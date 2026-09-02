import 'movie.dart';


class CastMember {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
    required this.order,
  });

  final int id;
  final String name;
  final String character;
  final String profilePath;
  final int order;

  factory CastMember.fromJson(Map<String, dynamic> json) => CastMember(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        character: json['character'] ?? '',
        profilePath: json['profile_path'] ?? '',
        order: json['order'] ?? 0,
      );
}


class ProductionCompany {
  const ProductionCompany({
    required this.id,
    required this.name,
    required this.logoPath,
    required this.originCountry,
  });

  final int id;
  final String name;
  final String logoPath;
  final String originCountry;

  factory ProductionCompany.fromJson(Map<String, dynamic> json) =>
      ProductionCompany(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        logoPath: json['logo_path'] ?? '',
        originCountry: json['origin_country'] ?? '',
      );
}


class ProductionCountry {
  const ProductionCountry({required this.iso, required this.name});

  final String iso;
  final String name;

  factory ProductionCountry.fromJson(Map<String, dynamic> json) =>
      ProductionCountry(
        iso: json['iso_3166_1'] ?? '',
        name: json['name'] ?? '',
      );
}


class SpokenLanguage {
  const SpokenLanguage({required this.code, required this.name});

  final String code;
  final String name;

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) => SpokenLanguage(
        code: json['iso_639_1'] ?? '',
        name: json['english_name'] ?? json['name'] ?? '',
      );
}






class MovieDetails {
  const MovieDetails({
    required this.movie,
    required this.runtimeMinutes,
    required this.budget,
    required this.revenue,
    required this.tagline,
    required this.status,
    required this.homepage,
    required this.imdbId,
    required this.cast,
    required this.productionCompanies,
    required this.productionCountries,
    required this.spokenLanguages,
  });

  final Movie movie;
  final int runtimeMinutes;
  final num budget;
  final num revenue;
  final String tagline;
  final String status;
  final String homepage;
  final String imdbId;
  final List<CastMember> cast;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final List<SpokenLanguage> spokenLanguages;

  
  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    
    
    final genreList = (json['genres'] as List?) ?? [];
    final genreIds = genreList
        .map((g) => (g as Map<String, dynamic>)['id'] as int? ?? 0)
        .where((id) => id != 0)
        .toList();

    
    final movieJson = Map<String, dynamic>.from(json)
      ..['genre_ids'] = genreIds;
    final movie = Movie.fromJson(movieJson);

    
    final genreNames = <int, String>{};
    for (final g in genreList) {
      final map = g as Map<String, dynamic>;
      final id = map['id'] as int?;
      final name = map['name'] as String?;
      if (id != null && name != null) genreNames[id] = name;
    }
    
    genreNameLookup.addAll(genreNames);

    final credits = json['credits'] as Map<String, dynamic>? ?? {};
    final castList = (credits['cast'] as List?) ?? [];

    return MovieDetails(
      movie: movie,
      runtimeMinutes: json['runtime'] ?? 0,
      budget: json['budget'] ?? 0,
      revenue: json['revenue'] ?? 0,
      tagline: json['tagline'] ?? '',
      status: json['status'] ?? '',
      homepage: json['homepage'] ?? '',
      imdbId: json['imdb_id'] ?? '',
      productionCompanies: (json['production_companies'] as List? ?? [])
          .map((c) => ProductionCompany.fromJson(c as Map<String, dynamic>))
          .toList(),
      productionCountries: (json['production_countries'] as List? ?? [])
          .map((c) => ProductionCountry.fromJson(c as Map<String, dynamic>))
          .toList(),
      spokenLanguages: (json['spoken_languages'] as List? ?? [])
          .map((l) => SpokenLanguage.fromJson(l as Map<String, dynamic>))
          .toList(),
      cast: castList
          .map((c) => CastMember.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}





final Map<int, String> genreNameLookup = {};
