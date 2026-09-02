import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../models/movie_details.dart';
import '../providers/favourites_provider.dart';
import '../providers/movie_details_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_helpers.dart';
import '../widgets/state_view.dart';










class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieDetailsProvider>().loadDetails(widget.movie.id);
    });
  }

  @override
  void dispose() {
    
    context.read<MovieDetailsProvider>().clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieDetailsProvider>();

    return Scaffold(
      body: _buildBody(provider),
    );
  }

  
  Widget _buildBody(MovieDetailsProvider provider) {
    
    if (provider.isLoading || provider.details == null) {
      return _buildScaffoldShell(
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    
    if (provider.error != null) {
      return _buildScaffoldShell(
        child: StateView.error(
          provider.error!,
          onRetry: () =>
              context.read<MovieDetailsProvider>().loadDetails(widget.movie.id),
        ),
      );
    }

    
    final details = provider.details!;
    return _buildScaffoldShell(child: _buildContent(details));
  }

  
  
  Widget _buildScaffoldShell({required Widget child}) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildBackdrop(),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.zero,
          sliver: SliverToBoxAdapter(child: child),
        ),
      ],
    );
  }

  
  Widget _buildBackdrop() {
    final movie = widget.movie;
    if (movie.backdropPath.isEmpty && movie.posterPath.isEmpty) {
      return Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: const Icon(
          Icons.local_movies,
          size: 80,
          color: AppColors.textSecondary,
        ),
      );
    }
    final url = movie.backdropPath.isNotEmpty
        ? AppHelpers.backdropUrl(movie.backdropPath)
        : AppHelpers.posterUrl(movie.posterPath);
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: const Icon(
          Icons.local_movies,
          size: 80,
          color: AppColors.textSecondary,
        ),
      ),
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

  
  Widget _buildContent(MovieDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoSection(details),
        _overviewSection(details),
        if (details.cast.isNotEmpty) _castSection(details),
        if (details.productionCompanies.isNotEmpty) _studioSection(details),
        _metadataSection(details),
        const SizedBox(height: 32),
      ],
    );
  }

  

  Widget _infoSection(MovieDetails details) {
    final movie = details.movie;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Text(
            movie.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),

          
          if (details.tagline.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              details.tagline,
              style: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: 12),

          
          Wrap(
            spacing: 14,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _metaChip(
                icon: Icons.star,
                iconColor: AppColors.accent,
                text: AppHelpers.formatRating(movie.voteAverage),
              ),
              _metaChip(
                icon: Icons.calendar_today,
                text: details.movie.releaseDate.isEmpty
                    ? 'Unknown'
                    : details.movie.releaseDate,
              ),
              _metaChip(
                icon: Icons.schedule,
                text: AppHelpers.formatRuntime(details.runtimeMinutes),
              ),
              if (details.status.isNotEmpty) _metaChip(icon: Icons.flag, text: details.status),
            ],
          ),

          const SizedBox(height: 12),

          
          _genreChips(movie.genreIds),

          const SizedBox(height: 20),

          
          _actionRow(details.movie),
        ],
      ),
    );
  }

  Widget _actionRow(Movie movie) {
    final favourites = context.watch<FavouritesProvider>();
    final isFav = favourites.isFavourite(movie.id);
    final listType = favourites.getListTypeOf(movie.id);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => favourites.toggleFavourite(movie),
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : AppColors.accent,
            ),
            label: Text(isFav ? 'Favourited' : 'Favourite'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showListPicker(context, movie),
            icon: const Icon(Icons.playlist_add, color: AppColors.accent),
            label: Text(listType == null ? 'My Lists' : listType.label,
                style: const TextStyle(color: AppColors.textPrimary)),
          ),
        ),
      ],
    );
  }

  

  Widget _overviewSection(MovieDetails details) {
    return _sectionPadding(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Overview'),
          const SizedBox(height: 8),
          Text(
            details.movie.overview.isEmpty
                ? 'No overview available for this movie.'
                : details.movie.overview,
            style: const TextStyle(
              height: 1.6,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _castSection(MovieDetails details) {
    
    final cast = [...details.cast]..sort((a, b) => a.order.compareTo(b.order));
    final top = cast.length > 15 ? cast.sublist(0, 15) : cast;

    return _sectionPadding(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Top Billed Cast'),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: top.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _ActorCard(member: top[index]),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _studioSection(MovieDetails details) {
    return _sectionPadding(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Production Studios'),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: details.productionCompanies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _StudioCard(company: details.productionCompanies[index]),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _metadataSection(MovieDetails details) {
    final countries = details.productionCountries
        .map((c) => c.name)
        .where((n) => n.isNotEmpty)
        .join(', ');
    final languages = details.spokenLanguages
        .map((l) => l.name)
        .where((n) => n.isNotEmpty)
        .join(', ');

    final items = <MapEntry<String, String>>[
      if (details.movie.releaseDate.isNotEmpty)
        MapEntry('Release Date', details.movie.releaseDate),
      MapEntry('Runtime', AppHelpers.formatRuntime(details.runtimeMinutes)),
      MapEntry('Budget', AppHelpers.formatCurrency(details.budget)),
      MapEntry('Revenue', AppHelpers.formatCurrency(details.revenue)),
      if (details.status.isNotEmpty) MapEntry('Status', details.status),
      if (details.movie.originalTitle != details.movie.title)
        MapEntry('Original Title', details.movie.originalTitle),
      if (details.movie.originalLanguage.isNotEmpty)
        MapEntry('Original Language', details.movie.originalLanguage.toUpperCase()),
      if (countries.isNotEmpty) MapEntry('Countries', countries),
      if (languages.isNotEmpty) MapEntry('Languages', languages),
      if (details.imdbId.isNotEmpty)
        MapEntry('IMDb ID', details.imdbId),
    ];

    return _sectionPadding(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Details'),
          const SizedBox(height: 8),
          _metadataGrid(items),
        ],
      ),
    );
  }

  Widget _metadataGrid(List<MapEntry<String, String>> items) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    items[i].key,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    items[i].value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  

  
  Widget _metaChip({
    required IconData icon,
    required String text,
    Color? iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor ?? AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  
  Widget _genreChips(List<int> genreIds) {
    final names = genreIds
        .map((id) => genreNameLookup[id] ?? AppHelpers.genreNames[id] ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final name in names)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionPadding(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: child);

  
  
  void _showListPicker(BuildContext context, Movie movie) {
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
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      if (current == type) {
                        await favourites.removeFromAllLists(movie.id);
                        messenger.showSnackBar(
                          SnackBar(content: Text('Removed from "${type.label}"')),
                        );
                      } else {
                        await favourites.addToList(movie, type);
                        messenger.showSnackBar(
                          SnackBar(content: Text('Added to "${type.label}"')),
                        );
                      }
                    } catch (_) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Could not update the list. Try again.'),
                        ),
                      );
                    }
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


class _ActorCard extends StatelessWidget {
  const _ActorCard({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          ClipOval(
            child: Container(
              width: 88,
              height: 88,
              color: AppColors.surface,
              child: member.profilePath.isEmpty
                  ? const Icon(Icons.person, size: 40, color: AppColors.textSecondary)
                  : Image.network(
                      AppHelpers.profileUrl(member.profilePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            member.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            member.character.isEmpty ? '—' : member.character,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}


class _StudioCard extends StatelessWidget {
  const _StudioCard({required this.company});

  final ProductionCompany company;

  @override
  Widget build(BuildContext context) {
    final hasLogo = company.logoPath.isNotEmpty;
    return Container(
      width: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLogo)
            Image.network(
              AppHelpers.posterUrl(company.logoPath, size: 'w185'),
              height: 32,
              errorBuilder: (_, _, _) => const Icon(
                Icons.business,
                color: AppColors.textSecondary,
              ),
            )
          else
            const Icon(Icons.business, color: AppColors.textSecondary, size: 28),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              company.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
