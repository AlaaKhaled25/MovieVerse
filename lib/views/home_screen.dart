import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/movie_card.dart';
import '../widgets/state_view.dart';
import 'movie_details_screen.dart';

/// The Home screen. It shows several horizontal lists of TMDB content:
/// Popular, Top Rated, Now Playing and Upcoming.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // The vertical list of sections shown on the home screen.
  static const _sections = [
    MovieEndpoint.popular,
    MovieEndpoint.nowPlaying,
    MovieEndpoint.topRated,
    MovieEndpoint.upcoming,
  ];

  @override
  void initState() {
    super.initState();
    // Kick off loading for all sections when the screen first appears.
    final provider = context.read<MovieProvider>();
    for (final section in _sections) {
      provider.loadMovies(section);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MovieVerse'),
      ),
      body: RefreshIndicator(
        // Pull-to-refresh reloads every section from the network.
        onRefresh: () async {
          for (final section in _sections) {
            await context.read<MovieProvider>().loadMovies(section, forceRefresh: true);
          }
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _sections.length,
          itemBuilder: (context, index) {
            final section = _sections[index];
            return _Section(
              section: section,
              movies: provider.getMovies(section),
              isLoading: provider.isLoading,
              error: provider.error,
            );
          },
        ),
      ),
    );
  }
}

/// A single horizontal scrolling section (e.g. "Popular") on the home screen.
class _Section extends StatelessWidget {
  const _Section({
    required this.section,
    required this.movies,
    required this.isLoading,
    required this.error,
  });

  final MovieEndpoint section;
  final List<Movie> movies;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            section.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildContent(context),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    // Show a loading indicator while this (or another) section loads.
    if (isLoading && movies.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Show a clear error state with a retry option.
    if (error != null && movies.isEmpty) {
      return SizedBox(
        height: 160,
        child: StateView.error(
          error!,
          onRetry: () => context.read<MovieProvider>().loadMovies(section, forceRefresh: true),
        ),
      );
    }

    // Show an empty state when nothing was returned.
    if (movies.isEmpty) {
      return const SizedBox(
        height: 160,
        child: StateView.empty('No movies yet. Pull to refresh.'),
      );
    }

    // Horizontal list of movie cards.
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return SizedBox(
            width: 130,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: MovieCard(
                movie: movie,
                onTap: () => _openDetails(context, movie),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openDetails(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
    );
  }
}
