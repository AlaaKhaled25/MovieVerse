// Unit tests for the Movie model parsing logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_verse/models/movie.dart';
import 'package:movie_verse/models/movie_details.dart';

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

  group('MovieDetails.fromJson', () {
    test('parses credits, studios and metadata', () {
      final json = {
        'id': 155,
        'title': 'The Dark Knight',
        'overview': 'A batman film',
        'poster_path': '/p.jpg',
        'release_date': '2008-07-18',
        'vote_average': 8.5,
        'runtime': 152,
        'budget': 185000000,
        'revenue': 1005000000,
        'tagline': 'Why so serious?',
        'status': 'Released',
        'imdb_id': 'tt0468569',
        'genres': [
          {'id': 18, 'name': 'Drama'},
          {'id': 28, 'name': 'Action'},
        ],
        'production_companies': [
          {'id': 1, 'name': 'Warner Bros.', 'logo_path': '/logo.png', 'origin_country': 'US'},
        ],
        'production_countries': [
          {'iso_3166_1': 'US', 'name': 'United States of America'},
        ],
        'spoken_languages': [
          {'iso_639_1': 'en', 'english_name': 'English'},
        ],
        'credits': {
          'cast': [
            {
              'id': 1,
              'name': 'Christian Bale',
              'character': 'Bruce Wayne',
              'profile_path': '/bale.jpg',
              'order': 0,
            },
            {
              'id': 2,
              'name': 'Heath Ledger',
              'character': 'Joker',
              'profile_path': '/ledger.jpg',
              'order': 1,
            },
          ],
        },
      };

      final details = MovieDetails.fromJson(json);

      expect(details.movie.id, 155);
      expect(details.runtimeMinutes, 152);
      expect(details.budget, 185000000);
      expect(details.tagline, 'Why so serious?');
      expect(details.status, 'Released');
      expect(details.cast.length, 2);
      expect(details.cast.first.name, 'Christian Bale');
      expect(details.cast.first.character, 'Bruce Wayne');
      expect(details.productionCompanies.length, 1);
      expect(details.productionCompanies.first.name, 'Warner Bros.');
      expect(details.productionCountries.first.name, 'United States of America');
      expect(details.spokenLanguages.first.name, 'English');
      // Genre ids should be captured for the details screen.
      expect(details.movie.genreIds, contains(18));
    });
  });
}
