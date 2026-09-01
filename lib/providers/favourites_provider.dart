import 'package:flutter/foundation.dart';

import '../controllers/favourites_controller.dart';
import '../models/movie.dart';

// Re-export so existing consumers (movie_lists_screen.dart,
// movie_details_screen.dart, ...) keep their `import 'providers/
// favourites_provider.dart'` and still see MovieListType.
export '../controllers/favourites_controller.dart'
    show MovieListType, MovieListTypeExtension;

/// Provider that manages the REACTIVE state for both the global Favourites
/// list and the three personal movie lists (Watched / Watching / Want to
/// Watch).
///
/// The Provider keeps the in-memory data the UI reacts to; every read/write is
/// delegated to [FavouritesController], which owns the persistence rules:
///   - mobile: SQFLite (durable across restarts)
///   - web:    SharedPreferences (survives page reloads)
class FavouritesProvider extends ChangeNotifier {
  final FavouritesController _controller = FavouritesController();

  /// Currently stored favourite movies (keyed by movie id).
  final Map<int, Movie> _favourites = {};

  /// Movies per list type, keyed by list type.
  final Map<MovieListType, List<Movie>> _movieLists = {
    MovieListType.watched: [],
    MovieListType.watching: [],
    MovieListType.wantToWatch: [],
  };

  /// Read-only list of favourites.
  List<Movie> get favourites => _favourites.values.toList();

  /// Returns the movies currently stored in the given list.
  List<Movie> getMoviesInList(MovieListType type) =>
      List.unmodifiable(_movieLists[type] ?? const []);

  /// Whether the given movie is currently favourited.
  bool isFavourite(int movieId) => _favourites.containsKey(movieId);

  /// The list (if any) a movie currently belongs to.
  MovieListType? getListTypeOf(int movieId) {
    for (final entry in _movieLists.entries) {
      if (entry.value.any((m) => m.id == movieId)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Loads all favourite & list data from the persistence backend.
  ///
  /// Should be called once when the app starts (after authentication).
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

  /// On web, persists the full current snapshot. No-op on mobile (SQFLite is
  /// updated incrementally by the controller instead).
  Future<void> _persistWeb() {
    return _controller.writeWebState(
      favourites: _favourites.values.toList(),
      lists: _movieLists,
    );
  }

  // ===================== FAVOURITES =====================

  /// Adds a movie to favourites (persisting it).
  Future<void> addFavourite(Movie movie) async {
    if (_favourites.containsKey(movie.id)) return;

    await _controller.insertFavourite(movie); // mobile
    _favourites[movie.id] = movie;
    await _persistWeb(); // web
    notifyListeners();
  }

  /// Removes a movie from favourites.
  Future<void> removeFavourite(int movieId) async {
    await _controller.deleteFavourite(movieId); // mobile
    _favourites.remove(movieId);
    await _persistWeb(); // web
    notifyListeners();
  }

  /// Toggles whether a movie is favourited.
  Future<void> toggleFavourite(Movie movie) async {
    _favourites.containsKey(movie.id)
        ? await removeFavourite(movie.id)
        : await addFavourite(movie);
  }

  // ===================== MOVIE LISTS =====================

  /// Adds a movie to the given personal list, removing it from any other
  /// list first (a movie belongs to at most one list at a time).
  Future<void> addToList(Movie movie, MovieListType type) async {
    // Ensure only one membership: persist + memory first, then add.
    await _controller.deleteFromAllLists(movie.id); // mobile
    for (final t in MovieListType.values) {
      _movieLists[t]!.removeWhere((m) => m.id == movie.id);
    }

    await _controller.insertToList(movie, type); // mobile
    _movieLists[type]!.add(movie);
    await _persistWeb(); // web
    notifyListeners();
  }

  /// Removes a movie from every personal list.
  Future<void> removeFromAllLists(int movieId) async {
    await _controller.deleteFromAllLists(movieId); // mobile
    for (final type in MovieListType.values) {
      _movieLists[type]!.removeWhere((m) => m.id == movieId);
    }
    await _persistWeb(); // web
    notifyListeners();
  }
}