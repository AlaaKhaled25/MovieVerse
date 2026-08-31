import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../utils/app_colors.dart';
import '../utils/app_helpers.dart';

/// A reusable poster card used throughout the app (home grids, search,
/// favourites, movie lists). Keeping this as a reusable widget avoids
/// duplicating layout/UI code in every screen.
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
  });

  /// The movie this card represents.
  final Movie movie;

  /// Optional callback invoked when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster image (with a themed fallback when no image is available).
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: movie.posterPath.isEmpty
                  ? _placeholder()
                  : Image.network(
                      AppHelpers.posterUrl(movie.posterPath),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => _placeholder(),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.surface,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 6),
          // Title (max 2 lines to keep cards tidy).
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Rating + release year in a compact row.
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.accent, size: 14),
              const SizedBox(width: 2),
              Text(
                AppHelpers.formatRating(movie.voteAverage),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                AppHelpers.releaseYear(movie.releaseDate),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// A simple styled placeholder shown when a poster is unavailable.
  Widget _placeholder() {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const Icon(Icons.local_movies, color: AppColors.textSecondary),
    );
  }
}
