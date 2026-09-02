



class Movie {
  
  final int id;

  
  final String posterPath;

  
  final String title;

  
  final String overview;

  
  final String releaseDate;

  
  final double voteAverage;

  
  final List<int> genreIds;

  
  final bool adult;

  
  final String originalLanguage;

  
  final String originalTitle;

  
  final String backdropPath;

  
  final int voteCount;

  
  final double popularity;

  
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
