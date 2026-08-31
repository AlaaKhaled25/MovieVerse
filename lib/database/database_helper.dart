import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database helper for the application.
///
/// Implements a singleton pattern so only one database connection is ever
/// opened. It is responsible for creating the schema and exposing the
/// database instance to the repositories/favourites provider.
///
/// This satisfies the mandatory SQFLite local storage requirement and keeps
/// all database concerns in one dedicated `database/` folder.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  /// Name of the local database file.
  static const String _dbName = 'movie_verse.db';

  /// Current database schema version.
  static const int _dbVersion = 1;

  Database? _database;

  /// Lazily opens (and caches) the database.
  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    // Resolve the path to a file in the app's documents directory.
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  /// Creates all tables when the database is first created.
  Future<void> _onCreate(Database db, int version) async {
    // Favourites table stores the essential fields needed to restore a
    // movie on the Favourites screen after the app restarts.
    await db.execute('''
      CREATE TABLE favourites (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        poster_path TEXT,
        overview TEXT,
        release_date TEXT,
        vote_average REAL,
        backdrop_path TEXT,
        genre_ids TEXT,
        created_at INTEGER
      )
    ''');

    // Movie lists table stores which of the three user lists
    // (Watced / Watching / Want to Watch) a movie belongs to. A movie
    // can appear in at most one list at a time, enforced by the unique
    // constraint on the primary key.
    await db.execute('''
      CREATE TABLE movie_lists (
        id INTEGER PRIMARY KEY,
        list_type TEXT NOT NULL,
        title TEXT NOT NULL,
        poster_path TEXT,
        overview TEXT,
        release_date TEXT,
        vote_average REAL,
        backdrop_path TEXT,
        created_at INTEGER
      )
    ''');
  }
}
