import '../models/movie.dart';

/// Small collection of pure helper functions used across the app.
class AppHelpers {
  AppHelpers._();

  /// Builds a full poster image URL from a TMDB-relative poster path.
  ///
  /// If [path] is empty we fall back to a placeholder-ish empty string so
  /// callers can show a default image instead of crashing.
  static String posterUrl(String path, {String size = 'w342'}) {
    if (path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  /// Builds a full backdrop image URL from a TMDB-relative backdrop path.
  static String backdropUrl(String path, {String size = 'w780'}) {
    if (path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  /// Builds a full actor profile image URL from a TMDB-relative path.
  static String profileUrl(String path, {String size = 'w185'}) {
    if (path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  /// Formats a runtime in minutes into a human string like "2h 28m".
  static String formatRuntime(int minutes) {
    if (minutes <= 0) return 'Unknown';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Formats a large currency value (e.g. budget/revenue) as US dollars.
  static String formatCurrency(num value) {
    if (value <= 0) return '—';
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  /// Formats a numeric rating (e.g. 8.4) as a single decimal string.
  static String formatRating(double rating) => rating.toStringAsFixed(1);

  /// Returns the release year (e.g. "2024") from a "yyyy-MM-dd" date string,
  /// or 'Unknown' when no valid year can be extracted.
  static String releaseYear(String releaseDate) {
    if (releaseDate.isEmpty) return 'Unknown';
    return releaseDate.split('-').first;
  }

  /// Simple map to decode a handful of common genre IDs into readable names.
  /// Used on the Movie Details screen.
  static const Map<int, String> genreNames = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  /// Converts a list of genre ids into a readable "Genre, Genre" string.
  static String genresFromIds(List<int> ids) {
    if (ids.isEmpty) return 'Unknown';
    return ids
        .map((id) => genreNames[id] ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');
  }

  /// Provides the display name for a movie (used in lists).
  static String displayTitle(Movie movie) => movie.title;
}
