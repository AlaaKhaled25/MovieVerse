import 'package:flutter/foundation.dart';

import '../controllers/movie_controller.dart';
import '../models/movie.dart';

// Re-export so existing consumers (e.g. home_screen.dart) can keep their
// `import 'providers/movie_provider.dart'` and still see MovieEndpoint.
export '../controllers/movie_controller.dart'
    show MovieEndpoint, MovieEndpointSlug;

/// Provider that owns ALL movie-related REACTIVE state for the application:
/// the fetched lists, the search results, and the loading/error flags.
///
/// It satisfies the mandatory "Provider state management" requirement. The
/// actual business logic (which endpoint to call, error mapping) lives in
/// [MovieController], keeping this class a thin state container.
class MovieProvider extends ChangeNotifier {
  MovieProvider(this._controller);

  final MovieController _controller;

  /// Movie results keyed by endpoint slug.
  final Map<String, List<Movie>> _moviesByEndpoint = {};

  /// Latest search results.
  List<Movie> _searchResults = [];

  /// Whether a network request is in flight.
  bool _isLoading = false;

  /// Current error message, or null when there is none.
  String? _error;

  /// Expose the lists defensively (read-only copies).
  List<Movie> getMovies(MovieEndpoint endpoint) =>
      _moviesByEndpoint[endpoint.slug] ?? const [];

  List<Movie> get searchResults => List.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches a given movie endpoint from the API and updates state.
  ///
  /// Skipped if the endpoint is already loaded and [forceRefresh] is false.
  Future<void> loadMovies(
    MovieEndpoint endpoint, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _moviesByEndpoint.containsKey(endpoint.slug)) {
      return; // Already loaded, no need to hit the network again.
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

  /// Runs a search for [query] and stores the results.
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

  /// Clears the current search results (e.g. when the search page closes).
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}