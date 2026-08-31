import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/favourites_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_helpers.dart';

/// Screen showing the full details of a selected movie. Includes the poster,
/// title, overview, release date, rating, genres and runtime (when provided),
/// plus actions to add the movie to Favourites or to one of the personal
/// movie lists (Watched / Watching / Want to Watch).
class MovieDetailsScreen extends StatelessWidget {
  const MovieDetailsScreen({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    // Watch both providers so the icons update reactively when the user
    // taps favourite / list buttons.
    final favourites = context.watch<FavouritesProvider>();

    final isFav = favourites.isFavourite(movie.id);
    final listType = favourites.getListTypeOf(movie.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Large backdrop header with a back button overlay.
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildBackdrop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title + rating row.
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.accent, size: 22),
                    const SizedBox(width: 4),
                    Text(
                      AppHelpers.formatRating(movie.voteAverage),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      movie.releaseDate.isEmpty ? 'Unknown' : movie.releaseDate,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Genres (when known).
                if (AppHelpers.genresFromIds(movie.genreIds) != 'Unknown') ...[
                  Text(
                    AppHelpers.genresFromIds(movie.genreIds),
                    style: const TextStyle(color: AppColors.accent),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 12),

                // ---- Action buttons: Favourite + Add to List ----
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => favourites.toggleFavourite(movie),
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.redAccent : AppColors.accent,
                        ),
                        label: Text(isFav ? 'Favourited' : 'Favourite'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showListPicker(context),
                        icon: const Icon(Icons.playlist_add, color: AppColors.accent),
                        label: Text(
                          listType == null ? 'My Lists' : listType.label,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ---- Overview ----
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.overview.isEmpty
                      ? 'No overview available for this movie.'
                      : movie.overview,
                  style: const TextStyle(
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Backdrop image or a dark fallback when there's no image.
  Widget _buildBackdrop() {
    if (movie.backdropPath.isEmpty && movie.posterPath.isEmpty) {
      return Container(color: AppColors.surface);
    }
    final url = movie.backdropPath.isNotEmpty
        ? AppHelpers.backdropUrl(movie.backdropPath)
        : AppHelpers.posterUrl(movie.posterPath);
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(color: AppColors.surface),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surface,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      },
    );
  }

  /// Shows a bottom sheet letting the user add the movie to one of the three
  /// personal lists (or remove it from its current list).
  void _showListPicker(BuildContext context) {
    final favourites = context.read<FavouritesProvider>();
    final current = favourites.getListTypeOf(movie.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Add to list',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              for (final type in MovieListType.values)
                ListTile(
                  leading: const Icon(Icons.checklist, color: AppColors.accent),
                  title: Text(
                    type.label,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: current == type
                      ? const Icon(Icons.check, color: AppColors.accent)
                      : null,
                  onTap: () {
                    // Selecting the same list again removes the movie.
                    if (current == type) {
                      favourites.removeFromAllLists(movie.id);
                    } else {
                      favourites.addToList(movie, type);
                    }
                    Navigator.pop(sheetContext);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
