import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/movie.dart';

/// The three personal movie lists a user can maintain.
enum MovieListType { watched, watching, wantToWatch }

/// Extension helpers for the list types.
extension MovieListTypeExtension on MovieListType {
  String get dbValue {
    switch (this) {
      case MovieListType.watched:
        return 'watched';
      case MovieListType.watching:
        return 'watching';
      case MovieListType.wantToWatch:
        return 'want_to_watch';
    }
  }

  String get label {
    switch (this) {
      case MovieListType.watched:
        return 'Watched';
      case MovieListType.watching:
        return 'Watching';
      case MovieListType.wantToWatch:
        return 'Want to Watch';
    }
  }
}

MovieListType _listTypeFromDb(String value) {
  switch (value) {
    case 'watched':
      return MovieListType.watched;
    case 'watching':
      return MovieListType.watching;
    default:
      return MovieListType.wantToWatch;
  }
}

/// Maps a database row back to a [Movie].
Movie _movieFromDbRow(Map<String, Object?> row) {
  return Movie(
    id: row['id'] as int,
    title: row['title'] as String? ?? '',
    posterPath: row['poster_path'] as String? ?? '',
    overview: row['overview'] as String? ?? '',
    releaseDate: row['release_date'] as String? ?? '',
    voteAverage: (row['vote_average'] as num?)?.toDouble() ?? 0.0,
    backdropPath: row['backdrop_path'] as String? ?? '',
    genreIds: const [],
    adult: false,
    originalLanguage: '',
    originalTitle: '',
    voteCount: 0,
    popularity: 0.0,
    video: false,
  );
}

/// Provider that manages both the global Favourites list (SQFLite) and the
/// three personal movie lists (Watched / Watching / Want to Watch).
///
/// All data is persisted locally with SQFLite, so favourites and list entries
/// survive app restarts (a mandatory requirement).
class FavouritesProvider extends ChangeNotifier {
  final DatabaseHelper _helper = DatabaseHelper.instance;

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

  /// Loads all favourite & list data from the local database.
  ///
  /// Should be called once when the app starts (after authentication).
  Future<void> loadAll() async {
    final db = await _helper.database;

    final favRows = await db.query('favourites');
    _favourites.clear();
    for (final row in favRows) {
      final movie = _movieFromDbRow(row);
      _favourites[movie.id] = movie;
    }

    final listRows = await db.query('movie_lists');
    for (final type in MovieListType.values) {
      _movieLists[type] = [];
    }
    for (final row in listRows) {
      final type = _listTypeFromDb(row['list_type'] as String? ?? '');
      _movieLists[type]!.add(_movieFromDbRow(row));
    }

    notifyListeners();
  }

  // ===================== FAVOURITES =====================

  /// Adds a movie to favourites (persisting it in the database).
  Future<void> addFavourite(Movie movie) async {
    if (_favourites.containsKey(movie.id)) return;

    final db = await _helper.database;
    await db.insert('favourites', _toFavMap(movie));
    _favourites[movie.id] = movie;
    notifyListeners();
  }

  /// Removes a movie from favourites.
  Future<void> removeFavourite(int movieId) async {
    final db = await _helper.database;
    await db.delete('favourites', where: 'id = ?', whereArgs: [movieId]);
    _favourites.remove(movieId);
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
    await removeFromAllLists(movie.id); // ensure only one membership

    final db = await _helper.database;
    await db.insert('movie_lists', _toListMap(movie, type));
    _movieLists[type]!.add(movie);
    notifyListeners();
  }

  /// Removes a movie from every personal list.
  Future<void> removeFromAllLists(int movieId) async {
    final db = await _helper.database;
    await db.delete('movie_lists', where: 'id = ?', whereArgs: [movieId]);
    for (final type in MovieListType.values) {
      _movieLists[type]!.removeWhere((m) => m.id == movieId);
    }
    notifyListeners();
  }

  // ===================== MAPPING HELPERS =====================

  Map<String, Object?> _toFavMap(Movie m) => {
        'id': m.id,
        'title': m.title,
        'poster_path': m.posterPath,
        'overview': m.overview,
        'release_date': m.releaseDate,
        'vote_average': m.voteAverage,
        'backdrop_path': m.backdropPath,
        'genre_ids': m.genreIds.join(','),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

  Map<String, Object?> _toListMap(Movie m, MovieListType type) => {
        'id': m.id,
        'list_type': type.dbValue,
        'title': m.title,
        'poster_path': m.posterPath,
        'overview': m.overview,
        'release_date': m.releaseDate,
        'vote_average': m.voteAverage,
        'backdrop_path': m.backdropPath,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };
}
