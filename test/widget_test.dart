// Unit tests for the Movie model parsing logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_verse/models/movie.dart';

void main() {
  group('Movie.fromJson', () {
    test('parses a valid JSON map correctly', () {
      final json = {
        'id': 123,
        'title': 'Interstellar',
        'overview': 'A great movie',
        'poster_path': '/abc.jpg',
        'release_date': '2014-11-05',
        'vote_average': 8.6,
        'genre_ids': [12, 18],
        'adult': false,
        'original_language': 'en',
        'original_title': 'Interstellar',
        'backdrop_path': '/def.jpg',
        'vote_count': 1000,
        'popularity': 50.5,
        'video': false,
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 123);
      expect(movie.title, 'Interstellar');
      expect(movie.overview, 'A great movie');
      expect(movie.posterPath, '/abc.jpg');
      expect(movie.releaseDate, '2014-11-05');
      expect(movie.voteAverage, 8.6);
      expect(movie.genreIds, [12, 18]);
    });

    test('handles missing/empty fields gracefully without crashing', () {
      final movie = Movie.fromJson(const {});
      expect(movie.id, 0);
      expect(movie.title, '');
      expect(movie.voteAverage, 0.0);
      expect(movie.genreIds, isEmpty);
    });
  });
}
