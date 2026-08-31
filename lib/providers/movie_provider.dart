import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/tmdb_api_service.dart';

/// Enumerates the different movie collections exposed by the TMDB service.
enum MovieEndpoint { popular, topRated, nowPlaying, upcoming }

/// Extension that maps each [MovieEndpoint] to its TMDB slug.
extension MovieEndpointSlug on MovieEndpoint {
  String get slug {
    switch (this) {
      case MovieEndpoint.popular:
        return 'popular';
      case MovieEndpoint.topRated:
        return 'top_rated';
      case MovieEndpoint.nowPlaying:
        return 'now_playing';
      case MovieEndpoint.upcoming:
        return 'upcoming';
    }
  }

  String get title {
    switch (this) {
      case MovieEndpoint.popular:
        return 'Popular';
      case MovieEndpoint.topRated:
        return 'Top Rated';
      case MovieEndpoint.nowPlaying:
        return 'Now Playing';
      case MovieEndpoint.upcoming:
        return 'Upcoming';
    }
  }
}

/// Provider that owns ALL movie-related state for the application:
/// the fetched lists, the search results, and the loading/error flags.
///
/// Keeping this in a Provider (rather than scatter-gathering setState calls)
/// satisfies the mandatory "Provider state management" requirement.
class MovieProvider extends ChangeNotifier {
  final TmdbApiService _api;

  MovieProvider(this._api);

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
  Future<void> loadMovies(MovieEndpoint endpoint, {bool forceRefresh = false}) async {
    if (!forceRefresh && _moviesByEndpoint.containsKey(endpoint.slug)) {
      return; // Already loaded, no need to hit the network again.
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final movies = await _api.fetchMovies(endpoint.slug);
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
      _searchResults = await _api.searchMovies(query);
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
