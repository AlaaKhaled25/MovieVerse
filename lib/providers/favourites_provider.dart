import 'package:flutter/foundation.dart';

import '../controllers/favourites_controller.dart';
import '../models/movie.dart';




export '../controllers/favourites_controller.dart'
    show MovieListType, MovieListTypeExtension;









class FavouritesProvider extends ChangeNotifier {
  final FavouritesController _controller = FavouritesController();

  
  final Map<int, Movie> _favourites = {};

  
  final Map<MovieListType, List<Movie>> _movieLists = {
    MovieListType.watched: [],
    MovieListType.watching: [],
    MovieListType.wantToWatch: [],
  };

  
  List<Movie> get favourites => _favourites.values.toList();

  
  List<Movie> getMoviesInList(MovieListType type) =>
      List.unmodifiable(_movieLists[type] ?? const []);

  
  bool isFavourite(int movieId) => _favourites.containsKey(movieId);

  
  MovieListType? getListTypeOf(int movieId) {
    for (final entry in _movieLists.entries) {
      if (entry.value.any((m) => m.id == movieId)) {
        return entry.key;
      }
    }
    return null;
  }

  
  
  
  Future<void> loadAll() async {
    final data = await _controller.loadAll();

    _favourites.clear();
    for (final movie in data.favourites) {
      _favourites[movie.id] = movie;
    }

    for (final type in MovieListType.values) {
      _movieLists[type] = [];
    }
    for (final entry in data.lists.entries) {
      _movieLists[entry.key] = entry.value;
    }

    notifyListeners();
  }

  
  
  Future<void> _persistWeb() {
    return _controller.writeWebState(
      favourites: _favourites.values.toList(),
      lists: _movieLists,
    );
  }

  

  
  Future<void> addFavourite(Movie movie) async {
    if (_favourites.containsKey(movie.id)) return;

    await _controller.insertFavourite(movie); 
    _favourites[movie.id] = movie;
    await _persistWeb(); 
    notifyListeners();
  }

  
  Future<void> removeFavourite(int movieId) async {
    await _controller.deleteFavourite(movieId); 
    _favourites.remove(movieId);
    await _persistWeb(); 
    notifyListeners();
  }

  
  Future<void> toggleFavourite(Movie movie) async {
    _favourites.containsKey(movie.id)
        ? await removeFavourite(movie.id)
        : await addFavourite(movie);
  }

  

  
  
  Future<void> addToList(Movie movie, MovieListType type) async {
    
    await _controller.deleteFromAllLists(movie.id); 
    for (final t in MovieListType.values) {
      _movieLists[t]!.removeWhere((m) => m.id == movie.id);
    }

    await _controller.insertToList(movie, type); 
    _movieLists[type]!.add(movie);
    await _persistWeb(); 
    notifyListeners();
  }

  
  Future<void> removeFromAllLists(int movieId) async {
    await _controller.deleteFromAllLists(movieId); 
    for (final type in MovieListType.values) {
      _movieLists[type]!.removeWhere((m) => m.id == movieId);
    }
    await _persistWeb(); 
    notifyListeners();
  }
}