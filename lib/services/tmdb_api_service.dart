import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/movie.dart';
import '../models/movie_details.dart';

/// Custom exception used to surface meaningful API errors up to the
/// Controllers/UI layers, instead of raw `http` exceptions.
class ApiException implements Exception {
  /// Human friendly message describing the error.
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

/// Service responsible for communicating with The Movie Database (TMDB) REST
/// API.
///
/// This class follows the single responsibility principle: it ONLY handles
/// HTTP calls and JSON parsing. No UI logic lives here (see spec section 8).
class TmdbApiService {
  TmdbApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Base URL for all TMDB version 3 API calls.
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  /// Convenience method that performs a GET request and returns the decoded
  /// JSON body, while throwing a friendly [ApiException] on any failure.
  Future<Map<String, dynamic>> _getJson(String path, [Map<String, String>? query]) async {
    // Build the full URI with the API key attached.
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: {
        'api_key': ApiConfig.tmdbApiKey, // v3 style authentication.
        ...?query,
      },
    );

    http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      // Network / timeout failure (e.g. no internet connection).
      throw ApiException('Network error. Check your internet connection.');
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Invalid response received from the server.');
    }

    // TMDB returns an HTTP error code and a status_message on failures.
    if (response.statusCode != 200) {
      final message = body['status_message'] ?? 'API error (${response.statusCode}).';
      throw ApiException(message as String);
    }

    return body;
  }

  /// Fetches a list of movies for the given [endpoint] (e.g. popular, top_rated).
  ///
  /// [endpoint] is the TMDB list slug without slashes (e.g. 'popular').
  Future<List<Movie>> fetchMovies(String endpoint, {int page = 1}) async {
    final json = await _getJson(
      '/movie/$endpoint',
      {
        'page': '$page',
        'language': 'en-US',
      },
    );

    final results = json['results'] as List? ?? [];
    return results
        .map((item) => Movie.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Searches TMDB for movies matching [query].
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) {
      return [];
    }
    final json = await _getJson(
      '/search/movie',
      {
        'query': query,
        'page': '$page',
        'language': 'en-US',
      },
    );

    final results = json['results'] as List? ?? [];
    return results
        .map((item) => Movie.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Fetches full details for a single movie, including its cast (actors),
  /// studios (production companies) and all extended metadata (runtime,
  /// budget, revenue, tagline, status, languages, countries...).
  Future<MovieDetails> fetchMovieDetails(int movieId) async {
    // The `credits` appendage adds the cast to the same response.
    final json = await _getJson(
      '/movie/$movieId',
      {
        'language': 'en-US',
        'append_to_response': 'credits',
      },
    );
    return MovieDetails.fromJson(json);
  }
}
