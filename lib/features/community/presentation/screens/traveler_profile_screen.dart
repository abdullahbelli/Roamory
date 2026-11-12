import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/data/repositories/supabase_community_repository.dart';
import 'package:roamory/features/community/domain/entities/post_entity.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/community/presentation/screens/community_feed_screen.dart';
import 'package:roamory/features/community/presentation/widgets/report_content_sheet.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_network_image.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Gezgin Profili (`E05` — Stitch `c8c12a7bc9874efbbf7539b196012144`)
/// ve Takipçiler / Takip Edilenler (`E06` — Stitch `24322a17804c48f2bb0759d023ff68ce`)
/// ekranları.
class TravelerProfileScreen extends ConsumerStatefulWidget {
  /// Gezgin profili ekranı oluşturur.
  const TravelerProfileScreen({super.key, required this.userId});

  /// Görüntülenecek gezginin kullanıcı kimliği (`profiles.id`).
  final String userId;

  @override
  ConsumerState<TravelerProfileScreen> createState() =>
      _TravelerProfileScreenState();
}

class _TravelerProfileScreenState extends ConsumerState<TravelerProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(communityControllerProvider.notifier)
          .loadTravelerProfile(widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(communityControllerProvider);
    final notifier = ref.read(communityControllerProvider.notifier);
    final currentUserId = ref.watch(authControllerProvider).user?.id;
    final isSelf = currentUserId != null && currentUserId == widget.userId;

    final profile =
        state.travelerProfiles[widget.userId] ??
        TravelerSummaryEntity(
          id: widget.userId,
          username: 'gezgin',
          fullName: l10n.travelerProfileTitle,
        );
    final avatarUrl = profile.avatarUrl?.trim();
    final posts = profile.isBlockedByCurrentUser
        ? const <PostEntity>[]
        : (state.travelerPosts[widget.userId] ??
              state.feedPosts.where((p) => p.userId == widget.userId).toList());

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(l10n.travelerProfileTitle),
        actions: [
          if (!isSelf)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'report') {
                  await showReportContentSheet(
                    context,
                    targetUserId: widget.userId,
                  );
                } else if (value == 'block') {
                  final confirmed = await showAppConfirmSheet(
                    context: context,
                    title: l10n.blockConfirmTitle,
                    message: l10n.blockConfirmMessage,
                    confirmLabel: l10n.communityBlockUserAction,
                    isDestructive: true,
                  );
                  if (confirmed && context.mounted) {
                    final ok = await notifier.blockUser(widget.userId);
                    if (ok && context.mounted) {
                      context.pop();
                    }
                  }
                } else if (value == 'unblock') {
                  await notifier.unblockUser(widget.userId);
                  await notifier.loadTravelerProfile(widget.userId);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'report',
                  child: Text(l10n.communityReportAction),
                ),
                PopupMenuItem(
                  value: profile.isBlockedByCurrentUser ? 'unblock' : 'block',
                  child: Text(
                    profile.isBlockedByCurrentUser
                        ? l10n.communityUnblockUserAction
                        : l10n.communityBlockUserAction,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colors.primaryContainer,
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? ClipOval(
                          child: AppNetworkImage(
                            imageUrl: avatarUrl,
                            width: 72,
                            height: 72,
                            borderRadius: 36,
                            placeholderIcon: Icons.person_outline_rounded,
                          ),
                        )
                      : Icon(
                          Icons.person_outline_rounded,
                          size: 36,
                          color: colors.primary,
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(profile.fullName, style: textTheme.headlineSmall),
                Text(
                  '@${profile.username}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    profile.bio!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(
                      label: l10n.travelerPostsStat,
                      value: profile.postsCount.toString(),
                    ),
                    InkWell(
                      onTap: () => context.push(
                        AppRoutes.travelerConnectionsPath(
                          widget.userId,
                          followers: true,
                        ),
                      ),
                      child: _StatColumn(
                        label: l10n.travelerFollowersStat,
                        value: profile.followersCount.toString(),
                      ),
                    ),
                    InkWell(
                      onTap: () => context.push(
                        AppRoutes.travelerConnectionsPath(
                          widget.userId,
                          followers: false,
                        ),
                      ),
                      child: _StatColumn(
                        label: l10n.travelerFollowingStat,
                        value: profile.followingCount.toString(),
                      ),
                    ),
                  ],
                ),
                if (!isSelf) ...[
                  const SizedBox(height: AppSpacing.md),
                  if (profile.isBlockedByCurrentUser)
                    SecondaryButton(
                      label: l10n.communityUnblockUserAction,
                      outlined: true,
                      onPressed: () async {
                        await notifier.unblockUser(widget.userId);
                        await notifier.loadTravelerProfile(widget.userId);
                      },
                    )
                  else
                    PrimaryButton(
                      label: profile.isFollowedByCurrentUser
                          ? l10n.communityFollowingAction
                          : l10n.communityFollowAction,
                      onPressed: () async {
                        await notifier.toggleFollow(widget.userId);
                        if (context.mounted) {
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
                      },
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...posts.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CommunityPostCard(post: post),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = RoamoryColors.of(context);
    return Column(
      children: [
        Text(value, style: textTheme.titleLarge),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

/// Roamory Takipçiler / Takip Edilenler Ekranı (`E06` — Stitch `24322a17804c48f2bb0759d023ff68ce`).
class FollowersFollowingScreen extends ConsumerStatefulWidget {
  /// Takipçiler / Takip Edilenler ekranı oluşturur.
  const FollowersFollowingScreen({
    super.key,
    required this.userId,
    this.initialShowFollowers = true,
  });

  /// Hedef kullanıcı kimliği.
  final String userId;

  /// `true` ise Takipçiler, `false` ise Takip Edilenler sekmesiyle başlar.
  final bool initialShowFollowers;

  @override
  ConsumerState<FollowersFollowingScreen> createState() =>
      _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState
    extends ConsumerState<FollowersFollowingScreen> {
  late bool _showFollowers;
  List<TravelerSummaryEntity> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _showFollowers = widget.initialShowFollowers;
    Future.microtask(_loadConnections);
  }

  Future<void> _loadConnections() async {
    setState(() => _loading = true);
    try {
      final currentUserId =
          ref.read(authControllerProvider).user?.id ?? widget.userId;
      final list = await ref
          .read(communityRepositoryProvider)
          .fetchFollowConnections(
            targetUserId: widget.userId,
            currentUserId: currentUserId,
            followers: _showFollowers,
          );
      if (mounted) {
        setState(() {
          _items = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(_showFollowers ? l10n.followersTitle : l10n.followingTitle),
      ),
      body: Column(
        children: [
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
                    label: Text(l10n.followersTitle),
                    selected: _showFollowers,
                    onSelected: (_) {
                      setState(() => _showFollowers = true);
                      _loadConnections();
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.followingTitle),
                    selected: !_showFollowers,
                    onSelected: (_) {
                      setState(() => _showFollowers = false);
                      _loadConnections();
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingSkeleton(
                    itemCount: 2,
                    showMediaPlaceholder: false,
                  )
                : _items.isEmpty
                ? EmptyState(
                    icon: Icons.people_outline_rounded,
                    title: _showFollowers
                        ? l10n.followersEmptyMessage
                        : l10n.followingEmptyMessage,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.pageMargin),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final traveler = _items[index];
                      return ListTile(
                        title: Text(traveler.fullName),
                        subtitle: Text('@${traveler.username}'),
                        onTap: () => context.push(
                          AppRoutes.travelerProfilePath(traveler.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
