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
import 'package:roamory/core/services/location_service.dart';
import 'package:roamory/core/utils/app_date_formatter.dart';
import 'package:roamory/core/utils/travel_validators.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/explore/presentation/providers/explore_controller.dart';
import 'package:roamory/features/visits/domain/entities/visit_entity.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Ziyaret Ekle (`C04` — Stitch `f5482f42ecf04aac98f6c1995b10ce89`) ve
/// Gezi Günlüğü Düzenleyici (`C05` — Stitch `2f12819fccda45c2aaf9534e720ec927`)
/// akışı.
///
/// İki adımlı veya doğrudan günlük adımından (`initialStep: 2`) başlatılabilir:
/// - **Adım 1 (`C04`)**: Mevcut mekan seçimi veya yeni özel mekan (`is_published=false`,
///   koordinat doğrulamalı) oluşturma, ziyaret tarihi, 1..5 yıldız puan ve deneyim
///   etiketleri.
/// - **Adım 2 (`C05`)**: Anı başlığı, zengin günlük notu, `visit-photos` private
///   bucket (`<= 10 MB`) fotoğraf seçimi ve gizlilik güvencesi.
/// Kaydedilmemiş değişiklik varken çıkışta `S04` onay sayfasını (`showAppConfirmSheet`) açar.
class AddVisitAndJournalScreen extends ConsumerStatefulWidget {
  /// Ziyaret ve günlük düzenleyici ekranı oluşturur.
  const AddVisitAndJournalScreen({
    super.key,
    this.initialPlaceId,
    this.editingVisitId,
    this.initialStep = 1,
  });

  /// Seçili olarak gelecek mekan kimliği (`B04` veya `C01` üzerinden).
  final String? initialPlaceId;

  /// Düzenlenen mevcut ziyaret kimliği (`C06` üzerinden).
  final String? editingVisitId;

  /// Başlangıç adımı (`1`: C04 Ziyaret Bilgileri, `2`: C05 Gezi Günlüğü).
  final int initialStep;

  @override
  ConsumerState<AddVisitAndJournalScreen> createState() =>
      _AddVisitAndJournalScreenState();
}

