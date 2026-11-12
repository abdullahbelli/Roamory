import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/utils/app_date_formatter.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/domain/entities/post_entity.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/community/presentation/widgets/report_content_sheet.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_network_image.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Topluluk Akışı Ekranı (`E01` — Stitch `3264034a2de2418daacdedf1528a8f6f`
/// ve `S02` Akış İskeleti — Stitch `de101723bb3641aebad0490183231ede`).
///
/// Yalnızca bilinçli olarak yayınlanmış (`status = 'published'`) ve engellenmemiş
/// gezgin gönderilerini listeler. `Keşfet` ve `Takip Edilenler` sekmelerini,
/// gerçek beğeni (`post_likes`), yorum (`comments`) ve kaydetme (`saved_posts`)
/// sayaçlarını gösterir; uydurma "Hikaye Paylaş / Stories" şeridi veya sahte
/// sosyal sayaç içermez.
class CommunityFeedScreen extends ConsumerWidget {
  /// Topluluk akışı ekranı oluşturur.
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(communityControllerProvider);
    final notifier = ref.read(communityControllerProvider.notifier);

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(l10n.navCommunity),
        actions: [
          FilledButton.tonalIcon(
            onPressed: () => context.push(AppRoutes.postCreate),
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: Text(l10n.communityCreatePostButton),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // Keşfet / Takip Edilenler sekme seçicisi.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
              vertical: AppSpacing.xs,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  ChoiceChip(
                    label: Text(l10n.communityFeedExploreTab),
                    selected: !state.followingOnly,
                    onSelected: (_) => notifier.loadFeed(followingOnly: false),
                  ),
                  ChoiceChip(
                    label: Text(l10n.communityFeedFollowingTab),
                    selected: state.followingOnly,
                    onSelected: (_) => notifier.loadFeed(followingOnly: true),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const LoadingSkeleton(itemCount: 3)
                : state.feedPosts.isEmpty
                ? RefreshIndicator(
                    onRefresh: () => notifier.loadFeed(),
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: EmptyState(
                            icon: Icons.public_outlined,
                            title: l10n.emptyDefaultTitle,
                            message: state.followingOnly
                                ? l10n.communityEmptyFollowing
                                : l10n.communityEmptyExplore,
                            actionLabel: l10n.communityCreatePostButton,
                            onAction: () => context.push(AppRoutes.postCreate),
                          ),
                        ),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => notifier.loadFeed(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageMargin,
                        AppSpacing.sm,
                        AppSpacing.pageMargin,
                        AppSpacing.bottomNavHeight + AppSpacing.xl * 2,
                      ),
                      itemCount: state.hasMoreFeed
                          ? state.feedPosts.length + 1
                          : state.feedPosts.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        if (index >= state.feedPosts.length) {
                          return Center(
                            child: state.isLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(AppSpacing.md),
                                    child: CircularProgressIndicator.adaptive(),
                                  )
                                : TextButton.icon(
                                    onPressed: notifier.loadMoreFeed,
                                    icon: const Icon(Icons.expand_more_rounded),
                                    label: Text(l10n.commonSeeAll),
                                  ),
                          );
                        }
                        final post = state.feedPosts[index];
                        return CommunityPostCard(post: post);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Topluluk akışında ve detaylarda kullanılan gönderi kartı.
class CommunityPostCard extends ConsumerWidget {
  /// Gönderi kartı oluşturur; [isDetail] `true` ise tam hikaye ve tüm fotoğraflar gösterilir.
  const CommunityPostCard({
    super.key,
    required this.post,
    this.isDetail = false,
  });

  /// Gösterilecek gönderi varlığı.
  final PostEntity post;

  /// Gönderi detayı (`E03`) görünümünde metin kısaltmasını ve fotoğraf sınırını kaldırır.
  final bool isDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final notifier = ref.read(communityControllerProvider.notifier);
    final currentUserId = ref.watch(authControllerProvider).user?.id;
    final isOwner = currentUserId != null && currentUserId == post.userId;
    final avatarUrl = post.author?.avatarUrl?.trim();

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yazar satırı ve güvenlik menüsü (başka kullanıcıysa Bildir / Engelle).
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () =>
                      context.push(AppRoutes.travelerProfilePath(post.userId)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: colors.primaryContainer,
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? ClipOval(
                                child: AppNetworkImage(
                                  imageUrl: avatarUrl,
                                  width: 36,
                                  height: 36,
                                  borderRadius: 18,
                                  placeholderIcon: Icons.person_outline_rounded,
                                ),
                              )
                            : Icon(
                                Icons.person_outline_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.author?.fullName ?? 'Gezgin',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelLarge,
                            ),
                            Text(
                              '@${post.author?.username ?? 'roamory'} • ${AppDateFormatter.format(context, post.createdAt)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'report') {
                      await showReportContentSheet(
                        context,
                        targetPostId: post.id,
                        targetUserId: post.userId,
                      );
                    } else if (value == 'block') {
                      final confirmed = await showAppConfirmSheet(
                        context: context,
                        title: l10n.blockConfirmTitle,
                        message: l10n.blockConfirmMessage,
                        confirmLabel: l10n.communityBlockUserAction,
                        isDestructive: true,
                      );
                      if (confirmed) {
                        final ok = await notifier.blockUser(post.userId);
                        if (!ok && context.mounted) {
                          final err = ref
                              .read(communityControllerProvider)
                              .error;
                          if (err != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(err.localizedMessage(l10n)),
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'report',
                      child: Text(l10n.communityReportAction),
                    ),
                    PopupMenuItem(
                      value: 'block',
                      child: Text(l10n.communityBlockUserAction),
                    ),
                  ],
                ),
            ],
          ),
          if (post.place != null) ...[
            const SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: () =>
                  context.push(AppRoutes.placeDetailsPath(post.place!.id)),
              child: Row(
                children: [
                  Icon(Icons.place_outlined, size: 16, color: colors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${post.place!.name} (${post.place!.locationLabel})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (post.photos.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            if (isDetail && post.photos.length > 1)
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.photos.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, photoIndex) => AppNetworkImage(
                    imageUrl: post.photos[photoIndex].signedUrl,
                    width: 280,
                    height: 220,
                    borderRadius: AppSpacing.radiusMd,
                  ),
                ),
              )
            else
              AppNetworkImage(
                imageUrl: post.photos.first.signedUrl,
                width: double.infinity,
                height: isDetail ? 240 : 190,
                borderRadius: AppSpacing.radiusMd,
              ),
          ],
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: isDetail
                ? null
                : () => context.push(AppRoutes.postDetailsPath(post.id)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.title != null && post.title!.trim().isNotEmpty) ...[
                  Text(post.title!, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                ],
                Text(
                  post.caption,
                  maxLines: isDetail ? null : 3,
                  overflow: isDetail
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  await notifier.toggleLike(post.id);
                  if (context.mounted) {
                    final err = ref.read(communityControllerProvider).error;
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err.localizedMessage(l10n))),
                      );
                    }
                  }
                },
                icon: Icon(
                  post.isLikedByCurrentUser
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: post.isLikedByCurrentUser
                      ? colors.error
                      : colors.textSecondary,
                ),
                label: Text('${post.likeCount}'),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.postCommentsPath(post.id)),
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: colors.textSecondary,
                ),
                label: Text('${post.commentCount}'),
              ),
              const Spacer(),
              IconButton(
                tooltip: l10n.communitySaveAction,
                onPressed: () async {
                  await notifier.toggleSavePost(post.id);
                  if (context.mounted) {
                    final err = ref.read(communityControllerProvider).error;
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err.localizedMessage(l10n))),
                      );
                    }
                  }
                },
                icon: Icon(
                  post.isSavedByCurrentUser
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: post.isSavedByCurrentUser
                      ? colors.accent
                      : colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
