import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/explore/presentation/providers/explore_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Arama ve Gelişmiş Filtreler Ekranı (`B03` — Stitch `193e4b2a369842c18c26c32c48e89142`).
///
/// Mekan adı, ülke, şehir, kategori, minimum puan ve sıralama kriterlerine göre
/// gerçek zamanlı mekan filtrelemesi sunar.
class SearchFilterScreen extends ConsumerStatefulWidget {
  /// Arama ve filtre ekranı oluşturur.
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  late final TextEditingController _queryController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  String? _selectedCategorySlug;
  double? _minRating;
  bool _sortAlphabetically = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(exploreControllerProvider).filter;
    _queryController = TextEditingController(text: current.query);
    _countryController = TextEditingController(text: current.country ?? '');
    _cityController = TextEditingController(text: current.city ?? '');
    _selectedCategorySlug = current.categorySlug;
    _minRating = current.minRating;
    _sortAlphabetically = current.sortAlphabetically;
  }

  @override
  void dispose() {
    _queryController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() async {
    final filter = PlaceSearchFilter(
      query: _queryController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      categorySlug: _selectedCategorySlug,
      minRating: _minRating,
      sortAlphabetically: _sortAlphabetically,
    );
    await ref.read(exploreControllerProvider.notifier).updateFilter(filter);
  }

  Future<void> _resetFilters() async {
    setState(() {
      _queryController.clear();
      _countryController.clear();
      _cityController.clear();
      _selectedCategorySlug = null;
      _minRating = null;
      _sortAlphabetically = false;
    });
    await ref.read(exploreControllerProvider.notifier).resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final langCode = Localizations.localeOf(context).languageCode;
    final state = ref.watch(exploreControllerProvider);

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(l10n.searchTitle),
        actions: [
          TextButton(onPressed: _resetFilters, child: Text(l10n.commonReset)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          AppTextField(
            label: l10n.commonSearch,
            controller: _queryController,
            hintText: l10n.exploreSearchHint,
            prefixIcon: Icons.search_rounded,
            onChanged: (_) => _applyFilters(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: l10n.searchCountryLabel,
                  controller: _countryController,
                  hintText: l10n.searchCountryHint,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: l10n.searchCityLabel,
                  controller: _cityController,
                  hintText: l10n.searchCityHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.searchCategoryLabel, style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              ChoiceChip(
                label: Text(l10n.commonAll),
                selected: _selectedCategorySlug == null,
                onSelected: (_) {
                  setState(() => _selectedCategorySlug = null);
                  _applyFilters();
                },
              ),
              ...state.categories.map((cat) {
                final selected = _selectedCategorySlug == cat.slug;
                return ChoiceChip(
                  label: Text(cat.localizedName(langCode)),
                  selected: selected,
                  onSelected: (_) {
                    setState(
                      () => _selectedCategorySlug = selected ? null : cat.slug,
                    );
                    _applyFilters();
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.searchMinRatingLabel, style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final rating in <double?>[null, 3.0, 4.0, 4.5])
                ChoiceChip(
                  label: Text(
                    rating == null ? l10n.commonAll : '${rating.toString()}+ ★',
                  ),
                  selected: _minRating == rating,
                  onSelected: (_) {
                    setState(() => _minRating = rating);
                    _applyFilters();
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.searchSortAlphabetical),
            value: _sortAlphabetically,
            onChanged: (v) {
              setState(() => _sortAlphabetically = v);
              _applyFilters();
            },
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label:
                '${l10n.commonApply} (${l10n.searchResultsCount(state.places.length)})',
            onPressed: () async {
              await _applyFilters();
              if (context.mounted) {
                context.pop();
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.searchResultsCount(state.places.length),
            style: textTheme.titleSmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...state.places.map((place) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.place_outlined, color: colors.primary),
              title: Text(place.name),
              subtitle: Text(place.locationLabel),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.placeDetailsPath(place.id)),
            );
          }),
        ],
      ),
    );
  }
}
