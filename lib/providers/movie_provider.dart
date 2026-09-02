import 'package:flutter/foundation.dart';

import '../controllers/movie_controller.dart';
import '../models/movie.dart';



export '../controllers/movie_controller.dart'
    show MovieEndpoint, MovieEndpointSlug;







class MovieProvider extends ChangeNotifier {
  MovieProvider(this._controller);

  final MovieController _controller;

  
  final Map<String, List<Movie>> _moviesByEndpoint = {};

  
  List<Movie> _searchResults = [];

  
  bool _isLoading = false;

  
  String? _error;

  
  List<Movie> getMovies(MovieEndpoint endpoint) =>
      _moviesByEndpoint[endpoint.slug] ?? const [];

  List<Movie> get searchResults => List.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;
  String? get error => _error;

  
  
  
  Future<void> loadMovies(
    MovieEndpoint endpoint, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _moviesByEndpoint.containsKey(endpoint.slug)) {
      return; 
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final movies = await _controller.fetchMovies(endpoint);
      _moviesByEndpoint[endpoint.slug] = movies;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Something went wrong while loading movies.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> search(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _controller.search(query);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Something went wrong while searching.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}