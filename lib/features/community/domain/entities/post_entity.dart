import 'package:flutter/foundation.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';

/// Toplulukta yer alan gezgin özet profili.
@immutable
class TravelerSummaryEntity {
  /// Gezgin özeti oluşturur.
  const TravelerSummaryEntity({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    this.homeCity,
    this.homeCountry,
    this.isPublic = true,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowedByCurrentUser = false,
    this.isBlockedByCurrentUser = false,
  });

  /// Kullanıcı kimliği (`profiles.id`).
  final String id;

  /// Benzersiz kullanıcı adı (`@` olmadan).
  final String username;

  /// Görünen ad soyad.
  final String fullName;

  /// Herkese açık avatar URL'si.
  final String? avatarUrl;

  /// Kısa biyografi.
  final String? bio;

  /// Yaşadığı şehir.
  final String? homeCity;

  /// Yaşadığı ülke.
  final String? homeCountry;

  /// Profilin herkese açık olup olmadığı.
  final bool isPublic;

  /// Yayınlanmış gönderi sayısı (gerçek veritabanı sayımı).
  final int postsCount;

  /// Takipçi sayısı (gerçek veritabanı sayımı).
  final int followersCount;

  /// Takip edilen gezgin sayısı (gerçek veritabanı sayımı).
  final int followingCount;

  /// Aktif oturumdaki kullanıcının bu gezgini takip edip etmediği.
  final bool isFollowedByCurrentUser;

  /// Aktif oturumdaki kullanıcının bu gezgini engelleyip engellemediği.
  final bool isBlockedByCurrentUser;

  /// Konum bilgisini `Şehir, Ülke` olarak biçimlendirir.
  String get locationLabel {
    final c = homeCity?.trim() ?? '';
    final co = homeCountry?.trim() ?? '';
    if (c.isEmpty) {
      return co;
    }
    if (co.isEmpty) {
      return c;
    }
    return '$c, $co';
  }

  /// Takip veya engel durumunu güncelleyerek kopya üretir.
  TravelerSummaryEntity copyWith({
    int? postsCount,
    int? followersCount,
    int? followingCount,
    bool? isFollowedByCurrentUser,
    bool? isBlockedByCurrentUser,
  }) {
    return TravelerSummaryEntity(
      id: id,
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
      bio: bio,
      homeCity: homeCity,
      homeCountry: homeCountry,
      isPublic: isPublic,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowedByCurrentUser:
          isFollowedByCurrentUser ?? this.isFollowedByCurrentUser,
      isBlockedByCurrentUser:
          isBlockedByCurrentUser ?? this.isBlockedByCurrentUser,
    );
  }
}

/// `public.post_photos` tablosuna karşılık gelen gönderi fotoğrafı varlığı.
@immutable
class PostPhotoEntity {
  /// Gönderi fotoğrafı varlığı oluşturur.
  const PostPhotoEntity({
    required this.id,
    required this.postId,
    required this.storagePath,
    this.signedUrl,
    this.sortOrder = 0,
  });

  /// Fotoğraf kimliği (`post_photos.id`).
  final String id;

  /// Bağlı olduğu gönderi kimliği (`posts.id`).
  final String postId;

  /// `post-photos` bucket içindeki nesne yolu (`userUUID/postUUID/file.ext`).
  final String storagePath;

  /// Görüntüleme için geçici imzalı URL.
  final String? signedUrl;

  /// Sıralama indeksi.
  final int sortOrder;
}

/// `public.comments` tablosuna karşılık gelen gönderi yorumu varlığı.
@immutable
class CommentEntity {
  /// Yorum varlığı oluşturur.
  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.body,
    required this.createdAt,
    this.author,
  });

  /// Yorum kimliği (`comments.id`).
  final String id;

  /// Bağlı olduğu gönderi kimliği (`posts.id`).
  final String postId;

  /// Yorumu yazan kullanıcı kimliği (`auth.uid()`).
  final String userId;

  /// Yorum metni.
  final String body;

  /// Oluşturulma zamanı.
  final DateTime createdAt;

  /// Yorum yazarının özet profili.
  final TravelerSummaryEntity? author;
}

