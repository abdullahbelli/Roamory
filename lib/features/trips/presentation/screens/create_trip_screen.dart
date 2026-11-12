import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/utils/app_date_formatter.dart';
import 'package:roamory/core/utils/travel_validators.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/trips/domain/entities/trip_entity.dart';
import 'package:roamory/features/trips/presentation/providers/trips_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Seyahat Planı Oluştur / Düzenle Ekranı (`D02` — Stitch `1123a5616c864c2894a8599e189228e6`).
///
/// Başlık, ülke, şehir, başlangıç/bitiş tarihi (`end_date >= start_date` doğrulamalı),
/// durum ve açıklama alanlarını yönetir. Kaydedilmemiş değişikliklerde `S04` onay
/// alt sayfasını (`showAppConfirmSheet`) açar.
class CreateTripScreen extends ConsumerStatefulWidget {
  /// Seyahat oluşturma/düzenleme ekranı oluşturur.
  const CreateTripScreen({super.key, this.editingTripId});

  /// Düzenleniyorsa mevcut seyahat kimliği; yeni kayıtta `null`.
  final String? editingTripId;

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _descriptionController;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));
  TripStatus _status = TripStatus.planned;
  String? _validationError;
  bool _isDirty = false;
  bool _hydratedExisting = false;

  /// Düzenleme modunda mevcut seyahat verilerini form denetleyicilerine aktarır.
  ///
  /// Kullanıcı formu henüz düzenlemeye başlamadıysa (`!_isDirty`), veritabanından
  /// gelen ülke kodunu (`TR` -> `Türkiye` vb.) okunabilir biçime çevirir ve tarih,
  /// durum, açıklama alanlarını doldurur.
  void _hydrateFromExisting(TripEntity existing) {
    _hydratedExisting = true;
    _titleController.text = existing.title;
    final rawCountry = existing.country?.trim() ?? '';
    _countryController.text = rawCountry.isEmpty
        ? ''
        : (TravelValidators.isValidCountry(rawCountry)
              ? TravelValidators.normalizeCountryName(rawCountry)
              : rawCountry);
    _cityController.text = existing.city ?? '';
    _descriptionController.text = existing.description ?? '';
    _startDate = existing.startDate ?? _startDate;
    _endDate = existing.endDate ?? _endDate;
    _status = existing.status;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _countryController = TextEditingController();
    _cityController = TextEditingController();
    _descriptionController = TextEditingController();

    final existing = widget.editingTripId == null
        ? null
        : ref.read(tripsControllerProvider).findById(widget.editingTripId!);
    if (existing != null) {
      _hydrateFromExisting(existing);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_titleController.text.trim().isEmpty) {
      setState(() => _validationError = l10n.tripValidationTitleRequired);
      return;
    }
    final rawCountry = _countryController.text.trim();
    if (rawCountry.isNotEmpty && !TravelValidators.isValidCountry(rawCountry)) {
      setState(() => _validationError = l10n.visitValidationCountryInvalid);
      return;
    }
    final rawCity = _cityController.text.trim();
    if (rawCity.isNotEmpty && !TravelValidators.isValidCity(rawCity)) {
      setState(() => _validationError = l10n.visitValidationCityInvalid);
      return;
    }
    if (_endDate.isBefore(_startDate)) {
      setState(() => _validationError = l10n.tripValidationDateOrder);
      return;
    }

    final userId =
        ref.read(authControllerProvider).user?.id ??
        ref.read(supabaseClientProvider)?.auth.currentUser?.id ??
        '';
    if (userId.isEmpty) {
      setState(() => _validationError = l10n.errorUnauthorizedMessage);
      return;
    }
    final request = UpsertTripRequest(
      tripId: widget.editingTripId,
      userId: userId,
      title: _titleController.text.trim(),
      country: rawCountry,
      city: rawCity.isEmpty ? '' : TravelValidators.normalizeCityName(rawCity),
      description: _descriptionController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      status: _status,
    );

    final saved = await ref
        .read(tripsControllerProvider.notifier)
        .saveTrip(request);
    if (!mounted) {
      return;
    }
    if (saved != null) {
      _isDirty = false;
      // Düzenleme modunda önceki ekran zaten güncel TripDetailsScreen olduğu
      // için geri dönerek çift detay sayfası oluşmasını önleriz.
      if (widget.editingTripId != null && context.canPop()) {
        context.pop();
      } else {
        context.pushReplacement(AppRoutes.tripDetailsPath(saved.id));
      }
    } else {
      final err = ref.read(tripsControllerProvider).error;
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
    final state = ref.watch(tripsControllerProvider);

    // Seyahat listesi açılış anında henüz yükleniyorsa veri geldiğinde formu
    // mevcut seyahatle güvenli biçimde tek sefer doldururuz.
    if (widget.editingTripId != null && !_hydratedExisting && !_isDirty) {
      final loadedExisting = state.findById(widget.editingTripId!);
      if (loadedExisting != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_hydratedExisting && !_isDirty) {
            setState(() => _hydrateFromExisting(loadedExisting));
          }
        });
      }
    }

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
        appBar: AppBar(
          title: Text(
            widget.editingTripId == null
                ? l10n.tripCreateTitle
                : l10n.tripEditTitle,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            if (widget.editingTripId != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: colors.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.tripEditPreserveDaysNotice,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
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
            AppTextField(
              label: l10n.tripTitleLabel,
              controller: _titleController,
              hintText: l10n.tripTitleHint,
              onChanged: (_) => _isDirty = true,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: l10n.tripCountryLabel,
                    controller: _countryController,
                    onChanged: (_) => _isDirty = true,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppTextField(
                    label: l10n.tripCityLabel,
                    controller: _cityController,
                    onChanged: (_) => _isDirty = true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                          _isDirty = true;
                        });
                      }
                    },
                    icon: const Icon(Icons.event_outlined, size: 18),
                    label: Text(
                      '${l10n.tripStartDateLabel}: ${AppDateFormatter.format(context, _startDate)}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                          _isDirty = true;
                        });
                      }
                    },
                    icon: const Icon(Icons.event_available_outlined, size: 18),
                    label: Text(
                      '${l10n.tripEndDateLabel}: ${AppDateFormatter.format(context, _endDate)}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.tripStatusLabel, style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                ChoiceChip(
                  label: Text(l10n.tripsTabPlanned),
                  selected: _status == TripStatus.planned,
                  onSelected: (_) => setState(() {
                    _status = TripStatus.planned;
                    _isDirty = true;
                  }),
                ),
                ChoiceChip(
                  label: Text(l10n.tripsTabOngoing),
                  selected: _status == TripStatus.ongoing,
                  onSelected: (_) => setState(() {
                    _status = TripStatus.ongoing;
                    _isDirty = true;
                  }),
                ),
                ChoiceChip(
                  label: Text(l10n.tripsTabCompleted),
                  selected: _status == TripStatus.completed,
                  onSelected: (_) => setState(() {
                    _status = TripStatus.completed;
                    _isDirty = true;
                  }),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.tripDescriptionLabel,
              controller: _descriptionController,
              hintText: l10n.tripDescriptionHint,
              maxLines: 4,
              onChanged: (_) => _isDirty = true,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: l10n.commonSave,
              isLoading: state.isSaving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
