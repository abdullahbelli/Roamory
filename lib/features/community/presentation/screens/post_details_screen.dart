import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/community/presentation/screens/community_feed_screen.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Gönderi Detayı Ekranı (`E03` — Stitch `a26c05d0629d4c2fb46c5b58605eddf7`).
///
/// Gönderinin tam hikayesini, fotoğraflarını, beğeni/kaydetme durumunu, yorum
/// özetini ve gönderi sahibiyse onaylı silme (`post-photos` Storage temizliğiyle)
/// aksiyonunu sunar.
class PostDetailsScreen extends ConsumerStatefulWidget {
  /// Gönderi detayı ekranı oluşturur.
  const PostDetailsScreen({super.key, required this.postId});

  /// Görüntülenecek gönderi kimliği (`posts.id`).
  final String postId;

  @override
  ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  bool _loadingPost = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notifier = ref.read(communityControllerProvider.notifier);
      final cached = ref
          .read(communityControllerProvider)
          .findPostById(widget.postId);
      if (cached == null) {
        if (mounted) {
          setState(() => _loadingPost = true);
        }
        await notifier.loadPostById(widget.postId);
        if (mounted) {
          setState(() => _loadingPost = false);
        }
      }
      if (!ref
          .read(communityControllerProvider)
          .notFoundPostIds
          .contains(widget.postId)) {
        await notifier.loadComments(widget.postId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(communityControllerProvider);
    final currentUserId = ref.watch(authControllerProvider).user?.id;
    final post = state.findPostById(widget.postId);

    if (_loadingPost && post == null) {
      return RoamoryScaffold(
        appBar: AppBar(title: Text(l10n.postDetailsTitle)),
        body: const LoadingSkeleton(itemCount: 1),
      );
    }

    if (post == null) {
      return RoamoryScaffold(
        appBar: AppBar(title: Text(l10n.postDetailsTitle)),
        body: EmptyState(
          title: l10n.errorNotFoundMessage,
          actionLabel: l10n.commonBack,
          onAction: () => context.pop(),
        ),
      );
    }

    final isOwner = currentUserId != null && currentUserId == post.userId;
    final comments = state.commentsByPost[post.id] ?? const [];

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(l10n.postDetailsTitle),
        actions: [
          if (isOwner)
            IconButton(
              tooltip: l10n.commonDelete,
              onPressed: () async {
                final confirmed = await showAppConfirmSheet(
                  context: context,
                  title: l10n.postDetailsDeleteConfirmTitle,
                  message: l10n.postDetailsDeleteConfirmMessage,
                  confirmLabel: l10n.commonDelete,
                  isDestructive: true,
                );
                if (confirmed && context.mounted) {
                  final deleted = await ref
                      .read(communityControllerProvider.notifier)
                      .deletePost(post.id);
                  if (!context.mounted) return;
                  if (deleted) {
                    context.pop();
                  } else {
                    final err = ref.read(communityControllerProvider).error;
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err.localizedMessage(l10n))),
                      );
                    }
                  }
                }
              },
              icon: Icon(Icons.delete_outline_rounded, color: colors.error),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          CommunityPostCard(post: post, isDetail: true),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.commentsTitle} (${comments.length})',
                style: textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () =>
                    context.push(AppRoutes.postCommentsPath(post.id)),
                child: Text(l10n.commonSeeAll),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (comments.isEmpty)
            Text(
              l10n.commentsEmptyMessage,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            )
          else
            ...comments.take(3).map((comment) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('@${comment.author?.username ?? 'gezgin'}'),
                subtitle: Text(comment.body),
              );
            }),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: l10n.commentsTitle,
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: () => context.push(AppRoutes.postCommentsPath(post.id)),
          ),
        ],
      ),
    );
  }
}
