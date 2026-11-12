import 'package:roamory/features/auth/domain/entities/user_profile.dart';

/// `public.profiles` tablosundan okunan ve yazılan JSON veri aktarım modeli.
///
/// Domain katmanındaki [UserProfile] varlığını Supabase şemasından izole eder.
class UserProfileModel {
  /// [UserProfileModel] örneği oluşturur.
  const UserProfileModel({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.homeCity,
    this.homeCountry,
    this.isPublic = true,
    this.preferredLanguage = 'tr',
  });

  /// Supabase `profiles` satırından DTO oluşturur.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      homeCity: json['home_city'] as String?,
      homeCountry: json['home_country'] as String?,
      isPublic: (json['is_public'] as bool?) ?? true,
      preferredLanguage: (json['preferred_language'] as String?) ?? 'tr',
    );
  }

  /// Kullanıcı kimliği (`auth.users.id`).
  final String id;

  /// Benzersiz kullanıcı adı.
  final String? username;

  /// Görünen ad soyad.
  final String? fullName;

  /// Herkese açık avatar URL'si.
  final String? avatarUrl;

  /// Kısa gezgin biyografisi.
  final String? bio;

  /// Yaşadığı şehir.
  final String? homeCity;

  /// Yaşadığı ülke.
  final String? homeCountry;

  /// Profilin herkese açık olup olmadığı.
  final bool isPublic;

  /// Tercih edilen dil (`tr` / `en`).
  final String preferredLanguage;

  /// DTO'yu bağımsız domain varlığına dönüştürür.
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
      bio: bio,
      homeCity: homeCity,
      homeCountry: homeCountry,
      isPublic: isPublic,
      preferredLanguage: preferredLanguage,
    );
  }

  /// Supabase `upsert` işlemi için canlı `public.profiles` tablosuyla uyumlu kolon haritası üretir.
  Map<String, dynamic> toUpsertJson() {
    // Canlı veritabanı şemasında yalnızca id, username, full_name, avatar_url, bio ve
    // preferred_language kolonları bulunduğu için yalnızca bu alanları gönderiyoruz.
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'bio': bio,
      'preferred_language': preferredLanguage,
    };
  }
}
