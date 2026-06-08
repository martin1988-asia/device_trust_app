import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/circle_model.dart';
import 'auth_service.dart';

class CircleService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // ✅ COLLECTION
  // =====================================================

  static CollectionReference<Map<String, dynamic>> get circles =>
      _db.collection('circles');

  static CollectionReference<Map<String, dynamic>> get users =>
      _db.collection('users');

  // =====================================================
  // ✅ CREATE CIRCLE (SAFE + CLEAN)
  // =====================================================

  static Future<String> createCircle(String name) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw Exception("Circle name cannot be empty");
    }

    try {
      final doc = circles.doc();

      final inviteCode = doc.id.substring(0, 6).toUpperCase();

      final circle = Circle(
        id: doc.id,
        name: cleanName,
        ownerId: user.uid,
        memberIds: [user.uid],
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      final batch = _db.batch();

      batch.set(doc, {
        ...circle.toJson(),
        "inviteCode": inviteCode,
      });

      batch.set(
        users.doc(user.uid),
        {"circleId": doc.id},
        SetOptions(merge: true),
      );

      await batch.commit();

      return inviteCode;
    } catch (e) {
      debugPrint("❌ createCircle error: $e");
      rethrow;
    }
  }

  // =====================================================
  // ✅ JOIN CIRCLE (OPTIMIZED)
  // =====================================================

  static Future<void> joinCircle(String inviteCode) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final cleanCode = inviteCode.trim().toUpperCase();

    if (cleanCode.isEmpty) {
      throw Exception("Invite code is required");
    }

    try {
      final query = await circles
          .where("inviteCode", isEqualTo: cleanCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Invalid invite code");
      }

      final circleDoc = query.docs.first;

      final members = List<String>.from(circleDoc.data()['memberIds'] ?? []);

      if (members.contains(user.uid)) {
        throw Exception("Already in this circle");
      }

      final batch = _db.batch();

      batch.update(circleDoc.reference, {
        "memberIds": FieldValue.arrayUnion([user.uid]),
      });

      batch.set(
        users.doc(user.uid),
        {"circleId": circleDoc.id},
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      debugPrint("❌ joinCircle error: $e");
      rethrow;
    }
  }

  // =====================================================
  // ✅ GET MY CIRCLE
  // =====================================================

  static Future<Circle?> getMyCircle() async {
    final user = AuthService.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await users.doc(user.uid).get();
      final circleId = userDoc.data()?['circleId'];

      if (circleId == null) return null;

      final circleDoc = await circles.doc(circleId).get();
      if (!circleDoc.exists) return null;

      return Circle.fromJson(circleDoc.id, circleDoc.data());
    } catch (e) {
      debugPrint("❌ getMyCircle error: $e");
      return null;
    }
  }

  // =====================================================
  // ✅ GET USER NAMES (OPTIMIZED ✅)
  // =====================================================

  static Future<Map<String, String>> getUserNames(List<String> userIds) async {
    final Map<String, String> result = {};

    if (userIds.isEmpty) return result;

    try {
      final snapshots = await Future.wait(
        userIds.map((uid) => users.doc(uid).get()),
      );

      for (final doc in snapshots) {
        if (doc.exists) {
          final data = doc.data();

          final displayName = data?['email'] ?? data?['name'] ?? "User";

          result[doc.id] = displayName;
        }
      }
    } catch (e) {
      debugPrint("❌ getUserNames error: $e");
    }

    return result;
  }

  // =====================================================
  // ✅ ADD MEMBER (SAFE)
  // =====================================================

  static Future<void> addMember(String circleId, String memberId) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    try {
      final doc = circles.doc(circleId);
      final snapshot = await doc.get();

      if (!snapshot.exists) {
        throw Exception("Circle not found");
      }

      final circle = Circle.fromJson(doc.id, snapshot.data());

      if (circle.ownerId != user.uid) {
        throw Exception("Only owner can add members");
      }

      if (circle.memberIds.contains(memberId)) {
        throw Exception("User already in circle");
      }

      await doc.update({
        "memberIds": FieldValue.arrayUnion([memberId]),
      });
    } catch (e) {
      debugPrint("❌ addMember error: $e");
      rethrow;
    }
  }

  // =====================================================
  // ✅ REMOVE MEMBER
  // =====================================================

  static Future<void> removeMember(String circleId, String memberId) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    try {
      final doc = circles.doc(circleId);
      final snapshot = await doc.get();

      if (!snapshot.exists) {
        throw Exception("Circle not found");
      }

      final circle = Circle.fromJson(doc.id, snapshot.data());

      if (circle.ownerId != user.uid) {
        throw Exception("Only owner can remove members");
      }

      await doc.update({
        "memberIds": FieldValue.arrayRemove([memberId]),
      });
    } catch (e) {
      debugPrint("❌ removeMember error: $e");
      rethrow;
    }
  }

  // =====================================================
  // ✅ LEAVE CIRCLE
  // =====================================================

  static Future<void> leaveCircle(String circleId) async {
    final user = AuthService.currentUser;
    if (user == null) return;

    try {
      final batch = _db.batch();

      batch.update(circles.doc(circleId), {
        "memberIds": FieldValue.arrayRemove([user.uid]),
      });

      batch.update(users.doc(user.uid), {
        "circleId": null,
      });

      await batch.commit();
    } catch (e) {
      debugPrint("❌ leaveCircle error: $e");
      rethrow;
    }
  }

  // =====================================================
  // ✅ GET USER CIRCLES (STREAM)
  // =====================================================

  static Stream<List<Circle>> getUserCircles() {
    final user = AuthService.currentUser;
    if (user == null) return const Stream.empty();

    return circles.where("memberIds", arrayContains: user.uid).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Circle.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  // =====================================================
  // ✅ GET SINGLE CIRCLE
  // =====================================================

  static Future<Circle?> getCircle(String circleId) async {
    try {
      final doc = await circles.doc(circleId).get();

      if (!doc.exists) return null;

      return Circle.fromJson(doc.id, doc.data());
    } catch (e) {
      debugPrint("❌ getCircle error: $e");
      return null;
    }
  }
}
