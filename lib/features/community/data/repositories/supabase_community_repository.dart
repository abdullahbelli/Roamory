import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/features/community/domain/entities/post_entity.dart';
import 'package:roamory/features/community/domain/repositories/community_repository.dart';
import 'package:roamory/features/explore/data/repositories/supabase_explore_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// [CommunityRepository] sözleşmesinin Supabase `posts`, `post_photos`,
/// `post_likes`, `comments`, `follows`, `saved_posts`, `user_blocks` ve
/// `content_reports` implementasyonu.
///
/// Engelleme (`user_blocks`), gizlilik (`status = 'published'`) ve yetim dosya
/// temizleme (`post-photos` Storage) kurallarına sıkı biçimde uyar.
class SupabaseCommunityRepository implements CommunityRepository {
  /// Supabase istemcisiyle repository oluşturur.
  const SupabaseCommunityRepository(this._client);

  /// `post-photos` private bucket maksimum dosya boyutu (`10 MB`).
  static const int maxPostPhotoBytes = 10 * 1024 * 1024;

  static const Set<String> _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  final sb.SupabaseClient? _client;

  sb.SupabaseClient get _requireClient {
    final client = _client;
    if (client == null) {
      throw const SupabaseNotConfiguredException();
    }
    return client;
  }

  @override
  Future<List<PostEntity>> fetchFeed({
    required String currentUserId,
    bool followingOnly = false,
    String? placeId,
    String? authorId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final client = _requireClient;

      // Engellenen kullanıcıların gönderilerini istemci katmanında da ek olarak süzüyoruz.
      final blockedIds = await _fetchBlockedIds(currentUserId);
      if (authorId != null &&
          authorId.isNotEmpty &&
          blockedIds.contains(authorId)) {
        return const [];
      }

      Set<String>? followedIds;
      if (followingOnly) {
        final followRows = await client
            .from('follows')
            .select('following_id')
            .eq('follower_id', currentUserId);
        followedIds = (followRows as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((r) => (r['following_id'] ?? '').toString())
            .where((id) => id.isNotEmpty)
            .toSet();
        if (followedIds.isEmpty) {
          return const [];
        }
      }

      // posts ile profiles arasında hem doğrudan (posts_user_id_fkey) hem de
      // post_likes / saved_posts üzerinden çoka-çok ilişki bulunduğu için
      // PostgREST PGRST201 belirsizliğini önlemek adına ilişkiyi açıkça belirtiyoruz.
      var query = client
          .from('posts')
          .select(
            '*, profiles!posts_user_id_fkey(*), places(*, categories(slug)), post_photos(*), post_likes(user_id), comments(id), saved_posts(user_id)',
          )
          .eq('status', 'published');

      if (placeId != null && placeId.isNotEmpty) {
        query = query.eq('place_id', placeId);
      }
      if (authorId != null && authorId.isNotEmpty) {
        query = query.eq('user_id', authorId);
      }

      final safeOffset = offset < 0 ? 0 : offset;
      final ordered = query.order('created_at', ascending: false);
      final rows = limit > 0
          ? await ordered.range(safeOffset, safeOffset + limit - 1)
          : await ordered;
      final posts = <PostEntity>[];

      for (final raw in rows as List<dynamic>) {
        if (raw is! Map<String, dynamic>) {
          continue;
        }
        final postOwnerId = (raw['user_id'] ?? '').toString();
        if (blockedIds.contains(postOwnerId)) {
          continue;
        }
        if (followedIds != null && !followedIds.contains(postOwnerId)) {
          continue;
        }
        posts.add(await _mapPostRowWithSignedUrls(raw, currentUserId));
      }
      return posts;
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<PostEntity> fetchPostById({
    required String postId,
    required String currentUserId,
  }) async {
    try {
      final row = await _requireClient
          .from('posts')
          .select(
            '*, profiles!posts_user_id_fkey(*), places(*, categories(slug)), post_photos(*), post_likes(user_id), comments(id), saved_posts(user_id)',
          )
          .eq('id', postId)
          .maybeSingle();

      if (row == null) {
        throw const NotFoundAppException(code: 'post_not_found');
      }

      final postOwnerId = (row['user_id'] ?? '').toString();
      final status = (row['status'] ?? 'published').toString();
      // Başkasının taslağı veya engellenmiş kullanıcının gönderisi doğrudan ID
      // ile (ör. eski bildirim bağlantısından) açılsa bile gizlenir.
      if (status != 'published' && postOwnerId != currentUserId) {
        throw const NotFoundAppException(code: 'post_not_found');
      }
      final blockedIds = await _fetchBlockedIds(currentUserId);
      if (blockedIds.contains(postOwnerId)) {
        throw const NotFoundAppException(code: 'post_not_found');
      }

      return await _mapPostRowWithSignedUrls(row, currentUserId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<List<PostEntity>> fetchSavedPosts(String currentUserId) async {
    try {
      final blockedIds = await _fetchBlockedIds(currentUserId);
      final rows = await _requireClient
          .from('saved_posts')
          .select(
            'posts(*, profiles!posts_user_id_fkey(*), places(*, categories(slug)), post_photos(*), post_likes(user_id), comments(id), saved_posts(user_id))',
          )
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      final result = <PostEntity>[];
      for (final r in rows as List<dynamic>) {
        if (r is Map<String, dynamic> && r['posts'] is Map<String, dynamic>) {
          final postMap = r['posts'] as Map<String, dynamic>;
          final postOwnerId = (postMap['user_id'] ?? '').toString();
          final status = (postMap['status'] ?? 'published').toString();
          if (blockedIds.contains(postOwnerId)) {
            continue;
          }
          if (status != 'published' && postOwnerId != currentUserId) {
            continue;
          }
          result.add(await _mapPostRowWithSignedUrls(postMap, currentUserId));
        }
      }
      return result;
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<PostEntity> createPost(CreatePostRequest request) async {
    final uploadedPaths = <String>[];
    try {
      if (request.caption.trim().isEmpty &&
          (request.title == null || request.title!.trim().isEmpty)) {
        throw const ValidationAppException(code: 'post_caption_required');
      }

      final client = _requireClient;
      final sessionUserId = client.auth.currentUser?.id;
      if (sessionUserId == null || sessionUserId.isEmpty) {
        throw const UnauthorizedAppException(code: 'auth_session_missing');
      }
      if (sessionUserId != request.userId) {
        throw const UnauthorizedAppException(code: 'auth_uid_mismatch');
      }

      final trimmedTitle = request.title?.trim() ?? '';
      final trimmedCaption = request.caption.trim();
      // Canlı `posts` şemasında metin kolonu `caption` olarak tanımlıdır;
      // başlık girildiyse açıklama metniyle birleştirilerek kaydedilir.
      final combinedCaption =
          trimmedTitle.isNotEmpty && trimmedCaption.isNotEmpty
          ? '$trimmedTitle\n\n$trimmedCaption'
          : (trimmedCaption.isNotEmpty ? trimmedCaption : trimmedTitle);

      final inserted = await client
          .from('posts')
          .insert({
            'user_id': request.userId,
            'caption': combinedCaption,
            if (request.placeId != null) 'place_id': request.placeId,
            'status': request.isDraft ? 'draft' : 'published',
          })
          .select('id')
          .single();

      final postId = inserted['id'].toString();

      for (var i = 0; i < request.photos.length; i++) {
        final photo = request.photos[i];
        final ext = photo.fileExtension.trim().toLowerCase();
        if (!_allowedExtensions.contains(ext)) {
          throw const ValidationAppException(code: 'invalid_photo_format');
        }
        if (photo.bytes.lengthInBytes > maxPostPhotoBytes) {
          throw const ValidationAppException(code: 'post_photo_too_large');
        }
        final mimeType = switch (ext) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          _ => 'image/jpeg',
        };
        final path =
            '${request.userId}/$postId/photo_${DateTime.now().millisecondsSinceEpoch}_$i.$ext';

        await client.storage
            .from('post-photos')
            .uploadBinary(
              path,
              photo.bytes,
              fileOptions: sb.FileOptions(contentType: mimeType, upsert: true),
            );
        uploadedPaths.add(path);

        await client.from('post_photos').insert({
          'post_id': postId,
          'storage_path': path,
          'sort_order': i,
        });
      }

      return await fetchPostById(postId: postId, currentUserId: request.userId);
    } catch (error, stackTrace) {
      if (uploadedPaths.isNotEmpty && _client != null) {
        try {
          await _client.storage.from('post-photos').remove(uploadedPaths);
        } catch (_) {}
      }
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> deletePost({
    required String postId,
    required String currentUserId,
  }) async {
    try {
      final client = _requireClient;
      final sessionUserId = client.auth.currentUser?.id;
      if (sessionUserId == null || sessionUserId != currentUserId) {
        throw const UnauthorizedAppException(code: 'auth_uid_mismatch');
      }

      // Önce gönderinin bu kullanıcıya ait olduğunu doğruluyoruz ki başkasının
      // gönderisine ait Storage yollarına dokunulmasın.
      final postOwnerRow = await client
          .from('posts')
          .select('id, user_id')
          .eq('id', postId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (postOwnerRow == null) {
        throw const NotFoundAppException(code: 'post_not_found');
      }

      final photoRows = await client
          .from('post_photos')
          .select('storage_path')
          .eq('post_id', postId);

      final paths = (photoRows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => e['storage_path']?.toString())
          .whereType<String>()
          .where((p) => p.isNotEmpty)
          .toList();

      await client
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', currentUserId);

      if (paths.isNotEmpty) {
        try {
          await client.storage.from('post-photos').remove(paths);
        } catch (_) {
          // Veritabanı kaydı silindikten sonra Storage temizliği best-effort yapılır.
        }
      }
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<PostEntity> toggleLike({
    required String postId,
    required String currentUserId,
  }) async {
    try {
      final client = _requireClient;
      final existing = await client
          .from('post_likes')
          .select('post_id')
          .eq('post_id', postId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existing != null) {
        await client
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUserId);
      } else {
        await client.from('post_likes').insert({
          'post_id': postId,
          'user_id': currentUserId,
        });
      }

      return await fetchPostById(postId: postId, currentUserId: currentUserId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<PostEntity> toggleSavePost({
    required String postId,
    required String currentUserId,
  }) async {
    try {
      final client = _requireClient;
      final existing = await client
          .from('saved_posts')
          .select('post_id')
          .eq('post_id', postId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existing != null) {
        await client
            .from('saved_posts')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUserId);
      } else {
        await client.from('saved_posts').insert({
          'post_id': postId,
          'user_id': currentUserId,
        });
      }

      return await fetchPostById(postId: postId, currentUserId: currentUserId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<List<CommentEntity>> fetchComments(String postId) async {
    try {
      final client = _requireClient;
      final sessionUserId = client.auth.currentUser?.id ?? '';
      final blockedIds = await _fetchBlockedIds(sessionUserId);

      final rows = await client
          .from('comments')
          .select('*, profiles(*)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      return (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(mapCommentRow)
          .where((c) => !blockedIds.contains(c.userId))
          .toList();
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<CommentEntity> addComment({
    required String postId,
    required String currentUserId,
    required String body,
  }) async {
    try {
      if (body.trim().isEmpty) {
        throw const ValidationAppException(code: 'comment_body_required');
      }
      // Canlı `comments` tablosunda yorum metni `content` kolonu olarak tanımlıdır.
      final row = await _requireClient
          .from('comments')
          .insert({
            'post_id': postId,
            'user_id': currentUserId,
            'content': body.trim(),
          })
          .select('*, profiles(*)')
          .single();

      return mapCommentRow(row);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> deleteComment({
    required String commentId,
    required String currentUserId,
  }) async {
    try {
      await _requireClient
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', currentUserId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<TravelerSummaryEntity> fetchTravelerProfile({
    required String targetUserId,
    required String currentUserId,
  }) async {
    try {
      final client = _requireClient;
      final profileRow = await client
          .from('profiles')
          .select()
          .eq('id', targetUserId)
          .maybeSingle();

      if (profileRow == null) {
        throw const NotFoundAppException(code: 'traveler_not_found');
      }

      final postsRows = await client
          .from('posts')
          .select('id')
          .eq('user_id', targetUserId)
          .eq('status', 'published');
      final followersRows = await client
          .from('follows')
          .select('follower_id')
          .eq('following_id', targetUserId);
      final followingRows = await client
          .from('follows')
          .select('following_id')
          .eq('follower_id', targetUserId);

      final followerIds = (followersRows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => (e['follower_id'] ?? '').toString())
          .toSet();

      final blockedIds = await _fetchBlockedIds(currentUserId);

      return mapTravelerRow(
        profileRow,
        postsCount: (postsRows as List<dynamic>).length,
        followersCount: followerIds.length,
        followingCount: (followingRows as List<dynamic>).length,
        isFollowedByCurrentUser: followerIds.contains(currentUserId),
        isBlockedByCurrentUser: blockedIds.contains(targetUserId),
      );
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<List<TravelerSummaryEntity>> fetchFollowConnections({
    required String targetUserId,
    required String currentUserId,
    required bool followers,
  }) async {
    try {
      final client = _requireClient;
      final columnToSelect = followers ? 'follower_id' : 'following_id';
      final filterColumn = followers ? 'following_id' : 'follower_id';

      final rows = await client
          .from('follows')
          .select(columnToSelect)
          .eq(filterColumn, targetUserId);

      final ids = (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((r) => (r[columnToSelect] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toList();

      if (ids.isEmpty) {
        return const [];
      }

      final result = <TravelerSummaryEntity>[];
      for (final id in ids) {
        try {
          result.add(
            await fetchTravelerProfile(
              targetUserId: id,
              currentUserId: currentUserId,
            ),
          );
        } catch (_) {}
      }
      return result;
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<TravelerSummaryEntity> toggleFollow({
    required String targetUserId,
    required String currentUserId,
  }) async {
    try {
      if (targetUserId == currentUserId) {
        throw const ValidationAppException(code: 'cannot_follow_self');
      }
      final client = _requireClient;
      final existing = await client
          .from('follows')
          .select('follower_id')
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId)
          .maybeSingle();

      if (existing != null) {
        await client
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('following_id', targetUserId);
      } else {
        await client.from('follows').insert({
          'follower_id': currentUserId,
          'following_id': targetUserId,
        });
      }

      return await fetchTravelerProfile(
        targetUserId: targetUserId,
        currentUserId: currentUserId,
      );
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<List<TravelerSummaryEntity>> fetchBlockedUsers(
    String currentUserId,
  ) async {
    try {
      final client = _requireClient;
      final rows = await client
          .from('user_blocks')
          .select('blocked_id')
          .eq('blocker_id', currentUserId);

      final ids = (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((r) => (r['blocked_id'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toList();

      final list = <TravelerSummaryEntity>[];
      for (final id in ids) {
        final pRow = await client
            .from('profiles')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (pRow != null) {
          list.add(mapTravelerRow(pRow, isBlockedByCurrentUser: true));
        } else {
          list.add(
            TravelerSummaryEntity(
              id: id,
              username: id.substring(0, id.length.clamp(0, 8)),
              fullName: 'Gezgin',
              isBlockedByCurrentUser: true,
            ),
          );
        }
      }
      return list;
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    try {
      if (currentUserId == blockedUserId) {
        throw const ValidationAppException(code: 'cannot_block_self');
      }
      final client = _requireClient;
      await client.from('user_blocks').upsert({
        'blocker_id': currentUserId,
        'blocked_id': blockedUserId,
      }, onConflict: 'blocker_id,blocked_id');
      // Engellenen kullanıcıyla olan mevcut takip ilişkisini her iki yönde de temizliyoruz.
      try {
        await client
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('following_id', blockedUserId);
      } catch (_) {}
      try {
        await client
            .from('follows')
            .delete()
            .eq('follower_id', blockedUserId)
            .eq('following_id', currentUserId);
      } catch (_) {}
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    try {
      await _requireClient
          .from('user_blocks')
          .delete()
          .eq('blocker_id', currentUserId)
          .eq('blocked_id', blockedUserId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> reportContent({
    required String reporterUserId,
    required String reason,
    String? targetPostId,
    String? targetCommentId,
    String? targetUserId,
    String? details,
  }) async {
    try {
      if (reason.trim().isEmpty) {
        throw const ValidationAppException(code: 'report_reason_required');
      }
      // Canlı `content_reports` tablosunda açıklama alanı `description` kolonu olarak tanımlıdır.
      await _requireClient.from('content_reports').insert({
        'reporter_id': reporterUserId,
        'reason': reason.trim(),
        'post_id': ?targetPostId,
        'comment_id': ?targetCommentId,
        'reported_user_id': ?targetUserId,
        if (details != null && details.trim().isNotEmpty)
          'description': details.trim(),
      });
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  Future<Set<String>> _fetchBlockedIds(String currentUserId) async {
    if (currentUserId.isEmpty || _client == null) {
      return const {};
    }
    try {
      final rows = await _client
          .from('user_blocks')
          .select('blocked_id, blocker_id')
          .or('blocker_id.eq.$currentUserId,blocked_id.eq.$currentUserId');
      final set = <String>{};
      for (final r
          in (rows as List<dynamic>).whereType<Map<String, dynamic>>()) {
        final b1 = (r['blocked_id'] ?? '').toString();
        final b2 = (r['blocker_id'] ?? '').toString();
        if (b1.isNotEmpty && b1 != currentUserId) {
          set.add(b1);
        }
        if (b2.isNotEmpty && b2 != currentUserId) {
          set.add(b2);
        }
      }
      return set;
    } catch (_) {
      return const {};
    }
  }

  Future<PostEntity> _mapPostRowWithSignedUrls(
    Map<String, dynamic> row,
    String currentUserId,
  ) async {
    final authorRaw = row['profiles'];
    final author = authorRaw is Map<String, dynamic>
        ? mapTravelerRow(authorRaw)
        : null;

    final placeRaw = row['places'];
    final place = placeRaw is Map<String, dynamic>
        ? SupabaseExploreRepository.mapPlaceRow(placeRaw)
        : null;

    final photosRaw = row['post_photos'];
    final photos = <PostPhotoEntity>[];
    if (photosRaw is List<dynamic>) {
      for (final p in photosRaw.whereType<Map<String, dynamic>>()) {
        final storagePath = (p['storage_path'] ?? '').toString();
        String? signedUrl = p['signed_url'] as String?;
        if (signedUrl == null && storagePath.isNotEmpty && _client != null) {
          try {
            signedUrl = await _client.storage
                .from('post-photos')
                .createSignedUrl(storagePath, 3600);
          } catch (_) {}
        }
        photos.add(
          PostPhotoEntity(
            id: (p['id'] ?? '').toString(),
            postId: (p['post_id'] ?? row['id'] ?? '').toString(),
            storagePath: storagePath,
            signedUrl: signedUrl,
            sortOrder: (p['sort_order'] as num?)?.toInt() ?? 0,
          ),
        );
      }
      photos.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    final likesRaw = row['post_likes'];
    var likeCount = (row['like_count'] as num?)?.toInt() ?? 0;
    var isLiked = false;
    if (likesRaw is List<dynamic>) {
      likeCount = likesRaw.length;
      isLiked = likesRaw.whereType<Map<String, dynamic>>().any(
        (l) => (l['user_id'] ?? '').toString() == currentUserId,
      );
    }

    final commentsRaw = row['comments'];
    var commentCount = (row['comment_count'] as num?)?.toInt() ?? 0;
    if (commentsRaw is List<dynamic>) {
      commentCount = commentsRaw.length;
    }

    final savedRaw = row['saved_posts'];
    var isSaved = false;
    if (savedRaw is List<dynamic>) {
      isSaved = savedRaw.whereType<Map<String, dynamic>>().any(
        (s) => (s['user_id'] ?? '').toString() == currentUserId,
      );
    }

    return PostEntity(
      id: (row['id'] ?? '').toString(),
      userId: (row['user_id'] ?? '').toString(),
      title: row['title'] as String?,
      caption: (row['caption'] ?? row['body'] ?? '').toString(),
      placeId: row['place_id']?.toString(),
      visitId: row['visit_id']?.toString(),
      tripId: row['trip_id']?.toString(),
      status: (row['status'] as String?) ?? 'published',
      createdAt:
          DateTime.tryParse((row['created_at'] ?? '').toString()) ??
          DateTime.now(),
      author: author,
      place: place,
      photos: photos,
      likeCount: likeCount,
      commentCount: commentCount,
      isLikedByCurrentUser: isLiked,
      isSavedByCurrentUser: isSaved,
    );
  }

  /// Supabase `profiles` satırını [TravelerSummaryEntity] varlığına dönüştürür.
  static TravelerSummaryEntity mapTravelerRow(
    Map<String, dynamic> row, {
    int postsCount = 0,
    int followersCount = 0,
    int followingCount = 0,
    bool isFollowedByCurrentUser = false,
    bool isBlockedByCurrentUser = false,
  }) {
    return TravelerSummaryEntity(
      id: (row['id'] ?? '').toString(),
      username: (row['username'] ?? 'gezgin').toString(),
      fullName: (row['full_name'] ?? row['username'] ?? 'Gezgin').toString(),
      avatarUrl: row['avatar_url'] as String?,
      bio: row['bio'] as String?,
      homeCity: row['home_city'] as String?,
      homeCountry: row['home_country'] as String?,
      isPublic: (row['is_public'] as bool?) ?? true,
      postsCount: postsCount,
      followersCount: followersCount,
      followingCount: followingCount,
      isFollowedByCurrentUser: isFollowedByCurrentUser,
      isBlockedByCurrentUser: isBlockedByCurrentUser,
    );
  }

  /// Supabase `comments` satırını [CommentEntity] varlığına dönüştürür.
  static CommentEntity mapCommentRow(Map<String, dynamic> row) {
    final authorRaw = row['profiles'];
    final author = authorRaw is Map<String, dynamic>
        ? mapTravelerRow(authorRaw)
        : null;

    return CommentEntity(
      id: (row['id'] ?? '').toString(),
      postId: (row['post_id'] ?? '').toString(),
      userId: (row['user_id'] ?? '').toString(),
      body: (row['body'] ?? row['content'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((row['created_at'] ?? '').toString()) ??
          DateTime.now(),
      author: author,
    );
  }
}

/// Uygulama genelinde kullanılan [CommunityRepository] bağımlılık sağlayıcısı.
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseCommunityRepository(client);
});
