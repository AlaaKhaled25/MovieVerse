import '../models/movie.dart';
import '../models/movie_details.dart';
import '../services/tmdb_api_service.dart';



export '../services/tmdb_api_service.dart' show ApiException;


enum MovieEndpoint { popular, topRated, nowPlaying, upcoming }


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










class MovieController {
  MovieController(this._api);

  final TmdbApiService _api;

  
  Future<List<Movie>> fetchMovies(MovieEndpoint endpoint) async {
    try {
      return await _api.fetchMovies(endpoint.slug);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Something went wrong while loading movies.');
    }
  }

  
  Future<List<Movie>> search(String query) async {
    try {
      return await _api.searchMovies(query);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Something went wrong while searching.');
    }
  }

  
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