/// `public.posts` tablosuna karşılık gelen topluluk gönderisi domain varlığı.
///
/// Kişisel ziyaret (`visits`) verisinden bağımsızdır; kullanıcı yalnızca açıkça
/// oluşturduğu ve `status = 'published'` yaptığı gönderileri toplulukla paylaşır.
@immutable
class PostEntity {
  /// Topluluk gönderisi varlığı oluşturur.
  const PostEntity({
    required this.id,
    required this.userId,
    required this.caption,
    required this.createdAt,
    this.title,
    this.placeId,
    this.visitId,
    this.tripId,
    this.status = 'published',
    this.author,
    this.place,
    this.photos = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByCurrentUser = false,
    this.isSavedByCurrentUser = false,
  });

  /// Gönderi kimliği (`posts.id`).
  final String id;

  /// Yazar kullanıcı kimliği (`auth.uid()`).
  final String userId;

  /// Gönderi başlığı (varsa).
  final String? title;

  /// Gönderi hikayesi / açıklaması.
  final String caption;

  /// İlişkili mekan kimliği (`places.id`).
  final String? placeId;

  /// Dönüştürüldüğü ziyaret kimliği (`visits.id`, kişisel notlar yine gizli kalır).
  final String? visitId;

  /// İlişkili seyahat planı kimliği (`trips.id`).
  final String? tripId;

  /// Yayın durumu (`draft` veya `published`).
  final String status;

  /// Oluşturulma tarihi.
  final DateTime createdAt;

  /// Yazar profili.
  final TravelerSummaryEntity? author;

  /// İlişkili mekan bilgisi.
  final PlaceEntity? place;

  /// Gönderi fotoğrafları (`post_photos`).
  final List<PostPhotoEntity> photos;

  /// Gerçek beğeni sayısı (`post_likes`).
  final int likeCount;

  /// Gerçek yorum sayısı (`comments`).
  final int commentCount;

  /// Mevcut kullanıcının beğenip beğenmediği.
  final bool isLikedByCurrentUser;

  /// Mevcut kullanıcının kaydedip kaydetmediği (`saved_posts`).
  final bool isSavedByCurrentUser;

  /// Beğeni, kaydetme veya yorum sayısını güncelleyerek yeni örnek döndürür.
  PostEntity copyWith({
    int? likeCount,
    int? commentCount,
    bool? isLikedByCurrentUser,
    bool? isSavedByCurrentUser,
    TravelerSummaryEntity? author,
  }) {
    return PostEntity(
      id: id,
      userId: userId,
      title: title,
      caption: caption,
      placeId: placeId,
      visitId: visitId,
      tripId: tripId,
      status: status,
      createdAt: createdAt,
      author: author ?? this.author,
      place: place,
      photos: photos,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isSavedByCurrentUser: isSavedByCurrentUser ?? this.isSavedByCurrentUser,
    );
  }
}

/// Gönderi fotoğrafı yükleme verisi.
@immutable
class PostPhotoUploadPayload {
  /// Fotoğraf yükleme verisi oluşturur.
  const PostPhotoUploadPayload({
    required this.bytes,
    required this.fileExtension,
  });

  /// Görselin ham baytları (`<= 10 MB`).
  final Uint8List bytes;

  /// Dosya uzantısı (`jpg`, `jpeg`, `png`, `webp`).
  final String fileExtension;
}

/// Yeni topluluk gönderisi oluşturma veya taslak kaydetme isteği.
@immutable
class CreatePostRequest {
  /// Gönderi oluşturma isteği yaratır.
  const CreatePostRequest({
    required this.userId,
    required this.caption,
    this.title,
    this.placeId,
    this.visitId,
    this.tripId,
    this.isDraft = false,
    this.photos = const [],
  });

  /// Yazar kimliği (`auth.uid()`).
  final String userId;

  /// Gönderi başlığı.
  final String? title;

  /// Gönderi metni.
  final String caption;

  /// İsteğe bağlı mekan kimliği.
  final String? placeId;

  /// İsteğe bağlı kaynak ziyaret kimliği.
  final String? visitId;

  /// İsteğe bağlı kaynak seyahat kimliği.
  final String? tripId;

  /// `true` ise `draft`, `false` ise `published` olarak kaydedilir.
  final bool isDraft;

  /// Yüklenecek fotoğraflar.
  final List<PostPhotoUploadPayload> photos;
}
