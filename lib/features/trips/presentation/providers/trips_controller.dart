import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/trips/data/repositories/supabase_trips_repository.dart';
import 'package:roamory/features/trips/domain/entities/trip_entity.dart';

/// Seyahat planlama modülünün (`D01`–`D05`) durumunu temsil eder.
@immutable
class TripsState {
  /// Seyahat durumu oluşturur.
  const TripsState({
    this.isLoading = false,
    this.isSaving = false,
    this.trips = const [],
    this.selectedStatusTab = TripStatus.planned,
    this.error,
  });

  /// Yüklenme durumu.
  final bool isLoading;

  /// Kayıt/güncelleme işlemi sürüyor mu.
  final bool isSaving;

  /// Kullanıcının tüm seyahat planları (`trips`).
  final List<TripEntity> trips;

  /// `D01` ekranında seçili sekme (`planned`, `ongoing`, `completed`).
  final TripStatus selectedStatusTab;

  /// Varsa son işlem hatası.
  final AppException? error;

  /// Seçili sekmeye ait seyahatleri döndürür.
  List<TripEntity> get filteredByTab =>
      trips.where((t) => t.status == selectedStatusTab).toList();

  /// Ana sayfada (`B01`) gösterilecek ilk yaklaşan veya devam eden seyahati döndürür.
  TripEntity? get upcomingTrip {
    for (final trip in trips) {
      if (trip.status == TripStatus.ongoing ||
          trip.status == TripStatus.planned) {
        return trip;
      }
    }
    return trips.isNotEmpty ? trips.first : null;
  }

  /// Kimliğe göre seyahat planı bulur.
  TripEntity? findById(String tripId) {
    for (final t in trips) {
      if (t.id == tripId) {
        return t;
      }
    }
    return null;
  }

