import 'package:cloud_firestore/cloud_firestore.dart';

class CloudService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // ✅ COLLECTIONS
  // =====================================================

  static CollectionReference get users => _db.collection('users');
  static CollectionReference get devices => _db.collection('devices');

  // =====================================================
  // ✅ USER OPERATIONS
  // =====================================================

  /// ✅ SAVE OR UPDATE USER (SAFE MERGE)
  static Future<void> saveUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      await users.doc(userId).set(
        {
          ...userData,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print("❌ Save user error: $e");
    }
  }

  /// ✅ GET USER
  static Future<DocumentSnapshot?> getUser(String userId) async {
    try {
      return await users.doc(userId).get();
    } catch (e) {
      print("❌ Get user error: $e");
      return null;
    }
  }

  /// ✅ UPDATE USER FIELD
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
      print("❌ Update user error: $e");
    }
  }

  // =====================================================
  // ✅ DEVICE OPERATIONS
  // =====================================================

  /// ✅ SAVE DEVICE (SAFE MERGE)
  static Future<void> saveDevice(
    String deviceId,
    Map<String, dynamic> deviceData,
  ) async {
    try {
      await devices.doc(deviceId).set(
        {
          ...deviceData,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print("❌ Save device error: $e");
    }
  }

  /// ✅ GET DEVICE
  static Future<DocumentSnapshot?> getDevice(String id) async {
    try {
      return await devices.doc(id).get();
    } catch (e) {
      print("❌ Get device error: $e");
      return null;
    }
  }

  /// ✅ UPDATE DEVICE
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
      print("❌ Update device error: $e");
    }
  }

  /// ✅ DELETE DEVICE
  static Future<void> deleteDevice(String id) async {
    try {
      await devices.doc(id).delete();
    } catch (e) {
      print("❌ Delete device error: $e");
    }
  }

  // =====================================================
  // ✅ MARKETPLACE STREAMS
  // =====================================================

  /// ✅ ALL DEVICES (REAL-TIME)
  static Stream<QuerySnapshot> getAllDevices() {
    return devices
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  /// ✅ ONLY DEVICES FOR SALE
  static Stream<QuerySnapshot> getMarketplaceDevices() {
    return devices
        .where('forSale', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  /// ✅ FILTER BY OWNER
  static Stream<QuerySnapshot> getUserDevices(String ownerId) {
    return devices
        .where('ownerId', isEqualTo: ownerId)
        .snapshots();
  }

  // =====================================================
  // ✅ PAGINATION (SCALING READY)
  // =====================================================

  static Future<QuerySnapshot> getDevicesPage({
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    Query query = devices
        .orderBy('updatedAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return await query.get();
  }

  // =====================================================
  // ✅ BATCH DELETE (OPTIMIZED)
  // =====================================================

  static Future<void> deleteMultipleDevices(
    List<String> ids,
  ) async {
    try {
      final batch = _db.batch();

      for (var id in ids) {
        batch.delete(devices.doc(id));
      }

      await batch.commit();
    } catch (e) {
      print("❌ Batch delete error: $e");
    }
  }
}
