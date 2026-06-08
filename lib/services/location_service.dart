import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'auth_service.dart';

class LocationService {
  static final _db = FirebaseFirestore.instance;

  static Timer? _locationTimer;

  // =====================================================
  // ✅ ENSURE PERMISSION (SAFE ✅)
  // =====================================================

  static Future<bool> ensurePermission() async {
    try {
      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;

    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // ✅ GET CURRENT LOCATION
  // =====================================================

  static Future<Position?> getCurrentLocation() async {
    final allowed = await ensurePermission();

    if (!allowed) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  // =====================================================
  // ✅ UPDATE LOCATION (SAFE ✅)
  // =====================================================

  static Future<void> updateLocation() async {
    final user = AuthService.currentUser?.email;

    if (user == null) return;

    try {
      final pos = await getCurrentLocation();

      if (pos == null) return;

      await _db.collection('locations').doc(user).set({
        "lat": pos.latitude,
        "lng": pos.longitude,
        "accuracy": pos.accuracy,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      // ✅ PRODUCTION: log errors (optional)
    }
  }

  // =====================================================
  // ✅ START LIVE TRACKING (🔥 IMPORTANT)
  // =====================================================

  static void startTracking({int intervalSeconds = 15}) {
    stopTracking(); // ✅ prevent duplicates

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
  }

  // =====================================================
  // ✅ STREAM MULTIPLE USERS (SAFE ✅)
  // =====================================================

  static Stream<QuerySnapshot> streamLocations(
      List<String> userIds) {
    if (userIds.isEmpty) {
      return const Stream.empty();
    }

    // ✅ Firestore LIMIT FIX (max 10)
    final limited = userIds.length > 10
        ? userIds.sublist(0, 10)
        : userIds;

    return _db
        .collection('locations')
        .where(FieldPath.documentId, whereIn: limited)
        .snapshots();
  }
}
