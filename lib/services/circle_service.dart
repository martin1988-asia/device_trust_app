import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/circle_model.dart';
import 'auth_service.dart';

class CircleService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // ✅ CREATE CIRCLE
  // =====================================================

  static Future<String> createCircle(String name) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final userId = user.uid;
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw Exception("Circle name cannot be empty");
    }

    try {
      final doc = _db.collection('circles').doc();

      final inviteCode = doc.id.substring(0, 6).toUpperCase();

      final circle = Circle(
        id: doc.id,
        name: cleanName,
        ownerId: userId,
        memberIds: [userId],
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await doc.set({
        ...circle.toJson(),
        "inviteCode": inviteCode,
      });

      await _db.collection('users').doc(userId).set(
        {"circleId": doc.id},
        SetOptions(merge: true),
      );

      return inviteCode;

    } catch (e) {
      throw Exception("Failed to create circle: $e");
    }
  }

  // =====================================================
  // ✅ JOIN CIRCLE
  // =====================================================

  static Future<void> joinCircle(String inviteCode) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final userId = user.uid;

    if (inviteCode.trim().isEmpty) {
      throw Exception("Invite code is required");
    }

    try {
      final query = await _db
          .collection('circles')
          .where("inviteCode", isEqualTo: inviteCode.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Invalid invite code");
      }

      final circleDoc = query.docs.first;
      final data = circleDoc.data();

      final members = List<String>.from(data['memberIds'] ?? []);

      if (members.contains(userId)) {
        throw Exception("Already in this circle");
      }

      await circleDoc.reference.update({
        "memberIds": FieldValue.arrayUnion([userId]),
      });

      await _db.collection('users').doc(userId).set(
        {"circleId": circleDoc.id},
        SetOptions(merge: true),
      );

    } catch (e) {
      throw Exception("Failed to join circle: $e");
    }
  }

  // =====================================================
  // ✅ GET MY CIRCLE
  // =====================================================

  static Future<Circle?> getMyCircle() async {
    final user = AuthService.currentUser;

    if (user == null) return null;

    final userId = user.uid;

    try {
      final userDoc = await _db.collection('users').doc(userId).get();

      if (!userDoc.exists) return null;

      final circleId = userDoc.data()?['circleId'];

      if (circleId == null) return null;

      final circleDoc =
          await _db.collection('circles').doc(circleId).get();

      if (!circleDoc.exists) return null;

      return Circle.fromJson(circleDoc.id, circleDoc.data()!);

    } catch (e) {
      print("❌ getMyCircle error: $e");
      return null;
    }
  }

  // =====================================================
  // ✅ GET USER NAMES (FOR MAP LABELS ✅)
  // =====================================================

  static Future<Map<String, String>> getUserNames(List<String> userIds) async {
    final Map<String, String> result = {};

    try {
      for (final uid in userIds) {
        final doc = await _db.collection('users').doc(uid).get();

        if (doc.exists) {
          final data = doc.data();

          // ✅ fallback logic
          final displayName =
              data?['email'] ??
              data?['name'] ??
              "User";

          result[uid] = displayName;
        }
      }
    } catch (e) {
      print("❌ getUserNames error: $e");
    }

    return result;
  }

  // =====================================================
  // ✅ ADD MEMBER
  // =====================================================

  static Future<void> addMember(String circleId, String memberId) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final userId = user.uid;

    final doc = _db.collection('circles').doc(circleId);
    final snapshot = await doc.get();

    if (!snapshot.exists) throw Exception("Circle not found");

    final circle = Circle.fromJson(doc.id, snapshot.data()!);

    if (circle.ownerId != userId) {
      throw Exception("Only owner can add members");
    }

    if (circle.memberIds.contains(memberId)) {
      throw Exception("User already in circle");
    }

    await doc.update({
      "memberIds": FieldValue.arrayUnion([memberId]),
    });
  }

  // =====================================================
  // ✅ REMOVE MEMBER
  // =====================================================

  static Future<void> removeMember(String circleId, String memberId) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final userId = user.uid;

    final doc = _db.collection('circles').doc(circleId);
    final snapshot = await doc.get();

    if (!snapshot.exists) throw Exception("Circle not found");

    final circle = Circle.fromJson(doc.id, snapshot.data()!);

    if (circle.ownerId != userId) {
      throw Exception("Only owner can remove members");
    }

    await doc.update({
      "memberIds": FieldValue.arrayRemove([memberId]),
    });
  }

  // =====================================================
  // ✅ LEAVE CIRCLE
  // =====================================================

  static Future<void> leaveCircle(String circleId) async {
    final user = AuthService.currentUser;

    if (user == null) return;

    final userId = user.uid;

    try {
      await _db.collection('circles').doc(circleId).update({
        "memberIds": FieldValue.arrayRemove([userId]),
      });

      await _db.collection('users').doc(userId).update({
        "circleId": null,
      });

    } catch (e) {
      print("❌ leaveCircle error: $e");
    }
  }

  // =====================================================
  // ✅ GET USER CIRCLES (LEGACY)
  // =====================================================

  static Stream<List<Circle>> getUserCircles() {
    final user = AuthService.currentUser;

    if (user == null) return const Stream.empty();

    final userId = user.uid;

    return _db
        .collection('circles')
        .where("memberIds", arrayContains: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) {
              return Circle.fromJson(doc.id, doc.data());
            }).toList());
  }

  // =====================================================
  // ✅ GET SINGLE CIRCLE
  // =====================================================

  static Future<Circle?> getCircle(String circleId) async {
    final doc = await _db.collection('circles').doc(circleId).get();

    if (!doc.exists) return null;

    return Circle.fromJson(doc.id, doc.data()!);
  }
}
