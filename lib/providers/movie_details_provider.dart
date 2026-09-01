import 'package:flutter/foundation.dart';

import '../controllers/movie_controller.dart';
import '../models/movie_details.dart';

/// Provider that owns the REACTIVE state for a single movie's detail view:
/// loading, error and the fetched [MovieDetails] payload.
///
/// Keeping this separate from [MovieProvider] means tapping one movie doesn't
/// disturb the home/search lists already loaded. The actual fetching logic
/// lives in [MovieController].
class MovieDetailsProvider extends ChangeNotifier {
  MovieDetailsProvider(this._controller);

  final MovieController _controller;

  MovieDetails? _details;
  bool _isLoading = false;
  String? _error;

  MovieDetails? get details => _details;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches the full details for [movieId] (skipped if already loaded).
  Future<void> loadDetails(int movieId) async {
    if (_details?.movie.id == movieId) return;

    _isLoading = true;
    _error = null;
    _details = null;
    notifyListeners();

    try {
      _details = await _controller.fetchMovieDetails(movieId);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong while loading movie details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets the cached details (e.g. when navigating to a new movie).
  void clear() {
    _details = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}