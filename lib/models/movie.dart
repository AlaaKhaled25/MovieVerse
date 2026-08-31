/// This is the primary data model for a movie in the application.
///
/// It represents the structure returned by the TMDB (The Movie Database)
/// API for an individual movie. Only the fields we actually need are kept.
class Movie {
  /// Unique identifier of the movie on TMDB.
  final int id;

  /// The full poster path returned by the API (e.g. "/abc123.jpg").
  final String posterPath;

  /// The title of the movie.
  final String title;

  /// A short synopsis / overview text for the movie.
  final String overview;

  /// The release date as a plain string (e.g. "2024-05-03").
  final String releaseDate;

  /// Average vote rating on a scale of 0 to 10.
  final double voteAverage;

  /// List of genre ids associated with this movie.
  final List<int> genreIds;

  /// Whether an adult audience rating was returned. Kept for completeness.
  final bool adult;

  /// Original language code of the movie (e.g. "en", "ar").
  final String originalLanguage;

  /// Original title (before localisation).
  final String originalTitle;

  /// Backdrop image path used for header visuals.
  final String backdropPath;

  /// Number of votes the movie has received.
  final int voteCount;

  /// Popularity score provided by TMDB.
  final double popularity;

  /// Whether the movie is only available for adult audiences.
  final bool video;

  Movie({
    required this.id,
    required this.posterPath,
    required this.title,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    required this.genreIds,
    required this.adult,
    required this.originalLanguage,
    required this.originalTitle,
    required this.backdropPath,
    required this.voteCount,
    required this.popularity,
    required this.video,
  });

  /// Builds a [Movie] from a JSON map returned by the TMDB API.
  ///
  /// All casts are defensive so that a missing or null field does not crash
  /// the whole application. Optional/empty values fall back to a safe default.
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      posterPath: json['poster_path'] ?? '',
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      genreIds: (json['genre_ids'] as List?)?.cast<int>() ?? [],
      adult: json['adult'] ?? false,
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteCount: json['vote_count'] ?? 0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      video: json['video'] ?? false,
    );
  }
}
