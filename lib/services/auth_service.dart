import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _db = FirebaseDatabase.instance.ref();

  // =========================================================
  // ✅ AUTH (FIXED + SAFE ✅)
  // =========================================================

  static Future<String?> register(String email, String password) async {
    try {
      final cred = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .timeout(const Duration(seconds: 5)); // ✅ prevent freeze

      final user = cred.user;
      if (user == null) return "User creation failed";

      // ✅ NON-BLOCKING profile creation
      _firestore.collection('users').doc(user.uid).set({
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'verified': false,
        'reports': 0,
        'sales': 0,
        'circleId': null,
      }).catchError((e) {
        print("⚠️ Profile creation failed: $e");
      });

      return null;
    } on FirebaseAuthException catch (e) {
      print("❌ Register error: ${e.code} - ${e.message}");
      return e.message;
    } catch (e) {
      print("❌ Register error: $e");
      return "Registration failed";
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      print("🔐 Starting login...");

      final cred = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .timeout(const Duration(seconds: 5)); // ✅ prevent hanging

      final user = cred.user;
      if (user == null) return false;

      print("✅ Firebase login success");

      // ✅ IMPORTANT: DON'T BLOCK LOGIN
      _firestore.collection('users').doc(user.uid).set({
        'lastSeen': FieldValue.serverTimestamp(),
      }).catchError((e) {
        print("⚠️ lastSeen update failed: $e");
      });

      return true;
    } on FirebaseAuthException catch (e) {
      print("❌ Login error: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      print("❌ Login error: $e");
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("❌ Logout error: $e");
    }
  }

  /// ✅ AUTH STATE LISTENER
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  // =========================================================
  // ✅ USER PROFILE
  // =========================================================

  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      print("❌ Profile fetch error: $e");
      return null;
    }
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update(data);
    } catch (e) {
      print("❌ Profile update error: $e");
    }
  }

  // =========================================================
  // 🔥 SELLER SYSTEM
  // =========================================================

  static Future<void> completeSale() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'sales': FieldValue.increment(1),
      });
    } catch (e) {
      print("❌ Sale error: $e");
    }
  }

  static Future<void> reportUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'reports': FieldValue.increment(1),
      });
    } catch (e) {
      print("❌ Report error: $e");
    }
  }

  static Future<void> verifySeller() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'verified': true,
      });
    } catch (e) {
      print("❌ Verify error: $e");
    }
  }

  // =========================================================
  // ✅ CIRCLES
  // =========================================================

  static Future<String> createCircle(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    final doc = await _firestore.collection('circles').add({
      'name': name,
      'owner': user.uid,
      'members': [user.uid],
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(user.uid).update({
      'circleId': doc.id,
    });

    return doc.id;
  }

  static Future<void> joinCircle(String circleId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('circles').doc(circleId).update({
        'members': FieldValue.arrayUnion([user.uid]),
      });

      await _firestore.collection('users').doc(user.uid).update({
        'circleId': circleId,
      });
    } catch (e) {
      print("❌ Join circle error: $e");
    }
  }

  static Future<void> leaveCircle() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      final circleId = userDoc.data()?['circleId'];

      if (circleId == null) return;

      await _firestore.collection('circles').doc(circleId).update({
        'members': FieldValue.arrayRemove([user.uid]),
      });

      await _firestore.collection('users').doc(user.uid).update({
        'circleId': null,
      });
    } catch (e) {
      print("❌ Leave circle error: $e");
    }
  }

  // =========================================================
  // ✅ LOCATION SYSTEM
  // =========================================================

  static Future<void> updateLocation(double lat, double lng) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.child("locations").child(user.uid).set({
        "latitude": lat,
        "longitude": lng,
        "lastSeen": DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print("❌ Location update error: $e");
    }
  }

  static DatabaseReference getLocationsRef() {
    return FirebaseDatabase.instance.ref("locations");
  }

  // =========================================================
  // 🔥 DELETE ACCOUNT
  // =========================================================

  static Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
    } catch (e) {
      print("❌ Delete account error: $e");
    }
  }
}
