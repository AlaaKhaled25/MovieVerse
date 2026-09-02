import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favourites_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/state_view.dart';
import 'movie_details_screen.dart';




class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favourites = context.watch<FavouritesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
      ),
      body: favourites.favourites.isEmpty
          ? const StateView.empty(
              'No favourites yet.\nTap the heart on a movie to save it here.',
              icon: Icons.favorite_border,
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: favourites.favourites.length,
              itemBuilder: (context, index) {
                final movie = favourites.favourites[index];
                return Stack(
                  children: [
                    MovieCard(
                      movie: movie,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MovieDetailsScreen(movie: movie),
                        ),
                      ),
                    ),
                    
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () =>
                            context.read<FavouritesProvider>().removeFavourite(movie.id),
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
            ),
    );
  }
}
