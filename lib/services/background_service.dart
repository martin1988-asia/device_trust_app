import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import 'auth_service.dart';

// =====================================================
// ✅ PERMISSION HANDLER (SAFE + CLEAN)
// =====================================================
Future<bool> _hasLocationPermission() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      debugPrint("❌ Location services disabled");
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint("❌ Location permission denied");
      return false;
    }

    return true;
  } catch (e) {
    debugPrint("⚠️ Permission error: $e");
    return false;
  }
}

// =====================================================
// ✅ BACKGROUND ENTRY POINT (PRODUCTION SAFE)
// =====================================================
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  Timer? timer;

  bool isRunning = true;

  Future<void> performTracking() async {
    if (!isRunning) return;

    try {
      // ✅ permission check isolated
      final hasPermission = await _hasLocationPermission();
      if (!hasPermission) return;
    } catch (e) {
      debugPrint("❌ Permission check failed: $e");
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final currentUser = await AuthService.getCurrentUserProfile();

      if (currentUser == null) {
        debugPrint("⚠️ No logged-in user");
        return;
      }

      await AuthService.updateLocation(position.latitude, position.longitude);

      debugPrint("📍 Updated: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      debugPrint("❌ Tracking error: $e");
    }
  }

  void startTracking() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 30), (_) {
      performTracking();
    });
  }

  // ✅ START INITIAL RUN
  performTracking();
  startTracking();

  // =====================================================
  // ✅ SERVICE EVENTS
  // =====================================================

  service.on('stopService').listen((event) {
    isRunning = false;
    timer?.cancel();
    service.stopSelf();
    debugPrint("🛑 Service stopped");
  });

  service.on('setForeground').listen((event) {
    debugPrint("📱 Switched to foreground");
  });

  service.on('setBackground').listen((event) {
    debugPrint("🌙 Switched to background");
  });
}

// =====================================================
// ✅ INITIALIZE SERVICE (POLISHED)
// =====================================================
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'device_trust_channel',
      initialNotificationTitle: 'Device Trust Active',
      initialNotificationContent: 'Tracking your device for safety',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: (service) async {
        debugPrint("🔄 iOS background fetch triggered");
        return true;
      },
    ),
  );

  final isRunning = await service.isRunning();

  if (!isRunning) {
    await service.startService();
    debugPrint("✅ Background service started");
  } else {
    debugPrint("ℹ️ Service already running");
  }
}
