import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Maps a database / prefs row back to a [Movie].
Movie _movieFromRow(Map<String, dynamic> row) {
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

/// The parsed result of loading favourites + lists.
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
///   -> SQFLite (mobile) / SharedPreferences (web).
///
/// It decides HOW data is stored/read. The provider keeps the live state the
/// UI reacts to and calls back into this controller for every write.
class FavouritesController {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  /// True on web, where there is no native SQLite. We persist there with
  /// SharedPreferences (localStorage) instead, so data survives page reloads.
  final bool isWeb = kIsWeb;

  static const String _favKey = 'movieverse_favourites_v1';
  static const String _listsKey = 'movieverse_lists_v1';

  // ============================ LOADING ============================

  /// Loads all favourites and list rows from the persistence backend.
  ///
  /// Web: reads JSON from SharedPreferences. Mobile: reads SQFLite.
  Future<FavouritesData> loadAll() async {
    if (isWeb) {
      final prefs = await SharedPreferences.getInstance();

      final favouritesJson = prefs.getString(_favKey);
      final favourites = (jsonDecode(favouritesJson ?? '[]') as List)
          .whereType<Map<String, dynamic>>()
          .map(_movieFromRow)
          .toList();

      final lists = <MovieListType, List<Movie>>{
        MovieListType.watched: [],
        MovieListType.watching: [],
        MovieListType.wantToWatch: [],
      };
      final listsJson = prefs.getString(_listsKey);
      final rawLists = jsonDecode(listsJson ?? '[]') as List;
      for (final item in rawLists.whereType<Map<String, dynamic>>()) {
        final type = _listTypeFromDb(item['list_type'] as String? ?? '');
        lists[type]!.add(_movieFromRow(item));
      }

      return FavouritesData(favourites: favourites, lists: lists);
    }

    final db = await _helper.database;

    final favRows = await db.query('favourites');
    final favourites =
        favRows.map((r) => _movieFromRow(Map<String, dynamic>.of(r))).toList();

    final lists = <MovieListType, List<Movie>>{
      MovieListType.watched: [],
      MovieListType.watching: [],
      MovieListType.wantToWatch: [],
    };
    final listRows = await db.query('movie_lists');
    for (final row in listRows) {
      final type = _listTypeFromDb(row['list_type'] as String? ?? '');
      lists[type]!.add(_movieFromRow(Map<String, dynamic>.of(row)));
    }

    return FavouritesData(favourites: favourites, lists: lists);
  }

  // ============================ WRITING ============================

  /// Persists a movie into the favourites table (mobile only; no-op on web).
  Future<void> insertFavourite(Movie movie) async {
    if (isWeb) return;
    final db = await _helper.database;
    await db.insert('favourites', _toFavMap(movie));
  }

  /// Deletes a movie row from the favourites table (mobile only).
  Future<void> deleteFavourite(int movieId) async {
    if (isWeb) return;
    final db = await _helper.database;
    await db.delete('favourites', where: 'id = ?', whereArgs: [movieId]);
  }

  /// Persists a movie into a given movie-list table (mobile only).
  Future<void> insertToList(Movie movie, MovieListType type) async {
    if (isWeb) return;
    final db = await _helper.database;
    await db.insert('movie_lists', _toListMap(movie, type));
  }

  /// Removes a movie from every movie-list table (mobile only).
  Future<void> deleteFromAllLists(int movieId) async {
    if (isWeb) return;
    final db = await _helper.database;
    await db.delete('movie_lists', where: 'id = ?', whereArgs: [movieId]);
  }

  /// Persists the FULL favourites + lists snapshot (web only; no-op on mobile)
  /// so that every change survives a page reload.
  Future<void> writeWebState({
    required List<Movie> favourites,
    required Map<MovieListType, List<Movie>> lists,
  }) async {
    if (!isWeb) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _favKey,
      jsonEncode(favourites.map(_toFavMap).toList()),
    );
    await prefs.setString(
      _listsKey,
      jsonEncode([
        for (final type in MovieListType.values)
          for (final movie in lists[type] ?? const <Movie>[])
            _toListMap(movie, type),
      ]),
    );
  }

  // ===================== MAPPING HELPERS =====================

  Map<String, dynamic> _toFavMap(Movie m) => {
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

  Map<String, dynamic> _toListMap(Movie m, MovieListType type) => {
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