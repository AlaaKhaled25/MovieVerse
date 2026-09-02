import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/movie.dart';
import '../models/movie_details.dart';



class ApiException implements Exception {
  
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}






class TmdbApiService {
  TmdbApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  
  
  Future<Map<String, dynamic>> _getJson(String path, [Map<String, String>? query]) async {
    
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: {
        'api_key': ApiConfig.tmdbApiKey, 
        ...?query,
      },
    );

    http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      
      throw ApiException('Network error. Check your internet connection.');
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Invalid response received from the server.');
    }

    
    if (response.statusCode != 200) {
      final message = body['status_message'] ?? 'API error (${response.statusCode}).';
      throw ApiException(message as String);
    }

    return body;
  }

  
  
  
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

  
  
  
  Future<MovieDetails> fetchMovieDetails(int movieId) async {
    
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
