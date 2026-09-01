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

/// The parsed result of loading favourites + lists from the database.
class FavouritesData {
  final List<Movie> favourites;
  final Map<MovieListType, List<Movie>> lists;

  FavouritesData({
    required this.favourites,
    required this.lists,
  });
}

/// Controller that owns the favourite & personal-lists BUSINESS logic.
///
/// This is the "C" in the MVC layering:
///   View (favourites/lists/details screens) -> Provider (FavouritesProvider,
///   reactive in-memory state) -> Controller (this class: persistence rules)
///   -> DatabaseHelper (SQFLite).
///
/// It decides HOW data is stored/read. The provider keeps the live state the
/// UI reacts to and calls back into this controller for every write.
class FavouritesController {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  /// On the web there is no native SQLite, so we fall back to in-memory only.
  /// (The real target is Android/iOS where SQFLite provides persistence.)
  final bool isWeb = kIsWeb;

  /// Loads all favourites and list rows from the database.
  ///
  /// Returns empty collections on the web (no database to read from).
  Future<FavouritesData> loadAll() async {
    if (isWeb) {
      return FavouritesData(
        favourites: const [],
        lists: {
          MovieListType.watched: const [],
          MovieListType.watching: const [],
          MovieListType.wantToWatch: const [],
        },
      );
    }

    final db = await _helper.database;

    final favRows = await db.query('favourites');
    final favourites = favRows.map(_movieFromDbRow).toList();

    final lists = <MovieListType, List<Movie>>{
      MovieListType.watched: [],
      MovieListType.watching: [],
      MovieListType.wantToWatch: [],
    };
    final listRows = await db.query('movie_lists');
    for (final row in listRows) {
      final type = _listTypeFromDb(row['list_type'] as String? ?? '');
      lists[type]!.add(_movieFromDbRow(row));
    }

    return FavouritesData(favourites: favourites, lists: lists);
  }

  /// Persists a movie into the favourites table.
  ///
  /// No-op on the web (in-memory only).
  Future<void> insertFavourite(Movie movie) async {
    if (isWeb) return;
    final db = await _helper.database;
    await db.insert('favourites', _toFavMap(movie));
  }

  /// Deletes a movie row from the favourites table.
  ///
  /// No-op on the web (in-memory only).
  Future<void> deleteFavourite(int movieId) async {
    if (isWeb) return;
    final db = await _helper.database;
    await db.delete('favourites', where: 'id = ?', whereArgs: [movieId]);
  }

  /// Persists a movie into a given movie-list table.
  ///
  /// No-op on the web (in-memory only).
  Future<void> insertToList(Movie movie, MovieListType type) async {
    if (isWeb) return;
    final db = await _helper.database;
    await db.insert('movie_lists', _toListMap(movie, type));
  }

  /// Removes a movie from every movie-list table.
  ///
  /// No-op on the web (in-memory only).
  Future<void> deleteFromAllLists(int movieId) async {
    if (isWeb) return;
    final db = await _helper.database;
    await db.delete('movie_lists', where: 'id = ?', whereArgs: [movieId]);
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