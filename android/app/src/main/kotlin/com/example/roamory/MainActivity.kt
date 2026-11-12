package com.example.roamory

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.os.Build
import android.os.CancellationSignal
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// Roamory Android ana aktivitesi.
///
/// Harita (`C01`) ve Özel Mekan Ekleme (`C04`) ekranlarının çalışma zamanı konum
/// iznini (`ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`) istemesi ve cihazın
/// güncel GPS/Ağ koordinatlarını alması için `io.roamory.app/location` kanalını sunar.
class MainActivity : FlutterActivity() {
    companion object {
        private const val LOCATION_CHANNEL = "io.roamory.app/location"
        private const val LOCATION_PERMISSION_REQUEST_CODE = 4102
    }

    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkAndRequestLocation" -> handleCheckAndRequestLocation(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasLocationPermission(): Boolean {
        val fine = checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED
        val coarse = checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED
        return fine || coarse
    }

    private fun handleCheckAndRequestLocation(result: MethodChannel.Result) {
        if (hasLocationPermission()) {
            resolveDeviceCoordinates(result)
            return
        }
        if (pendingPermissionResult != null) {
            result.error("PERMISSION_IN_PROGRESS", "Konum izni isteği zaten açık.", null)
            return
        }
        pendingPermissionResult = result
        requestPermissions(
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION,
            ),
            LOCATION_PERMISSION_REQUEST_CODE,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != LOCATION_PERMISSION_REQUEST_CODE) {
            return
        }
        val callback = pendingPermissionResult ?: return
        pendingPermissionResult = null

        val granted = grantResults.any { it == PackageManager.PERMISSION_GRANTED }
        if (granted) {
            resolveDeviceCoordinates(callback)
        } else {
            callback.success(mapOf("status" to "denied"))
        }
    }

    @SuppressLint("MissingPermission")
    private fun resolveDeviceCoordinates(result: MethodChannel.Result) {
        val locationManager =
            getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        if (locationManager == null) {
            result.success(mapOf("status" to "disabled"))
            return
        }

        val gpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
        val netEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        if (!gpsEnabled && !netEnabled) {
            result.success(mapOf("status" to "disabled"))
            return
        }

        // 1. Önce önbellekteki son bilinen konumu kontrol ediyoruz.
        val providers = listOf(
            LocationManager.GPS_PROVIDER,
            LocationManager.NETWORK_PROVIDER,
            LocationManager.PASSIVE_PROVIDER,
        )
        var bestLocation: Location? = null
        for (provider in providers) {
            try {
                val candidate = locationManager.getLastKnownLocation(provider)
                if (candidate != null) {
                    if (bestLocation == null || candidate.time > bestLocation.time) {
                        bestLocation = candidate
                    }
                }
            } catch (_: Exception) {
            }
        }

        if (bestLocation != null) {
            result.success(
                mapOf(
                    "status" to "granted",
                    "latitude" to bestLocation.latitude,
                    "longitude" to bestLocation.longitude,
                ),
            )
            return
        }

        // 2. Son bilinen konum yoksa aktif sağlayıcıdan anlık konum talep ediyoruz (API 30+).
        val activeProvider = if (gpsEnabled) {
            LocationManager.GPS_PROVIDER
        } else {
            LocationManager.NETWORK_PROVIDER
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                locationManager.getCurrentLocation(
                    activeProvider,
                    CancellationSignal(),
                    mainExecutor,
                ) { location ->
                    if (location != null) {
                        result.success(
                            mapOf(
                                "status" to "granted",
                                "latitude" to location.latitude,
                                "longitude" to location.longitude,
                            ),
                        )
                    } else {
                        result.success(mapOf("status" to "unavailable"))
                    }
                }
                return
            } catch (_: Exception) {
            }
        }

        result.success(mapOf("status" to "unavailable"))
    }
}
