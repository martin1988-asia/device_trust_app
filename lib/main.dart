import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'app.dart';
import 'services/device_service.dart';
import 'services/background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initFirebase();
  await _initBackgroundService();
  await _loadLocalData();

  runApp(const DeviceTrustApp());
}

// =====================================================
// ✅ FIREBASE INITIALIZATION (SAFE + FIXED)
// =====================================================

Future<void> _initFirebase() async {
  try {
    // ✅ PREVENT DUPLICATE INITIALIZATION (VERY IMPORTANT)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    debugPrint("✅ Firebase initialized");
  } catch (e) {
    debugPrint("❌ Firebase init error: $e");
  }
}

// =====================================================
// ✅ BACKGROUND SERVICE
// =====================================================

Future<void> _initBackgroundService() async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      await initializeService();
      debugPrint("✅ Background service started");
    } catch (e) {
      debugPrint("❌ Background service error: $e");
    }
  }
}

// =====================================================
// ✅ LOAD LOCAL DATA
// =====================================================

Future<void> _loadLocalData() async {
  try {
    await DeviceService.loadDevices();
    debugPrint("✅ Local data loaded");
  } catch (e) {
    debugPrint("❌ Data load error: $e");
  }
}
