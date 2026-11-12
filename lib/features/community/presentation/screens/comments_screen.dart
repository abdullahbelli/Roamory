import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/community/presentation/widgets/report_content_sheet.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_network_image.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Gönderi Yorumları Ekranı (`E04` — Stitch `398fdefcd66c4c13bbae8ef6a1ef4cdb`).
///
/// Gönderiye ait gerçek yorumları (`comments`) listeler, yeni yorum eklemeyi,
/// kendi yorumunu silmeyi ve uygunsuz yorumu bildirmeyi sağlar.
class CommentsScreen extends ConsumerStatefulWidget {
  /// Yorumlar ekranı oluşturur.
  const CommentsScreen({super.key, required this.postId});

  /// Yorumları görüntülenecek gönderi kimliği (`posts.id`).
  final String postId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(communityControllerProvider.notifier)
          .loadComments(widget.postId),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final l10n = AppLocalizations.of(context);
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final ok = await ref
        .read(communityControllerProvider.notifier)
        .addComment(postId: widget.postId, body: text);
    if (!mounted) return;
    if (ok) {
      _commentController.clear();
    } else {
      final err = ref.read(communityControllerProvider).error;
      if (err != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err.localizedMessage(l10n))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final state = ref.watch(communityControllerProvider);
    final currentUserId = ref.watch(authControllerProvider).user?.id;
    final comments = state.commentsByPost[widget.postId] ?? const [];

    return RoamoryScaffold(
      appBar: AppBar(title: Text(l10n.commentsTitle)),
      body: Column(
        children: [
          Expanded(
            child: comments.isEmpty
                ? EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: l10n.commentsEmptyMessage,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pageMargin),
                    itemCount: comments.length,
                    separatorBuilder: (_, _) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final isOwn =
                          currentUserId != null &&
                          currentUserId == comment.userId;
                      final avatarUrl = comment.author?.avatarUrl?.trim();
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: colors.primaryContainer,
                          child: avatarUrl != null && avatarUrl.isNotEmpty
                              ? ClipOval(
                                  child: AppNetworkImage(
                                    imageUrl: avatarUrl,
                                    width: 40,
                                    height: 40,
                                    borderRadius: 20,
                                    placeholderIcon:
                                        Icons.person_outline_rounded,
                                  ),
                                )
                              : Icon(
                                  Icons.person_outline_rounded,
                                  color: colors.primary,
                                ),
                        ),
                        title: Text('@${comment.author?.username ?? 'gezgin'}'),
                        subtitle: Text(comment.body),
                        trailing: isOwn
                            ? IconButton(
                                tooltip: l10n.commonDelete,
                                onPressed: () async {
                                  final confirmed = await showAppConfirmSheet(
                                    context: context,
                                    title: l10n.commentsDeleteConfirmTitle,
                                    message: l10n.commentsDeleteConfirmMessage,
                                    confirmLabel: l10n.commonDelete,
                                    isDestructive: true,
                                  );
                                  if (confirmed) {
                                    await ref
                                        .read(
                                          communityControllerProvider.notifier,
                                        )
                                        .deleteComment(
                                          postId: widget.postId,
                                          commentId: comment.id,
                                        );
                                  }
                                },
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: colors.error,
                                ),
                              )
                            : IconButton(
                                tooltip: l10n.communityReportAction,
                                onPressed: () => showReportContentSheet(
                                  context,
                                  targetPostId: widget.postId,
                                  targetCommentId: comment.id,
                                  targetUserId: comment.userId,
                                ),
                                icon: const Icon(Icons.flag_outlined, size: 18),
                              ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pageMargin),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: l10n.commentsInputHint,
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  FilledButton(
                    onPressed: state.isSubmitting ? null : _submitComment,
                    child: Text(l10n.commentsSendButton),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