  /// Seçili alanları güncelleyerek kopya üretir.
  TripsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<TripEntity>? trips,
    TripStatus? selectedStatusTab,
    AppException? error,
    bool clearError = false,
  }) {
    return TripsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      trips: trips ?? this.trips,
      selectedStatusTab: selectedStatusTab ?? this.selectedStatusTab,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Seyahat planlama, günlük durak sıralama ve kontrol listesini yöneten Riverpod Notifier.
class TripsController extends Notifier<TripsState> {
  @override
  TripsState build() {
    // Oturumdaki kullanıcı kimliği değiştiğinde seyahat listesini otomatik yenileriz.
    ref.watch(authControllerProvider.select((s) => s.user?.id));
    Future.microtask(loadTrips);
    return const TripsState(isLoading: true);
  }

  String get _currentUserId =>
      ref.read(authControllerProvider).user?.id ??
      ref.read(supabaseClientProvider)?.auth.currentUser?.id ??
      '';

  /// Kullanıcının tüm seyahat planlarını veritabanından yükler.
  Future<void> loadTrips() async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      state = state.copyWith(isLoading: false, trips: const []);
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await ref.read(tripsRepositoryProvider).fetchTrips(userId);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, trips: list, clearError: true);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: ErrorMapper.map(error, stackTrace),
      );
    }
  }

  /// `D01` ekranındaki sekme filtresini değiştirir.
  void setStatusTab(TripStatus status) {
    state = state.copyWith(selectedStatusTab: status);
  }

  /// Yeni seyahat planı oluşturur veya mevcut seyahati günceller (`D02`).
  Future<TripEntity?> saveTrip(UpsertTripRequest request) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final saved = await ref.read(tripsRepositoryProvider).upsertTrip(request);
      if (!ref.mounted) return saved;
      final existingIndex = state.trips.indexWhere((t) => t.id == saved.id);
      final updated = existingIndex >= 0
          ? [for (final t in state.trips) t.id == saved.id ? saved : t]
          : [saved, ...state.trips];
      state = state.copyWith(
        isSaving: false,
        trips: updated,
        selectedStatusTab: saved.status,
        clearError: true,
      );
      return saved;
    } catch (error, stackTrace) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        isSaving: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return null;
    }
  }

  /// Seyahat planını siler (`D03`).
  Future<bool> deleteTrip(String tripId) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      return false;
    }
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref
          .read(tripsRepositoryProvider)
          .deleteTrip(tripId: tripId, userId: userId);
      if (!ref.mounted) return true;
      state = state.copyWith(
        isSaving: false,
        trips: state.trips.where((t) => t.id != tripId).toList(),
        clearError: true,
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSaving: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return false;
    }
  }

  /// Seyahat planına yeni bir gün (`trip_days`) ekler (`D04`).
  Future<TripDayEntity?> addDayToTrip(String tripId, {String? title}) async {
    final trip = state.findById(tripId);
    if (trip == null) {
      return null;
    }
    final nextDayNumber = trip.days.length + 1;
    final existingDateKeys = <String>{
      for (final day in trip.days)
        if (day.dayDate != null)
          '${day.dayDate!.year}-${day.dayDate!.month}-${day.dayDate!.day}',
    };

    // Mevcut gün yoksa başlangıç tarihinden başlatırız; varsa son günden
    // sonraki çakışmayan ilk tarihi seçeriz.
    var nextDate = trip.days.isEmpty && trip.startDate != null
        ? DateTime(
            trip.startDate!.year,
            trip.startDate!.month,
            trip.startDate!.day,
          )
        : (trip.days.lastOrNull?.dayDate ??
                  trip.startDate ??
                  DateTime.now().subtract(const Duration(days: 1)))
              .add(const Duration(days: 1));
    while (existingDateKeys.contains(
      '${nextDate.year}-${nextDate.month}-${nextDate.day}',
    )) {
      nextDate = nextDate.add(const Duration(days: 1));
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final createdDay = await ref
          .read(tripsRepositoryProvider)
          .addTripDay(
            tripId: tripId,
            dayNumber: nextDayNumber,
            dayDate: nextDate,
            title: title,
          );
      if (!ref.mounted) return createdDay;
      final createdDate = createdDay.dayDate;
      final updatedStartDate =
          createdDate != null &&
              (trip.startDate == null || createdDate.isBefore(trip.startDate!))
          ? createdDate
          : trip.startDate;
      final updatedEndDate =
          createdDate != null &&
              (trip.endDate == null || createdDate.isAfter(trip.endDate!))
          ? createdDate
          : trip.endDate;
      _replaceTripInState(
        trip.copyWith(
          startDate: updatedStartDate,
          endDate: updatedEndDate,
          days: [...trip.days, createdDay],
        ),
      );
      return createdDay;
    } catch (error, stackTrace) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        isSaving: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return null;
    }
  }

  /// Belirli bir seyahat gününün başlık ve notunu günceller (`D04`).
  Future<bool> updateDayInfo({
    required String tripId,
    required String tripDayId,
    String? title,
    String? notes,
  }) async {
    final trip = state.findById(tripId);
    if (trip == null) {
      return false;
    }
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updated = await ref
          .read(tripsRepositoryProvider)
          .updateTripDay(tripDayId: tripDayId, title: title, notes: notes);
      if (!ref.mounted) return true;
      final updatedDays = trip.days.map((d) {
        if (d.id != tripDayId) {
          return d;
        }
        return d.copyWith(title: updated.title, notes: updated.notes);
      }).toList();
      _replaceTripInState(trip.copyWith(days: updatedDays));
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSaving: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return false;
    }
  }

  /// Belirli bir güne yeni mekan durağı ekler (`D04`).
  Future<bool> addStopToDay({
    required String tripId,
    required String tripDayId,
    required PlaceEntity place,
    String? notes,
    String? arrivalTime,
  }) async {
    final trip = state.findById(tripId);
    if (trip == null) {
      return false;
    }
    final day = trip.days.where((d) => d.id == tripDayId).firstOrNull;
    final nextOrder = day == null ? 0 : day.stops.length;

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final added = await ref
          .read(tripsRepositoryProvider)
          .addTripStop(
            tripDayId: tripDayId,
            placeId: place.id,
            orderIndex: nextOrder,
            notes: notes,
            arrivalTime: arrivalTime,
          );
      if (!ref.mounted) return true;
      final resolvedStop = added.place != null
          ? added
          : added.copyWith(place: place);

      final updatedDays = trip.days.map((d) {
        if (d.id != tripDayId) {
          return d;
        }
        return d.copyWith(stops: [...d.stops, resolvedStop]);
      }).toList();

      _replaceTripInState(trip.copyWith(days: updatedDays));
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSaving: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return false;
    }
  }

  /// Gün içindeki durakların sıralamasını değiştirir (`D04`).
  Future<bool> reorderStops({
    required String tripId,
    required String tripDayId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final trip = state.findById(tripId);
    if (trip == null) {
      return false;
    }
    final day = trip.days.where((d) => d.id == tripDayId).firstOrNull;
    if (day == null || oldIndex < 0 || oldIndex >= day.stops.length) {
      return false;
    }

    final reordered = [...day.stops];
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex.clamp(0, reordered.length), moved);

    final indexed = <TripStopEntity>[
      for (var i = 0; i < reordered.length; i++)
        reordered[i].copyWith(orderIndex: i),
    ];

    final updatedDays = trip.days.map((d) {
      return d.id == tripDayId ? d.copyWith(stops: indexed) : d;
    }).toList();
    _replaceTripInState(trip.copyWith(days: updatedDays));

    try {
      await ref
          .read(tripsRepositoryProvider)
          .reorderTripStops(
            tripDayId: tripDayId,
            orderedStopIds: indexed.map((s) => s.id).toList(),
          );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      // Veritabanı güncellemesi başarısız olursa iyimser sıralamayı geri alırız.
      state = state.copyWith(
        isSaving: false,
        trips: state.trips.map((t) => t.id == trip.id ? trip : t).toList(),
        error: ErrorMapper.map(error, stackTrace),
      );
      return false;
    }
  }

  /// Bir durağı siler (`D04`).
  Future<bool> removeStop({
    required String tripId,
    required String tripDayId,
    required String stopId,
  }) async {
    final trip = state.findById(tripId);
    if (trip == null) {
      return false;
    }
    try {
      await ref.read(tripsRepositoryProvider).deleteTripStop(stopId);
      if (!ref.mounted) return true;
      final updatedDays = trip.days.map((d) {
        if (d.id != tripDayId) {
          return d;
        }
        final remaining = d.stops.where((s) => s.id != stopId).toList();
        return d.copyWith(
          stops: [
            for (var i = 0; i < remaining.length; i++)
              remaining[i].copyWith(orderIndex: i),
          ],
        );
      }).toList();
      _replaceTripInState(trip.copyWith(days: updatedDays));
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Seyahat kontrol listesine yeni madde ekler (`D05`).
  Future<bool> addChecklistItem({
    required String tripId,
    required String title,
    String category = TripChecklistCategory.general,
  }) async {
    final trip = state.findById(tripId);
    if (trip == null) {
      return false;
    }
    final nextSortOrder = trip.checklist.isEmpty
        ? 0
        : trip.checklist
                  .map((c) => c.sortOrder)
                  .reduce((a, b) => a > b ? a : b) +
              1;
    try {
      final item = await ref
          .read(tripsRepositoryProvider)
          .addChecklistItem(
            tripId: tripId,
            title: title,
            category: category,
            sortOrder: nextSortOrder,
          );
      if (!ref.mounted) return true;
      _replaceTripInState(trip.copyWith(checklist: [...trip.checklist, item]));
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Kontrol listesi maddesinin tamamlanma durumunu değiştirir (`D05`).
  Future<bool> toggleChecklistItem({
    required String tripId,
    required TripChecklistItemEntity item,
  }) async {
    final trip = state.findById(tripId);
    if (trip == null) {
      return false;
    }
    try {
      final updated = await ref
          .read(tripsRepositoryProvider)
          .updateChecklistItem(itemId: item.id, isCompleted: !item.isCompleted);
      if (!ref.mounted) return true;
      final list = trip.checklist
          .map((c) => c.id == item.id ? updated : c)
          .toList();
      _replaceTripInState(trip.copyWith(checklist: list));
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Kontrol listesi maddesini siler (`D05`).
  Future<bool> deleteChecklistItem({
    required String tripId,
    required String itemId,
  }) async {
    final trip = state.findById(tripId);
    if (trip == null) {
      return false;
    }
    try {
      await ref.read(tripsRepositoryProvider).deleteChecklistItem(itemId);
      if (!ref.mounted) return true;
      final list = trip.checklist.where((c) => c.id != itemId).toList();
      _replaceTripInState(trip.copyWith(checklist: list));
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  void _replaceTripInState(TripEntity updatedTrip) {
    state = state.copyWith(
      isSaving: false,
      trips: state.trips
          .map((t) => t.id == updatedTrip.id ? updatedTrip : t)
          .toList(),
      clearError: true,
    );
  }
}

/// Seyahat planlama durumunu sunan Riverpod sağlayıcısı.
final tripsControllerProvider = NotifierProvider<TripsController, TripsState>(
  TripsController.new,
);
