import '../models/movie.dart';
import '../models/movie_details.dart';
import '../services/tmdb_api_service.dart';

// Re-export so consumers (providers) can refer to ApiException without
// importing the service directly.
export '../services/tmdb_api_service.dart' show ApiException;

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

/// Controller that owns the movie BUSINESS logic.
///
/// This is the "C" in the MVC layering:
///   View (home/search/details screens) -> Provider (state, e.g. MovieProvider)
///   -> Controller (this class, what to fetch + friendly error mapping)
///   -> TmdbApiService (pure HTTP/JSON).
///
/// The controller holds NO UI state; it only decides WHICH data to request and
/// translates low-level failures into user-safe [ApiException]s.
class MovieController {
  MovieController(this._api);

  final TmdbApiService _api;

  /// Fetches the movie list for a given [endpoint] from the API.
  Future<List<Movie>> fetchMovies(MovieEndpoint endpoint) async {
    try {
      return await _api.fetchMovies(endpoint.slug);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Something went wrong while loading movies.');
    }
  }

  /// Runs a search for [query] against the API.
  Future<List<Movie>> search(String query) async {
    try {
      return await _api.searchMovies(query);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Something went wrong while searching.');
    }
  }

  /// Fetches the full details (cast, studios, metadata) for [movieId].
  Future<MovieDetails> fetchMovieDetails(int movieId) async {
    try {
      return await _api.fetchMovieDetails(movieId);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Something went wrong while loading movie details.');
    }
  }
}