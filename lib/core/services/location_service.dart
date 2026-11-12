import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Cihaz konum sorgusunun olası durumlarını sınıflandırır.
enum LocationPermissionStatus {
  /// İzin verildi ve geçerli koordinat alındı.
  granted,

  /// Kullanıcı konum iznini reddetti.
  denied,

  /// Cihazda konum servisi (GPS) kapalı.
  serviceDisabled,

  /// İzin var ancak henüz uydu/ağ koordinatı alınamadı.
  unavailable,
}

/// Cihazdan alınan konum izni ve koordinat sonucunu temsil eder.
@immutable
class DeviceLocationResult {
  /// Konum sonucu oluşturur.
  const DeviceLocationResult({required this.status, this.coordinates});

  /// İzin ve konum servisi durumu.
  final LocationPermissionStatus status;

  /// Konum alındıysa enlem/boylam (`LatLng`); aksi halde `null`.
  final LatLng? coordinates;

  /// Geçerli koordinatın mevcut olup olmadığını döndürür.
  bool get hasCoordinates =>
      status == LocationPermissionStatus.granted && coordinates != null;
}

/// Harita (`C01`) ve Özel Mekan Ekleme (`C04`) ekranları için konum izni ve
/// koordinat alma sözleşmesi.
abstract interface class LocationService {
  /// Konum iznini kontrol eder (gerekirse kullanıcıdan ister) ve güncel koordinatı döndürür.
  Future<DeviceLocationResult> checkAndRequestCurrentLocation();
}

/// `io.roamory.app/location` MethodChannel üzerinden yerel Android/iOS konum
/// servisini çağıran üretim implementasyonu.
class MethodChannelLocationService implements LocationService {
  /// Varsayılan kanal üzerinden servis oluşturur.
  const MethodChannelLocationService();

  static const MethodChannel _channel = MethodChannel(
    'io.roamory.app/location',
  );

  @override
  Future<DeviceLocationResult> checkAndRequestCurrentLocation() async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>(
        'checkAndRequestLocation',
      );
      if (raw == null) {
        return const DeviceLocationResult(
          status: LocationPermissionStatus.unavailable,
        );
      }

      final statusStr = (raw['status'] ?? '').toString();
      switch (statusStr) {
        case 'granted':
          final lat = (raw['latitude'] as num?)?.toDouble();
          final lon = (raw['longitude'] as num?)?.toDouble();
          if (lat != null && lon != null) {
            return DeviceLocationResult(
              status: LocationPermissionStatus.granted,
              coordinates: LatLng(lat, lon),
            );
          }
          return const DeviceLocationResult(
            status: LocationPermissionStatus.unavailable,
          );
        case 'denied':
          return const DeviceLocationResult(
            status: LocationPermissionStatus.denied,
          );
        case 'disabled':
          return const DeviceLocationResult(
            status: LocationPermissionStatus.serviceDisabled,
          );
        default:
          return const DeviceLocationResult(
            status: LocationPermissionStatus.unavailable,
          );
      }
    } on MissingPluginException {
      // Widget testlerinde veya masaüstü ortamda kanal yoksa güvenli unavailable döner.
      return const DeviceLocationResult(
        status: LocationPermissionStatus.unavailable,
      );
    } on PlatformException {
      return const DeviceLocationResult(
        status: LocationPermissionStatus.unavailable,
      );
    }
  }
}

/// Uygulama genelinde kullanılan [LocationService] bağımlılık sağlayıcısı.
///
/// Birim ve widget testlerinde `overrideWithValue` ile sahte konum servisi
/// enjekte edilerek izin/red/GPS kapalı senaryoları deterministik test edilir.
final locationServiceProvider = Provider<LocationService>((ref) {
  return const MethodChannelLocationService();
});