class _AddVisitAndJournalScreenState
    extends ConsumerState<AddVisitAndJournalScreen> {
  late int _step;
  bool _createCustomPlace = false;
  String? _selectedPlaceId;
  DateTime _visitedAt = DateTime.now();
  int _rating = 5;
  final Set<String> _selectedCategorySlugs = {};
  final List<VisitPhotoUploadPayload> _pendingPhotos = [];
  String? _validationError;
  bool _isDirty = false;

  late final TextEditingController _customNameController;
  late final TextEditingController _customCountryController;
  late final TextEditingController _customCityController;
  late final TextEditingController _customLatController;
  late final TextEditingController _customLonController;
  late final TextEditingController _journalTitleController;
  late final TextEditingController _journalNotesController;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep.clamp(1, 2);
    _selectedPlaceId = widget.initialPlaceId;

    final existing = widget.editingVisitId == null
        ? null
        : ref.read(visitsControllerProvider).findById(widget.editingVisitId!);

    if (existing != null) {
      _selectedPlaceId = existing.placeId;
      _visitedAt = existing.visitedAt;
      _rating = existing.rating ?? 5;
      _selectedCategorySlugs.addAll(existing.categorySlugs);
    } else if (_selectedPlaceId == null &&
        ref.read(exploreControllerProvider).places.isEmpty) {
      // Katalogda henüz yayınlanmış mekan yoksa kullanıcıyı boş açılır listeyle
      // karşılaştırmamak için yeni özel mekan oluşturma modunu varsayılan açıyoruz.
      _createCustomPlace = true;
    }

    _customNameController = TextEditingController();
    _customCountryController = TextEditingController();
    _customCityController = TextEditingController();
    _customLatController = TextEditingController(text: '38.4237');
    _customLonController = TextEditingController(text: '27.1428');
    _journalTitleController = TextEditingController(
      text: existing?.title ?? '',
    );
    _journalNotesController = TextEditingController(
      text: existing?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _customCountryController.dispose();
    _customCityController.dispose();
    _customLatController.dispose();
    _customLonController.dispose();
    _journalTitleController.dispose();
    _journalNotesController.dispose();
    super.dispose();
  }

  bool _locating = false;

  /// Özel mekan oluştururken cihazın gerçek GPS koordinatını alıp enlem ve
  /// boylam alanlarına otomatik yazar.
  Future<void> _fillCurrentLocation() async {
    if (_locating) {
      return;
    }
    setState(() => _locating = true);
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(locationServiceProvider)
        .checkAndRequestCurrentLocation();
    if (!mounted) {
      return;
    }
    setState(() => _locating = false);

    if (result.hasCoordinates) {
      final coords = result.coordinates!;
      setState(() {
        _customLatController.text = coords.latitude.toStringAsFixed(5);
        _customLonController.text = coords.longitude.toStringAsFixed(5);
        _isDirty = true;
        _validationError = null;
      });
      return;
    }

    final message = switch (result.status) {
      LocationPermissionStatus.denied => l10n.mapLocationPermissionDenied,
      _ => l10n.mapLocationServiceDisabled,
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_isDirty) {
      return true;
    }
    final l10n = AppLocalizations.of(context);
    return showAppConfirmSheet(
      context: context,
      title: l10n.confirmUnsavedTitle,
      message: l10n.confirmUnsavedMessage,
      confirmLabel: l10n.confirmDiscardAction,
      cancelLabel: l10n.confirmKeepEditingAction,
      isDestructive: true,
    );
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
      _validationError = null;
      _pendingPhotos.add(
        VisitPhotoUploadPayload(
          bytes: bytes,
          fileExtension: ext.isEmpty ? 'jpg' : ext,
        ),
      );
    });
  }

  bool _validateStep1(AppLocalizations l10n) {
    if (_createCustomPlace) {
      if (_customNameController.text.trim().isEmpty ||
          _customCountryController.text.trim().isEmpty ||
          _customCityController.text.trim().isEmpty) {
        setState(() => _validationError = l10n.visitValidationPlaceRequired);
        return false;
      }
      // Dijital Pasaport sayaçlarında geçersiz kod veya mükerrer yazım oluşmaması
      // için ülke ve şehir adlarını form adımında doğruluyoruz.
      if (!TravelValidators.isValidCountry(_customCountryController.text)) {
        setState(() => _validationError = l10n.visitValidationCountryInvalid);
        return false;
      }
      if (!TravelValidators.isValidCity(_customCityController.text)) {
        setState(() => _validationError = l10n.visitValidationCityInvalid);
        return false;
      }
      final lat = double.tryParse(_customLatController.text.trim());
      final lon = double.tryParse(_customLonController.text.trim());
      if (lat == null ||
          lon == null ||
          lat < -90 ||
          lat > 90 ||
          lon < -180 ||
          lon > 180) {
        setState(
          () => _validationError = l10n.visitValidationCoordinateInvalid,
        );
        return false;
      }
    } else if (_selectedPlaceId == null || _selectedPlaceId!.trim().isEmpty) {
      setState(() => _validationError = l10n.visitValidationPlaceRequired);
      return false;
    }

    if (_rating < 1 || _rating > 5) {
      setState(() => _validationError = l10n.visitValidationRatingInvalid);
      return false;
    }

    setState(() => _validationError = null);
    return true;
  }

  Future<void> _submitVisit() async {
    final l10n = AppLocalizations.of(context);
    if (!_validateStep1(l10n)) {
      return;
    }
    // Oturum kimliğini önce AuthController'dan, yoksa doğrudan Supabase
    // auth.currentUser üzerinden alıyoruz; sahte 'local_user' dizgesi kullanmıyoruz.
    final userId =
        ref.read(authControllerProvider).user?.id ??
        ref.read(supabaseClientProvider)?.auth.currentUser?.id ??
        '';
    if (userId.isEmpty) {
      setState(() => _validationError = l10n.errorUnauthorizedMessage);
      return;
    }

    CreatePrivatePlaceRequest? customPlace;
    if (_createCustomPlace) {
      customPlace = CreatePrivatePlaceRequest(
        userId: userId,
        name: _customNameController.text.trim(),
        country: _customCountryController.text.trim(),
        city: _customCityController.text.trim(),
        latitude: double.parse(_customLatController.text.trim()),
        longitude: double.parse(_customLonController.text.trim()),
      );
    }

    final request = UpsertVisitRequest(
      visitId: widget.editingVisitId,
      userId: userId,
      placeId: _createCustomPlace ? null : _selectedPlaceId,
      customPlace: customPlace,
      visitedAt: _visitedAt,
      rating: _rating,
      title: _journalTitleController.text.trim(),
      notes: _journalNotesController.text.trim(),
      categorySlugs: _selectedCategorySlugs.toList(),
      newPhotos: _pendingPhotos,
    );

    final saved = await ref
        .read(visitsControllerProvider.notifier)
        .saveVisit(request);

    if (!mounted) {
      return;
    }
    if (saved != null) {
      _isDirty = false;
      context.pushReplacement(AppRoutes.visitDetailsPath(saved.id));
    } else {
      final err = ref.read(visitsControllerProvider).error;
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
    final visitsState = ref.watch(visitsControllerProvider);

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final discard = await _confirmDiscardIfNeeded();
        if (discard && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: RoamoryScaffold(
        appBar: AppBar(
          title: Text(
            _step == 1 ? l10n.visitAddStep1Title : l10n.visitJournalStep2Title,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            // S04 Doğrulama / Hata özeti kutusu.
            if (_validationError != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: colors.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            if (_step == 1) ...[
              // C04 — Adım 1: Mekan seçimi veya özel mekan oluşturma.
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.visitAddCreateCustomPlace),
                value: _createCustomPlace,
                onChanged: (v) => setState(() {
                  _createCustomPlace = v;
                  _isDirty = true;
                }),
              ),
              if (!_createCustomPlace) ...[
                Text(
                  l10n.visitAddSelectPlaceLabel,
                  style: textTheme.labelLarge,
                ),
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
                          child: Text('${p.name} (${p.locationLabel})'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedPlaceId = v;
                    _isDirty = true;
                  }),
                ),
              ] else ...[
                AppTextField(
                  label: l10n.visitAddPlaceNameLabel,
                  controller: _customNameController,
                  hintText: l10n.visitAddPlaceNameHint,
                  onChanged: (_) => _isDirty = true,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: l10n.searchCountryLabel,
                        controller: _customCountryController,
                        onChanged: (_) => _isDirty = true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        label: l10n.searchCityLabel,
                        controller: _customCityController,
                        onChanged: (_) => _isDirty = true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: l10n.visitAddLatitudeLabel,
                        controller: _customLatController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        onChanged: (_) => _isDirty = true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        label: l10n.visitAddLongitudeLabel,
                        controller: _customLonController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        onChanged: (_) => _isDirty = true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _locating ? null : _fillCurrentLocation,
                    icon: const Icon(Icons.my_location_rounded, size: 18),
                    label: Text(l10n.visitAddUseCurrentLocation),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // Ziyaret Tarihi + "Bugünü Seç".
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.visitAddDateLabel, style: textTheme.labelLarge),
                      Text(
                        AppDateFormatter.format(
                          context,
                          _visitedAt,
                          longMonth: true,
                        ),
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          _visitedAt = DateTime.now();
                          _isDirty = true;
                        }),
                        child: Text(l10n.visitAddTodayButton),
                      ),
                      IconButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _visitedAt,
                            firstDate: DateTime(1990),
                            lastDate: DateTime.now().add(
                              const Duration(days: 1),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              _visitedAt = picked;
                              _isDirty = true;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today_outlined),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 1..5 Yıldız Puanlama.
              Text(l10n.visitAddRatingLabel, style: textTheme.labelLarge),
              Row(
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  return IconButton(
                    onPressed: () => setState(() {
                      _rating = starValue;
                      _isDirty = true;
                    }),
                    icon: Icon(
                      starValue <= _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: colors.accent,
                      size: 32,
                    ),
                  );
                }),
              ),
              if (exploreState.categories.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(l10n.visitAddCategoriesLabel, style: textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: exploreState.categories.map((cat) {
                    final selected = _selectedCategorySlugs.contains(cat.slug);
                    final isEn = Localizations.localeOf(context).languageCode
                        .startsWith('en');
                    return FilterChip(
                      label: Text(isEn ? cat.nameEn : cat.nameTr),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          _isDirty = true;
                          if (v) {
                            _selectedCategorySlugs.add(cat.slug);
                          } else {
                            _selectedCategorySlugs.remove(cat.slug);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              PrimaryButton(
                label: l10n.visitAddContinueToJournal,
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  if (_validateStep1(l10n)) {
                    setState(() => _step = 2);
                  }
                },
              ),
            ] else ...[
              // C05 — Adım 2: Gezi Günlüğü ve Fotoğraf Yükleme.
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, color: colors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.visitJournalPrivacyBanner,
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
                label: l10n.visitJournalTitleLabel,
                controller: _journalTitleController,
                hintText: l10n.visitJournalTitleHint,
                onChanged: (_) => _isDirty = true,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.visitJournalNotesLabel,
                controller: _journalNotesController,
                hintText: l10n.visitJournalNotesHint,
                maxLines: 6,
                onChanged: (_) => _isDirty = true,
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
              if (_pendingPhotos.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _pendingPhotos.length,
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
                              _pendingPhotos[index].bytes,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: GestureDetector(
                              onTap: () => setState(
                                () => _pendingPhotos.removeAt(index),
                              ),
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
                      label: l10n.commonBack,
                      outlined: true,
                      onPressed: () => setState(() => _step = 1),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: PrimaryButton(
                      label: l10n.commonSave,
                      isLoading: visitsState.isSaving,
                      onPressed: _submitVisit,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
