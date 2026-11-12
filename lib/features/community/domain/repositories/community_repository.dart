import 'package:roamory/features/community/domain/entities/post_entity.dart';

/// Topluluk akışı, gönderi paylaşımı, yorum, beğeni, takip ve güvenlik sözleşmesi.
abstract interface class CommunityRepository {
  /// Topluluk akışındaki yayınlanmış (`status = 'published'`) gönderileri getirir.
  ///
  /// [followingOnly] `true` ise yalnızca aktif kullanıcının takip ettiği gezginlerin
  /// gönderileri listelenir. Engellenen kullanıcılar (`user_blocks`) filtrelenir.
  Future<List<PostEntity>> fetchFeed({
    required String currentUserId,
    bool followingOnly = false,
    String? placeId,
    String? authorId,
    int limit = 20,
    int offset = 0,
  });

  /// Tek bir gönderinin detaylarını getirir.
  Future<PostEntity> fetchPostById({
    required String postId,
    required String currentUserId,
  });

  /// Kullanıcının kaydettiği (`saved_posts`) gönderileri getirir.
  Future<List<PostEntity>> fetchSavedPosts(String currentUserId);

  /// Yeni topluluk gönderisi oluşturur veya taslak olarak kaydeder.
  ///
  /// Fotoğraflar `post-photos` private bucket'ına `userUUID/postUUID/file` olarak
  /// yüklenir; yükleme hatasında yetim dosyalar temizlenir.
  Future<PostEntity> createPost(CreatePostRequest request);

  /// Gönderiyi ve bağlı `post-photos` Storage nesnelerini siler.
  Future<void> deletePost({
    required String postId,
    required String currentUserId,
  });

  /// Gönderi beğenisini açar veya kapatır (`post_likes`) ve güncel gönderiyi döner.
  Future<PostEntity> toggleLike({
    required String postId,
    required String currentUserId,
  });

  /// Gönderiyi kaydedilenlere ekler veya çıkarır (`saved_posts`).
  Future<PostEntity> toggleSavePost({
    required String postId,
    required String currentUserId,
  });

  /// Gönderinin yorumlarını (`comments`) kronolojik olarak getirir.
  Future<List<CommentEntity>> fetchComments(String postId);

  /// Gönderiye yeni yorum ekler.
  Future<CommentEntity> addComment({
    required String postId,
    required String currentUserId,
    required String body,
  });

  /// Kullanıcının kendi yorumunu siler.
  Future<void> deleteComment({
    required String commentId,
    required String currentUserId,
  });

  /// Bir gezginin herkese açık profil özetini ve gerçek istatistiklerini getirir.
  Future<TravelerSummaryEntity> fetchTravelerProfile({
    required String targetUserId,
    required String currentUserId,
  });

  /// Gezginin takipçilerini (`followers`) veya takip ettiklerini (`following`) listeler.
  Future<List<TravelerSummaryEntity>> fetchFollowConnections({
    required String targetUserId,
    required String currentUserId,
    required bool followers,
  });

  /// Gezgini takip eder veya takibi bırakır (`follows`).
  Future<TravelerSummaryEntity> toggleFollow({
    required String targetUserId,
    required String currentUserId,
  });

  /// Kullanıcının engellediği gezginleri (`user_blocks`) listeler.
  Future<List<TravelerSummaryEntity>> fetchBlockedUsers(String currentUserId);

  /// Bir kullanıcıyı engeller (`user_blocks`) ve takip bağını koparır.
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  });

  /// Kullanıcı engelini kaldırır.
  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  });

  /// Uygunsuz gönderi, yorum veya kullanıcıyı moderasyona bildirir (`content_reports`).
  Future<void> reportContent({
    required String reporterUserId,
    required String reason,
    String? targetPostId,
    String? targetCommentId,
    String? targetUserId,
    String? details,
  });
}
