import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favourites_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/movie_card.dart';
import '../widgets/state_view.dart';
import 'movie_details_screen.dart';




class MovieListsScreen extends StatelessWidget {
  const MovieListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: MovieListType.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Lists'),
          bottom: TabBar(
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.accent,
            tabs: [
              for (final type in MovieListType.values)
                Tab(text: type.label),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final type in MovieListType.values)
              _ListTab(type: type),
          ],
        ),
      ),
    );
  }
}


class _ListTab extends StatelessWidget {
  const _ListTab({required this.type});

  final MovieListType type;

  @override
  Widget build(BuildContext context) {
    final favourites = context.watch<FavouritesProvider>();
    final movies = favourites.getMoviesInList(type);

    if (movies.isEmpty) {
      return StateView.empty(
        'No movies in "${type.label}" yet.\nOpen a movie and add it to this list.',
        icon: Icons.checklist,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return Stack(
          children: [
            MovieCard(
              movie: movie,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
              ),
            ),
            
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => context.read<FavouritesProvider>()
                    .removeFromAllLists(movie.id),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
