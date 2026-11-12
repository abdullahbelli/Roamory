import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/data/repositories/supabase_community_repository.dart';
import 'package:roamory/features/community/domain/entities/post_entity.dart';

/// Topluluk akışı, gönderi paylaşımı, yorum, takip ve güvenlik durumunu tutar.
@immutable
class CommunityState {
  /// Topluluk durumu oluşturur.
  const CommunityState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.followingOnly = false,
    this.hasMoreFeed = true,
    this.feedPosts = const [],
    this.savedPosts = const [],
    this.blockedUsers = const [],
    this.commentsByPost = const {},
    this.travelerProfiles = const {},
    this.travelerPosts = const {},
    this.postByIdCache = const {},
    this.notFoundPostIds = const {},
    this.error,
  });

  /// Akış yükleniyor mu.
  final bool isLoading;

  /// Sayfalama ile devam gönderileri yükleniyor mu.
  final bool isLoadingMore;

  /// Gönderi/yorum paylaşımı sürüyor mu.
  final bool isSubmitting;

  /// `E01` akış sekmesi (`false`: Keşfet, `true`: Takip Edilenler).
  final bool followingOnly;

  /// Sayfalama ile daha fazla gönderi yüklenip yüklenemeyeceği.
  final bool hasMoreFeed;

  /// Akıştaki yayınlanmış gönderiler (`posts`).
  final List<PostEntity> feedPosts;

  /// Kullanıcının kaydettiği gönderiler (`saved_posts`).
  final List<PostEntity> savedPosts;

  /// Kullanıcının engellediği gezginler (`user_blocks`).
  final List<TravelerSummaryEntity> blockedUsers;

  /// Gönderi kimliğine göre yorum listeleri (`comments`).
  final Map<String, List<CommentEntity>> commentsByPost;

  /// Gezgin kimliğine göre önbelleğe alınmış gezgin profilleri.
  final Map<String, TravelerSummaryEntity> travelerProfiles;

  /// Gezgin profili ekranında (`E05`) doğrudan yüklenen yayınlanmış gönderiler.
  final Map<String, List<PostEntity>> travelerPosts;

  /// Bildirim veya derin bağlantı ile doğrudan açılan gönderi önbelleği (`E03`).
  final Map<String, PostEntity> postByIdCache;

  /// Silinmiş veya engelleme nedeniyle erişilemeyen gönderi kimlikleri.
  final Set<String> notFoundPostIds;

  /// Varsa son işlem hatası.
  final AppException? error;

  /// Kimliğe göre gönderi bulur.
  PostEntity? findPostById(String postId) {
    final cached = postByIdCache[postId];
    if (cached != null) {
      return cached;
    }
    for (final p in feedPosts) {
      if (p.id == postId) {
        return p;
      }
    }
    for (final s in savedPosts) {
      if (s.id == postId) {
        return s;
      }
    }
    for (final list in travelerPosts.values) {
      for (final p in list) {
        if (p.id == postId) {
          return p;
        }
      }
    }
    return null;
  }

  /// Seçili alanları güncelleyerek kopya üretir.
  CommunityState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSubmitting,
    bool? followingOnly,
    bool? hasMoreFeed,
    List<PostEntity>? feedPosts,
    List<PostEntity>? savedPosts,
    List<TravelerSummaryEntity>? blockedUsers,
    Map<String, List<CommentEntity>>? commentsByPost,
    Map<String, TravelerSummaryEntity>? travelerProfiles,
    Map<String, List<PostEntity>>? travelerPosts,
    Map<String, PostEntity>? postByIdCache,
    Set<String>? notFoundPostIds,
    AppException? error,
    bool clearError = false,
  }) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      followingOnly: followingOnly ?? this.followingOnly,
      hasMoreFeed: hasMoreFeed ?? this.hasMoreFeed,
      feedPosts: feedPosts ?? this.feedPosts,
      savedPosts: savedPosts ?? this.savedPosts,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      commentsByPost: commentsByPost ?? this.commentsByPost,
      travelerProfiles: travelerProfiles ?? this.travelerProfiles,
      travelerPosts: travelerPosts ?? this.travelerPosts,
      postByIdCache: postByIdCache ?? this.postByIdCache,
      notFoundPostIds: notFoundPostIds ?? this.notFoundPostIds,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Topluluk ve sosyal ağ işlemlerini yöneten Riverpod Notifier.
