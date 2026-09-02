import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/state_view.dart';
import 'movie_details_screen.dart';




class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  
  
  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        context.read<MovieProvider>().clearSearch();
      } else {
        context.read<MovieProvider>().search(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                hintText: 'Search for a movie...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.movie),
              ),
            ),
          ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(MovieProvider provider) {
    
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return StateView.error(
        provider.error!,
        onRetry: () => provider.search(_controller.text),
      );
    }

    final results = provider.searchResults;

    
    if (_controller.text.trim().isEmpty) {
      return const StateView.empty(
        'Type a movie name to start searching.',
        icon: Icons.search,
      );
    }

    
    if (results.isEmpty) {
      return StateView.empty(
        'No results found for "${_controller.text.trim()}"',
        icon: Icons.search_off,
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
      itemCount: results.length,
      itemBuilder: (context, index) {
        final movie = results[index];
        return MovieCard(
          movie: movie,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
          ),
        );
      },
    );
  }
}
