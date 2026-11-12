import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/domain/entities/post_entity.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/explore/presentation/providers/explore_controller.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Topluluk Gönderisi Oluştur / Yayınla Ekranı (`E02` — Stitch `94c85959ec3f48608571d275ec67fe91`).
///
/// Bağımsız yeni gönderi oluşturmayı veya kişisel bir ziyaretten (`visitId` ile `C06`)
/// bilinçli olarak topluluk gönderisine dönüştürmeyi sağlar. Kişisel günlük notlarını
/// otomatik sızdırmaz; kullanıcıya açık gizlilik bildirimi gösterir ve `Taslak Kaydet`
/// (`status='draft'`) veya `Hemen Yayınla` (`status='published'`) seçeneklerini sunar.
class CreatePostScreen extends ConsumerStatefulWidget {
  /// Gönderi oluşturma ekranı yaratır.
  const CreatePostScreen({
    super.key,
    this.initialVisitId,
    this.initialPlaceId,
    this.initialTripId,
  });

  /// Dönüştürülen kaynak ziyaret kimliği (isteğe bağlı).
  final String? initialVisitId;

  /// Seçili mekan kimliği (isteğe bağlı).
  final String? initialPlaceId;

  /// Seçili seyahat planı kimliği (isteğe bağlı).
  final String? initialTripId;

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final List<PostPhotoUploadPayload> _photos = [];
  String? _selectedPlaceId;
  String? _validationError;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _selectedPlaceId = widget.initialPlaceId;
    // Ziyaret ekranından ("Gönderiye Dönüştür") gelindiyse yalnızca mekanı ve
    // başlığı ön dolduruyoruz; özel günlük notlarını (`visit.notes`) gizlilik
    // gereği asla otomatik kopyalamıyoruz.
    if (widget.initialVisitId != null) {
      final visit = ref
          .read(visitsControllerProvider)
          .findById(widget.initialVisitId!);
      if (visit != null) {
        _selectedPlaceId ??= visit.placeId;
        if (visit.title != null && visit.title!.trim().isNotEmpty) {
          _titleController.text = visit.title!;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final l10n = AppLocalizations.of(context);
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) {
      return;
    }
    final Uint8List bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > 10 * 1024 * 1024) {
      setState(() => _validationError = l10n.visitPhotoSizeError);
      return;
    }
    final ext = file.name.split('.').last.toLowerCase();
    setState(() {
      _isDirty = true;
      _photos.add(
        PostPhotoUploadPayload(
          bytes: bytes,
          fileExtension: ext.isEmpty ? 'jpg' : ext,
        ),
      );
    });
  }

  Future<void> _submit({required bool isDraft}) async {
    final l10n = AppLocalizations.of(context);
    if (_captionController.text.trim().isEmpty &&
        _titleController.text.trim().isEmpty) {
      setState(() => _validationError = l10n.postValidationCaptionRequired);
      return;
    }

    // Oturum kimliğini gerçek Supabase oturumundan alıyoruz; sahte 'local_user' kullanmıyoruz.
    final userId =
        ref.read(authControllerProvider).user?.id ??
        ref.read(supabaseClientProvider)?.auth.currentUser?.id ??
        '';
    if (userId.isEmpty) {
      setState(() => _validationError = l10n.errorUnauthorizedMessage);
      return;
    }
    final request = CreatePostRequest(
      userId: userId,
      title: _titleController.text.trim(),
      caption: _captionController.text.trim(),
      placeId: _selectedPlaceId,
      visitId: widget.initialVisitId,
      tripId: widget.initialTripId,
      isDraft: isDraft,
      photos: _photos,
    );

    final created = await ref
        .read(communityControllerProvider.notifier)
        .createPost(request);
    if (!mounted) {
      return;
    }
    if (created != null) {
      _isDirty = false;
      context.pushReplacement(AppRoutes.postDetailsPath(created.id));
    } else {
      final err = ref.read(communityControllerProvider).error;
      setState(
        () => _validationError =
            err?.localizedMessage(l10n) ?? l10n.errorGenericMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final exploreState = ref.watch(exploreControllerProvider);
    final communityState = ref.watch(communityControllerProvider);

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final discard = await showAppConfirmSheet(
          context: context,
          title: l10n.confirmUnsavedTitle,
          message: l10n.confirmUnsavedMessage,
          confirmLabel: l10n.confirmDiscardAction,
          cancelLabel: l10n.confirmKeepEditingAction,
          isDestructive: true,
        );
        if (discard && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: RoamoryScaffold(
        appBar: AppBar(title: Text(l10n.postCreateTitle)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            if (_validationError != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  _validationError!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: colors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.postCreatePrivacyNotice,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.postCreateTitleLabel,
              controller: _titleController,
              hintText: l10n.postCreateTitleHint,
              onChanged: (_) => _isDirty = true,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.postCreateCaptionLabel,
              controller: _captionController,
              hintText: l10n.postCreateCaptionHint,
              maxLines: 5,
              onChanged: (_) => _isDirty = true,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.postCreateSelectPlaceLabel, style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue:
                  exploreState.places.any((p) => p.id == _selectedPlaceId)
                  ? _selectedPlaceId
                  : null,
              items: exploreState.places
                  .map(
                    (p) => DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(p.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedPlaceId = v;
                _isDirty = true;
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.visitJournalPhotosLabel,
                    style: textTheme.labelLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: Text(l10n.visitJournalAddPhoto),
                ),
              ],
            ),
            if (_photos.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          child: Image.memory(
                            _photos[index].bytes,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _photos.removeAt(index)),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: colors.error,
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: colors.onError,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: l10n.postCreateSaveDraft,
                    outlined: true,
                    onPressed: communityState.isSubmitting
                        ? null
                        : () => _submit(isDraft: true),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PrimaryButton(
                    label: l10n.postCreatePublish,
                    isLoading: communityState.isSubmitting,
                    onPressed: () => _submit(isDraft: false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
