import '../models/movie.dart';


class AppHelpers {
  AppHelpers._();

  
  
  
  
  static String posterUrl(String path, {String size = 'w342'}) {
    if (path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  
  static String backdropUrl(String path, {String size = 'w780'}) {
    if (path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  
  static String profileUrl(String path, {String size = 'w185'}) {
    if (path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  
  static String formatRuntime(int minutes) {
    if (minutes <= 0) return 'Unknown';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  
  static String formatCurrency(num value) {
    if (value <= 0) return '—';
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  
  static String formatRating(double rating) => rating.toStringAsFixed(1);

  
  
  static String releaseYear(String releaseDate) {
    if (releaseDate.isEmpty) return 'Unknown';
    return releaseDate.split('-').first;
  }

  
  
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

  
  static String genresFromIds(List<int> ids) {
    if (ids.isEmpty) return 'Unknown';
    return ids
        .map((id) => genreNames[id] ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');
  }

  
  static String displayTitle(Movie movie) => movie.title;
}
