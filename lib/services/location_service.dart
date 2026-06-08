import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'auth_service.dart';

class LocationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Timer? _locationTimer;
  static bool _isUpdating = false;

  // =====================================================
  // ✅ COLLECTION
  // =====================================================

  static CollectionReference<Map<String, dynamic>> get locations =>
      _db.collection('locations');

  // =====================================================
  // ✅ ENSURE PERMISSION (FULL SAFE ✅)
  // =====================================================

  static Future<bool> ensurePermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        debugPrint("❌ Location services disabled");
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();

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
      debugPrint("❌ Permission error: $e");
      return false;
    }
  }

  // =====================================================
  // ✅ GET CURRENT LOCATION (SAFE ✅)
  // =====================================================

  static Future<Position?> getCurrentLocation() async {
    final allowed = await ensurePermission();
    if (!allowed) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint("❌ Location fetch error: $e");
      return null;
    }
  }

  // =====================================================
  // ✅ UPDATE LOCATION (GUARDED ✅)
  // =====================================================

  static Future<void> updateLocation() async {
    if (_isUpdating) return; // ✅ prevent overlap
    _isUpdating = true;

    try {
      final user = AuthService.currentUser?.email;

      if (user == null) {
        debugPrint("⚠️ No user for location update");
        return;
      }

      final pos = await getCurrentLocation();
      if (pos == null) return;

      await locations.doc(user).set({
        "lat": pos.latitude,
        "lng": pos.longitude,
        "accuracy": pos.accuracy,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint("📍 Location updated: ${pos.latitude}, ${pos.longitude}");
    } catch (e) {
      debugPrint("❌ Update location error: $e");
    } finally {
      _isUpdating = false;
    }
  }

  // =====================================================
  // ✅ START TRACKING (SMART ✅)
  // =====================================================

  static void startTracking({int intervalSeconds = 20}) {
    stopTracking();

    debugPrint("🚀 Location tracking started");

    _locationTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => updateLocation(),
    );
  }

  // =====================================================
  // ✅ STOP TRACKING
  // =====================================================

  static void stopTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;

    debugPrint("🛑 Location tracking stopped");
  }

  // =====================================================
  // ✅ STREAM MULTIPLE USERS (SAFE ✅)
  // =====================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamLocations(
      List<String> userIds) {
    if (userIds.isEmpty) {
      return const Stream.empty();
    }

    // ✅ Firestore allows max 10
    final limited = userIds.take(10).toList();

    if (userIds.length > 10) {
      debugPrint("⚠️ streamLocations limited to 10 users");
    }

    return locations.where(FieldPath.documentId, whereIn: limited).snapshots();
  }
}
