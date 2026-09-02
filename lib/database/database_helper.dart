import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';









class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  
  static const String _dbName = 'movie_verse.db';

  
  static const int _dbVersion = 1;

  Database? _database;

  
  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  
  Future<void> _onCreate(Database db, int version) async {
    
    
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
