import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import 'auth_service.dart';

// =====================================================
// ✅ PERMISSION HANDLER (SAFE + REUSABLE)
// =====================================================

Future<bool> _hasLocationPermission() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      print("❌ Location services disabled");
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("❌ Location permission denied");
      return false;
    }

    return true;
  } catch (e) {
    print("⚠️ Permission error: $e");
    return false;
  }
}

// =====================================================
// ✅ BACKGROUND ENTRY POINT
// =====================================================

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  Timer? timer;

  void startTracking() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 30), (t) async {
      try {
        final hasPermission = await _hasLocationPermission();
        if (!hasPermission) return;

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );

        final currentUser =
            await AuthService.getCurrentUserProfile();

        if (currentUser == null) return;

        await AuthService.updateLocation(
          position.latitude,
          position.longitude,
        );

        print("📍 Updated: ${position.latitude}, ${position.longitude}");
      } catch (e) {
        print("❌ Tracking error: $e");
      }
    });
  }

  // ✅ START TRACKING
  startTracking();

  // =====================================================
  // ✅ LISTEN FOR SERVICE EVENTS
  // =====================================================

  service.on('stopService').listen((event) {
    timer?.cancel();
    service.stopSelf();
    print("🛑 Service stopped");
  });

  service.on('setForeground').listen((event) {
    // ✅ handled by configuration
  });

  service.on('setBackground').listen((event) {
    // ✅ handled automatically
  });
}

// =====================================================
// ✅ INITIALIZE SERVICE (PRODUCTION READY)
// =====================================================

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,

      // ✅ Notification settings (important for Android)
      notificationChannelId: 'device_trust_channel',
      initialNotificationTitle: 'Device Trust Active',
      initialNotificationContent: 'Tracking device for safety',
      foregroundServiceNotificationId: 888,
    ),

    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,

      // ✅ iOS background fallback
      onBackground: (service) async {
        return true;
      },
    ),
  );

  await service.startService();
}
