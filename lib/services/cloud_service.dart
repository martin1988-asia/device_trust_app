import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CloudService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // ✅ COLLECTIONS (TYPED ✅)
  // =====================================================

  static CollectionReference<Map<String, dynamic>> get users =>
      _db.collection('users');

  static CollectionReference<Map<String, dynamic>> get devices =>
      _db.collection('devices');

  // =====================================================
  // ✅ USER OPERATIONS
  // =====================================================

  static Future<void> saveUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      await users.doc(userId).set({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("❌ Save user error: $e");
      rethrow;
    }
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> getUser(
      String userId) async {
    try {
      return await users.doc(userId).get();
    } catch (e) {
      debugPrint("❌ Get user error: $e");
      return null;
    }
  }

  static Future<void> updateUserField(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await users.doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("❌ Update user error: $e");
      rethrow;
    }
  }

  // =====================================================
  // ✅ DEVICE OPERATIONS
  // =====================================================

  static Future<void> saveDevice(
    String deviceId,
    Map<String, dynamic> deviceData,
  ) async {
    try {
      await devices.doc(deviceId).set({
        ...deviceData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("❌ Save device error: $e");
      rethrow;
    }
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> getDevice(
      String id) async {
    try {
      return await devices.doc(id).get();
    } catch (e) {
      debugPrint("❌ Get device error: $e");
      return null;
    }
  }

  static Future<void> updateDevice(
    String deviceId,
    Map<String, dynamic> data,
  ) async {
    try {
      await devices.doc(deviceId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("❌ Update device error: $e");
      rethrow;
    }
  }

  static Future<void> deleteDevice(String id) async {
    try {
      await devices.doc(id).delete();
    } catch (e) {
      debugPrint("❌ Delete device error: $e");
      rethrow;
    }
  }

  // =====================================================
  // ✅ MARKETPLACE STREAMS (TYPED ✅)
  // =====================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllDevices() {
    return devices.orderBy('updatedAt', descending: true).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMarketplaceDevices() {
    return devices
        .where('forSale', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserDevices(
      String ownerId) {
    return devices.where('ownerId', isEqualTo: ownerId).snapshots();
  }

  // =====================================================
  // ✅ PAGINATION (SAFE ✅)
  // =====================================================

  static Future<QuerySnapshot<Map<String, dynamic>>> getDevicesPage({
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query =
        devices.orderBy('updatedAt', descending: true).limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return query.get();
  }

  // =====================================================
  // ✅ BATCH DELETE (SAFE ✅)
  // =====================================================

  static Future<void> deleteMultipleDevices(List<String> ids) async {
    try {
      for (int i = 0; i < ids.length; i += 500) {
        final batch = _db.batch();

        final chunk = ids.skip(i).take(500);

        for (var id in chunk) {
          batch.delete(devices.doc(id));
        }

        await batch.commit();
      }
    } catch (e) {
      debugPrint("❌ Batch delete error: $e");
      rethrow;
    }
  }
}
