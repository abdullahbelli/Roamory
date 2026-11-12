import 'package:flutter/foundation.dart';

/// `public.categories` tablosuna karşılık gelen mekan/deneyim kategorisi varlığı.
///
/// Hem Keşfet filtrelerinde (`B02`, `B03`) hem de ziyaret etiketlemede (`C04`)
/// kullanılan çok dilli (`name_tr`, `name_en`) kategori bilgisini taşır.
@immutable
class CategoryEntity {
  /// Kategori varlığı oluşturur.
  const CategoryEntity({
    required this.id,
    required this.slug,
    required this.nameTr,
    required this.nameEn,
    this.iconName,
  });

  /// Kategori benzersiz kimliği (`categories.id`).
  final String id;

  /// URL/kod dostu anahtar (`nature`, `history`, `food` vb.).
  final String slug;

  /// Türkçe görünen kategori adı.
  final String nameTr;

  /// İngilizce görünen kategori adı.
  final String nameEn;

  /// İsteğe bağlı ikon tanımlayıcısı.
  final String? iconName;

  /// Aktif dil koduna (`tr` veya `en`) göre uygun kategori adını döndürür.
  String localizedName(String languageCode) {
    return languageCode.toLowerCase().startsWith('en') ? nameEn : nameTr;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          slug == other.slug &&
          nameTr == other.nameTr &&
          nameEn == other.nameEn;

  @override
  int get hashCode => Object.hash(id, slug, nameTr, nameEn);
}

/// `public.places` tablosuna karşılık gelen destinasyon/mekan domain varlığı.
///
/// Katalogdaki herkese açık (`isPublished: true`) mekanları ve kullanıcının
/// kendi haritası için oluşturduğu özel (`isPublished: false`, `createdBy: uid`)
/// mekanları temsil eder.
@immutable
class PlaceEntity {
  /// Mekan varlığı oluşturur.
  const PlaceEntity({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.description,
    this.categoryId,
    this.categorySlug,
    this.coverImageUrl,
    this.isPublished = true,
    this.createdBy,
    this.averageRating,
    this.createdAt,
  });

  /// Mekan kimliği (`places.id`).
  final String id;

  /// Mekan adı.
  final String name;

  /// Ülke adı.
  final String country;

  /// Şehir veya bölge adı.
  final String city;

  /// Coğrafi enlem (`-90.0` .. `90.0`).
  final double latitude;

  /// Coğrafi boylam (`-180.0` .. `180.0`).
  final double longitude;

  /// Mekan açıklaması veya hikayesi.
  final String? description;

  /// İlişkili kategori kimliği (`categories.id`).
  final String? categoryId;

  /// İlişkili kategori kısa kodu (`slug`).
  final String? categorySlug;

  /// Varsa mekanın kapak görseli URL'si.
  final String? coverImageUrl;

  /// Mekanın genel katalogda yayınlanıp yayınlanmadığı.
  ///
  /// `false` ise yalnızca oluşturan kullanıcı (`createdBy`) tarafından görülür.
  final bool isPublished;

  /// Mekanı oluşturan kullanıcının kimliği (`auth.uid()`).
  final String? createdBy;

  /// Varsa gerçek ziyaretlerden hesaplanan ortalama puan.
  final double? averageRating;

  /// Kayıt oluşturulma zamanı.
  final DateTime? createdAt;

  /// Şehir ve ülke bilgisini `Şehir, Ülke` biçiminde birleştirir.
  String get locationLabel {
    final cleanCity = city.trim();
    final cleanCountry = country.trim();
    if (cleanCity.isEmpty) {
      return cleanCountry;
    }
    if (cleanCountry.isEmpty) {
      return cleanCity;
    }
    return '$cleanCity, $cleanCountry';
  }

  /// Coğrafi koordinatların dünya sınırları içinde geçerli olup olmadığını denetler.
  bool get hasValidCoordinates =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  /// Belirtilen alanları güncelleyerek yeni bir [PlaceEntity] kopyası döndürür.
  PlaceEntity copyWith({
    String? id,
    String? name,
    String? country,
    String? city,
    double? latitude,
    double? longitude,
    String? description,
    String? categoryId,
    String? categorySlug,
    String? coverImageUrl,
    bool? isPublished,
    String? createdBy,
    double? averageRating,
    DateTime? createdAt,
  }) {
    return PlaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categorySlug: categorySlug ?? this.categorySlug,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isPublished: isPublished ?? this.isPublished,
      createdBy: createdBy ?? this.createdBy,
      averageRating: averageRating ?? this.averageRating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          country == other.country &&
          city == other.city &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          coverImageUrl == other.coverImageUrl &&
          isPublished == other.isPublished;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    country,
    city,
    latitude,
    longitude,
    coverImageUrl,
    isPublished,
  );
}

/// Keşfet ve Arama (`B02`, `B03`) ekranlarında kullanılan filtre kriterleri.
@immutable
class PlaceSearchFilter {
  /// Arama filtresi oluşturur.
  const PlaceSearchFilter({
    this.query = '',
    this.categorySlug,
    this.country,
    this.city,
    this.minRating,
    this.sortAlphabetically = false,
  });

  /// Serbest metin arama sorgusu (mekan adı, şehir veya ülke).
  final String query;

  /// Seçili kategori `slug` değeri (`null` ise tüm kategoriler).
  final String? categorySlug;

  /// Ülke filtresi.
  final String? country;

  /// Şehir filtresi.
  final String? city;

  /// Minimum puan filtresi (`1`..`5`).
  final double? minRating;

  /// `true` ise A-Z alfabetik, `false` ise en yeniye göre sıralar.
  final bool sortAlphabetically;

  /// Herhangi bir aktif filtre uygulanıp uygulanmadığını döndürür.
  bool get hasActiveFilters =>
      query.trim().isNotEmpty ||
      (categorySlug != null && categorySlug!.isNotEmpty) ||
      (country != null && country!.trim().isNotEmpty) ||
      (city != null && city!.trim().isNotEmpty) ||
      minRating != null ||
      sortAlphabetically;

  /// Seçili alanları güncelleyerek yeni bir filtre örneği döndürür.
  PlaceSearchFilter copyWith({
    String? query,
    String? categorySlug,
    bool clearCategory = false,
    String? country,
    bool clearCountry = false,
    String? city,
    bool clearCity = false,
    double? minRating,
    bool clearMinRating = false,
    bool? sortAlphabetically,
  }) {
    return PlaceSearchFilter(
      query: query ?? this.query,
      categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
      country: clearCountry ? null : (country ?? this.country),
      city: clearCity ? null : (city ?? this.city),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sortAlphabetically: sortAlphabetically ?? this.sortAlphabetically,
    );
  }
}

/// Kullanıcının kişisel haritası için yeni özel mekan oluşturma isteği.
@immutable
class CreatePrivatePlaceRequest {
  /// Özel mekan oluşturma isteği yaratır.
  const CreatePrivatePlaceRequest({
    required this.userId,
    required this.name,
    required this.country,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.description,
    this.categoryId,
  });

  /// Oluşturan kullanıcı kimliği (`auth.uid()`).
  final String userId;

  /// Mekan adı.
  final String name;

  /// Ülke adı.
  final String country;

  /// Şehir adı.
  final String city;

  /// Enlem (`-90..90`).
  final double latitude;

  /// Boylam (`-180..180`).
  final double longitude;

  /// İsteğe bağlı açıklama.
  final String? description;

  /// İsteğe bağlı kategori kimliği.
  final String? categoryId;
}
