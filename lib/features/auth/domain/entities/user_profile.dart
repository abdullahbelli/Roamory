import 'package:flutter/foundation.dart';

/// `public.profiles` tablosuna karşılık gelen gezgin profili domain varlığı.
///
/// Profil kurulumu tamamlanma kontrolü (`isSetupComplete`) yönlendirme
/// katmanında bu varlık üzerinden hesaplanır.
@immutable
class UserProfile {
  /// Gezgin profili varlığı oluşturur.
  const UserProfile({
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

  /// Kullanıcı kimliği (`profiles.id`).
  final String id;

  /// Benzersiz kullanıcı adı (`@` öneki olmadan saklanır).
  final String? username;

  /// Görünen ad soyad.
  final String? fullName;

  /// `avatars` bucket üzerinde tutulan herkese açık profil fotoğrafı URL'si.
  final String? avatarUrl;

  /// İsteğe bağlı kısa gezgin biyografisi.
  final String? bio;

  /// Kullanıcının yaşadığı şehir (`F02`).
  final String? homeCity;

  /// Kullanıcının yaşadığı ülke (`F02`).
  final String? homeCountry;

  /// Profilin diğer gezginlere açık olup olmadığı (`F02`, `F04`).
  final bool isPublic;

  /// Kullanıcının tercih ettiği uygulama dili (`tr` veya `en`).
  final String preferredLanguage;

  /// Ana uygulamaya geçiş için zorunlu profil alanlarının doluluğunu kontrol eder.
  ///
  /// Hem görünen ad hem de benzersiz kullanıcı adı tanımlanmadan kullanıcı
  /// ana sekmelere alınmaz (`A07` kapısı).
  bool get isSetupComplete =>
      (fullName?.trim().isNotEmpty ?? false) &&
      (username?.trim().isNotEmpty ?? false);

  /// Seçili alanları güncelleyerek yeni bir [UserProfile] örneği döndürür.
  UserProfile copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? homeCity,
    String? homeCountry,
    bool? isPublic,
    String? preferredLanguage,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      homeCity: homeCity ?? this.homeCity,
      homeCountry: homeCountry ?? this.homeCountry,
      isPublic: isPublic ?? this.isPublic,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          fullName == other.fullName &&
          avatarUrl == other.avatarUrl &&
          bio == other.bio &&
          homeCity == other.homeCity &&
          homeCountry == other.homeCountry &&
          isPublic == other.isPublic &&
          preferredLanguage == other.preferredLanguage;

  @override
  int get hashCode => Object.hash(
    id,
    username,
    fullName,
    avatarUrl,
    bio,
    homeCity,
    homeCountry,
    isPublic,
    preferredLanguage,
  );
}
