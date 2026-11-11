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
      preferredLanguage: preferredLanguage,
    );
  }

  /// Supabase `upsert` işlemi için kolon haritası üretir.
  Map<String, dynamic> toUpsertJson() {
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