class CommunityController extends Notifier<CommunityState> {
  static const int _pageSize = 20;

  /// Çift tıklamada eşzamanlı beğeni/kaydetme yarışını önleyen kilit kümesi.
  final Set<String> _inFlightPostActions = <String>{};

  @override
  CommunityState build() {
    // Oturum değiştiğinde akışı, kaydedilen gönderileri ve engellenenler listesini yeniliyoruz.
    ref.watch(authControllerProvider.select((s) => s.user?.id));
    Future.microtask(loadFeed);
    return const CommunityState(isLoading: true);
  }

  String get _currentUserId => ref.read(authControllerProvider).user?.id ?? '';

  /// Topluluk akışını ve kaydedilen gönderileri yükler (`E01`).
  Future<void> loadFeed({bool? followingOnly}) async {
    final targetFollowing = followingOnly ?? state.followingOnly;
    final userId = _currentUserId;
    state = state.copyWith(
      isLoading: true,
      followingOnly: targetFollowing,
      hasMoreFeed: true,
      clearError: true,
    );

    try {
      final repo = ref.read(communityRepositoryProvider);
      final posts = await repo.fetchFeed(
        currentUserId: userId,
        followingOnly: targetFollowing,
        limit: _pageSize,
        offset: 0,
      );
      if (!ref.mounted) return;
      final saved = userId.isEmpty
          ? const <PostEntity>[]
          : await repo.fetchSavedPosts(userId);
      if (!ref.mounted) return;
      final blocked = userId.isEmpty
          ? const <TravelerSummaryEntity>[]
          : await repo.fetchBlockedUsers(userId);
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        hasMoreFeed: posts.length >= _pageSize,
        feedPosts: posts,
        savedPosts: saved,
        blockedUsers: blocked,
        clearError: true,
      );
    } catch (error, stackTrace) {
      // Asenkron yükleme bitmeden container/sayfa kapanırsa disposed ref yazma hatasını önler.
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: ErrorMapper.map(error, stackTrace),
      );
    }
  }

  /// Sayfalama ile akışın sonraki sayfasını yükler (`E01`).
  Future<void> loadMoreFeed() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMoreFeed) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final repo = ref.read(communityRepositoryProvider);
      final nextPage = await repo.fetchFeed(
        currentUserId: _currentUserId,
        followingOnly: state.followingOnly,
        limit: _pageSize,
        offset: state.feedPosts.length,
      );
      if (!ref.mounted) return;
      final existingIds = state.feedPosts.map((p) => p.id).toSet();
      final merged = [
        ...state.feedPosts,
        ...nextPage.where((p) => !existingIds.contains(p.id)),
      ];
      state = state.copyWith(
        isLoadingMore: false,
        hasMoreFeed: nextPage.length >= _pageSize,
        feedPosts: merged,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        error: ErrorMapper.map(error, stackTrace),
      );
    }
  }

  /// Bildirim veya derin bağlantıdan açılan tekil gönderiyi yükler (`E03`).
  Future<PostEntity?> loadPostById(String postId) async {
    try {
      final post = await ref
          .read(communityRepositoryProvider)
          .fetchPostById(postId: postId, currentUserId: _currentUserId);
      if (!ref.mounted) return post;
      final nextNotFound = {...state.notFoundPostIds}..remove(postId);
      state = state.copyWith(
        postByIdCache: {...state.postByIdCache, postId: post},
        notFoundPostIds: nextNotFound,
        clearError: true,
      );
      _replacePost(post);
      return post;
    } catch (error, stackTrace) {
      if (!ref.mounted) return null;
      final mapped = ErrorMapper.map(error, stackTrace);
      final nextNotFound = mapped is NotFoundAppException
          ? {...state.notFoundPostIds, postId}
          : state.notFoundPostIds;
      state = state.copyWith(notFoundPostIds: nextNotFound, error: mapped);
      return null;
    }
  }

  /// Yeni topluluk gönderisi yayınlar veya taslak olarak kaydeder (`E02`).
  Future<PostEntity?> createPost(CreatePostRequest request) async {
    if (state.isSubmitting) {
      return null;
    }
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final created = await ref
          .read(communityRepositoryProvider)
          .createPost(request);
      if (!ref.mounted) return created;
      final updatedFeed = created.status == 'published'
          ? [created, ...state.feedPosts]
          : state.feedPosts;
      final nextNotFound = {...state.notFoundPostIds}..remove(created.id);
      state = state.copyWith(
        isSubmitting: false,
        feedPosts: updatedFeed,
        postByIdCache: {...state.postByIdCache, created.id: created},
        notFoundPostIds: nextNotFound,
        clearError: true,
      );
      return created;
    } catch (error, stackTrace) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return null;
    }
  }

  /// Gönderiyi siler (`E03`).
  Future<bool> deletePost(String postId) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      return false;
    }
    try {
      await ref
          .read(communityRepositoryProvider)
          .deletePost(postId: postId, currentUserId: userId);
      if (!ref.mounted) return true;
      final nextCache = {...state.postByIdCache}..remove(postId);
      final nextTravelerPosts = {
        for (final entry in state.travelerPosts.entries)
          entry.key: entry.value.where((p) => p.id != postId).toList(),
      };
      state = state.copyWith(
        feedPosts: state.feedPosts.where((p) => p.id != postId).toList(),
        savedPosts: state.savedPosts.where((p) => p.id != postId).toList(),
        postByIdCache: nextCache,
        travelerPosts: nextTravelerPosts,
        notFoundPostIds: {...state.notFoundPostIds, postId},
        clearError: true,
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Gönderiyi beğenir veya beğeniyi geri alır (`E01`, `E03`).
  Future<void> toggleLike(String postId) async {
    final userId = _currentUserId;
    final lockKey = 'like:$postId';
    if (userId.isEmpty || _inFlightPostActions.contains(lockKey)) {
      return;
    }
    _inFlightPostActions.add(lockKey);
    try {
      final updated = await ref
          .read(communityRepositoryProvider)
          .toggleLike(postId: postId, currentUserId: userId);
      if (!ref.mounted) return;
      _replacePost(updated);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
    } finally {
      _inFlightPostActions.remove(lockKey);
    }
  }

  /// Gönderiyi kaydedilenlere ekler veya çıkarır (`E01`, `E03`).
  Future<void> toggleSavePost(String postId) async {
    final userId = _currentUserId;
    final lockKey = 'save:$postId';
    if (userId.isEmpty || _inFlightPostActions.contains(lockKey)) {
      return;
    }
    _inFlightPostActions.add(lockKey);
    try {
      final updated = await ref
          .read(communityRepositoryProvider)
          .toggleSavePost(postId: postId, currentUserId: userId);
      if (!ref.mounted) return;
      _replacePost(updated);
      final savedList = updated.isSavedByCurrentUser
          ? [updated, ...state.savedPosts.where((p) => p.id != postId)]
          : state.savedPosts.where((p) => p.id != postId).toList();
      state = state.copyWith(savedPosts: savedList, clearError: true);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
    } finally {
      _inFlightPostActions.remove(lockKey);
    }
  }

  /// Belirli bir gönderinin yorumlarını yükler (`E04`).
  Future<void> loadComments(String postId) async {
    try {
      final list = await ref
          .read(communityRepositoryProvider)
          .fetchComments(postId);
      if (!ref.mounted) return;
      state = state.copyWith(
        commentsByPost: {...state.commentsByPost, postId: list},
        clearError: true,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
    }
  }

  /// Gönderiye yeni yorum yazar (`E04`).
  Future<bool> addComment({
    required String postId,
    required String body,
  }) async {
    final userId = _currentUserId;
    if (userId.isEmpty || body.trim().isEmpty || state.isSubmitting) {
      return false;
    }
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final comment = await ref
          .read(communityRepositoryProvider)
          .addComment(postId: postId, currentUserId: userId, body: body);
      if (!ref.mounted) return true;
      final currentList = state.commentsByPost[postId] ?? const [];
      final newComments = [...currentList, comment];
      final post = state.findPostById(postId);
      if (post != null) {
        _replacePost(post.copyWith(commentCount: post.commentCount + 1));
      }
      state = state.copyWith(
        isSubmitting: false,
        commentsByPost: {...state.commentsByPost, postId: newComments},
        clearError: true,
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSubmitting: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return false;
    }
  }

  /// Kullanıcının kendi yorumunu siler ve gönderinin yorum sayacını azaltır (`E04`).
  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      return false;
    }
    try {
      await ref
          .read(communityRepositoryProvider)
          .deleteComment(commentId: commentId, currentUserId: userId);
      if (!ref.mounted) return true;
      final currentList = state.commentsByPost[postId] ?? const [];
      final post = state.findPostById(postId);
      if (post != null) {
        _replacePost(
          post.copyWith(
            commentCount: post.commentCount > 0 ? post.commentCount - 1 : 0,
          ),
        );
      }
      state = state.copyWith(
        commentsByPost: {
          ...state.commentsByPost,
          postId: currentList.where((c) => c.id != commentId).toList(),
        },
        clearError: true,
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Gezgin profilini, gerçek istatistiklerini ve yayınlanmış gönderilerini yükler (`E05`).
  Future<TravelerSummaryEntity?> loadTravelerProfile(
    String targetUserId,
  ) async {
    final userId = _currentUserId;
    try {
      final repo = ref.read(communityRepositoryProvider);
      final profile = await repo.fetchTravelerProfile(
        targetUserId: targetUserId,
        currentUserId: userId,
      );
      if (!ref.mounted) return profile;
      final posts = profile.isBlockedByCurrentUser
          ? const <PostEntity>[]
          : await repo.fetchFeed(
              currentUserId: userId,
              authorId: targetUserId,
              limit: 20,
              offset: 0,
            );
      if (!ref.mounted) return profile;
      state = state.copyWith(
        travelerProfiles: {...state.travelerProfiles, targetUserId: profile},
        travelerPosts: {...state.travelerPosts, targetUserId: posts},
        clearError: true,
      );
      return profile;
    } catch (error, stackTrace) {
      if (!ref.mounted) return null;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return null;
    }
  }

  /// Gezgini takip eder veya takibi bırakır (`E05`, `E06`).
  Future<void> toggleFollow(String targetUserId) async {
    final userId = _currentUserId;
    final lockKey = 'follow:$targetUserId';
    if (userId.isEmpty ||
        targetUserId == userId ||
        _inFlightPostActions.contains(lockKey)) {
      return;
    }
    _inFlightPostActions.add(lockKey);
    try {
      final updated = await ref
          .read(communityRepositoryProvider)
          .toggleFollow(targetUserId: targetUserId, currentUserId: userId);
      if (!ref.mounted) return;
      state = state.copyWith(
        travelerProfiles: {...state.travelerProfiles, targetUserId: updated},
        clearError: true,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
    } finally {
      _inFlightPostActions.remove(lockKey);
    }
  }

  /// Bir kullanıcıyı engeller; gönderilerini ve yorumlarını akıştan hemen kaldırır (`T16`).
  Future<bool> blockUser(String blockedUserId) async {
    final userId = _currentUserId;
    if (userId.isEmpty || userId == blockedUserId) {
      return false;
    }
    try {
      final repo = ref.read(communityRepositoryProvider);
      await repo.blockUser(currentUserId: userId, blockedUserId: blockedUserId);
      final blockedList = await repo.fetchBlockedUsers(userId);
      if (!ref.mounted) return true;

      final nextComments = <String, List<CommentEntity>>{
        for (final entry in state.commentsByPost.entries)
          entry.key: entry.value
              .where((c) => c.userId != blockedUserId)
              .toList(),
      };
      final nextCache = <String, PostEntity>{
        for (final entry in state.postByIdCache.entries)
          if (entry.value.userId != blockedUserId) entry.key: entry.value,
      };
      final existingProfile = state.travelerProfiles[blockedUserId];
      final nextProfiles = existingProfile == null
          ? state.travelerProfiles
          : {
              ...state.travelerProfiles,
              blockedUserId: existingProfile.copyWith(
                isBlockedByCurrentUser: true,
                isFollowedByCurrentUser: false,
              ),
            };
      final nextTravelerPosts = {...state.travelerPosts}..remove(blockedUserId);

      state = state.copyWith(
        feedPosts: state.feedPosts
            .where((p) => p.userId != blockedUserId)
            .toList(),
        savedPosts: state.savedPosts
            .where((p) => p.userId != blockedUserId)
            .toList(),
        blockedUsers: blockedList,
        commentsByPost: nextComments,
        postByIdCache: nextCache,
        travelerProfiles: nextProfiles,
        travelerPosts: nextTravelerPosts,
        clearError: true,
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Engellenen kullanıcının engelini kaldırır ve akışı günceller (`F04`).
  Future<void> unblockUser(String blockedUserId) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      return;
    }
    try {
      await ref
          .read(communityRepositoryProvider)
          .unblockUser(currentUserId: userId, blockedUserId: blockedUserId);
      if (!ref.mounted) return;
      final existingProfile = state.travelerProfiles[blockedUserId];
      final nextProfiles = existingProfile == null
          ? state.travelerProfiles
          : {
              ...state.travelerProfiles,
              blockedUserId: existingProfile.copyWith(
                isBlockedByCurrentUser: false,
              ),
            };
      state = state.copyWith(
        blockedUsers: state.blockedUsers
            .where((u) => u.id != blockedUserId)
            .toList(),
        travelerProfiles: nextProfiles,
        clearError: true,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
    }
  }

  /// Gönderi, yorum veya kullanıcıyı bildirir (`content_reports`).
  Future<bool> reportContent({
    required String reason,
    String? targetPostId,
    String? targetCommentId,
    String? targetUserId,
    String? details,
  }) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      return false;
    }
    try {
      await ref
          .read(communityRepositoryProvider)
          .reportContent(
            reporterUserId: userId,
            reason: reason,
            targetPostId: targetPostId,
            targetCommentId: targetCommentId,
            targetUserId: targetUserId,
            details: details,
          );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  void _replacePost(PostEntity updated) {
    final nextCache = state.postByIdCache.containsKey(updated.id)
        ? {...state.postByIdCache, updated.id: updated}
        : state.postByIdCache;
    final nextTravelerPosts = {
      for (final entry in state.travelerPosts.entries)
        entry.key: entry.value
            .map((p) => p.id == updated.id ? updated : p)
            .toList(),
    };
    state = state.copyWith(
      feedPosts: state.feedPosts
          .map((p) => p.id == updated.id ? updated : p)
          .toList(),
      savedPosts: state.savedPosts
          .map((p) => p.id == updated.id ? updated : p)
          .toList(),
      postByIdCache: nextCache,
      travelerPosts: nextTravelerPosts,
      clearError: true,
    );
  }
}

/// Topluluk durumunu sunan Riverpod sağlayıcısı.
final communityControllerProvider =
    NotifierProvider<CommunityController, CommunityState>(
      CommunityController.new,
    );
