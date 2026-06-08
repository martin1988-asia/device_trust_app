import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';

class ChatService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // ✅ COLLECTIONS
  // =====================================================

  static CollectionReference<Map<String, dynamic>> get chats =>
      _db.collection('chats');

  static CollectionReference<Map<String, dynamic>> get conversations =>
      _db.collection('conversations');

  // =====================================================
  // ✅ SEND MESSAGE (ATOMIC + SAFE)
  // =====================================================

  static Future<void> sendMessage(
    String chatId,
    String deviceName,
    MessageModel message,
  ) async {
    try {
      final batch = _db.batch();

      final messageRef = chats.doc(chatId).collection('messages').doc();

      final updatedMessage = message.copyWith(id: messageRef.id);

      batch.set(messageRef, updatedMessage.toJson());

      final convoRef = conversations.doc(chatId);

      batch.set(
        convoRef,
        {
          "deviceName": deviceName,
          "lastMessage": message.text,
          "lastTimestamp": message.timestamp,
          "updatedAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      debugPrint("❌ Send message error: $e");
      rethrow; // ✅ don’t swallow errors
    }
  }

  // =====================================================
  // ✅ MARK AS SEEN (OPTIMIZED ✅)
  // =====================================================

  static Future<void> markMessagesAsSeen(
    String chatId,
    String currentUser,
  ) async {
    try {
      final snapshot = await chats
          .doc(chatId)
          .collection('messages')
          .where('seen', isEqualTo: false)
          .limit(100) // ✅ prevent large fetch
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _db.batch();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['sender'] != currentUser) {
          batch.update(doc.reference, {
            'seen': true,
            'delivered': true,
          });
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint("❌ Seen update error: $e");
      rethrow;
    }
  }

  // =====================================================
  // ✅ MESSAGE STREAM (TYPED ✅)
  // =====================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      String chatId) {
    return chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  // =====================================================
  // ✅ PAGINATED LOAD (SAFE ✅)
  // =====================================================

  static Future<QuerySnapshot<Map<String, dynamic>>> getMessagesPage(
    String chatId, {
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return query.get();
  }

  // =====================================================
  // ✅ CONVERSATIONS STREAM
  // =====================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>> getConversations() {
    return conversations.orderBy('lastTimestamp', descending: true).snapshots();
  }

  // =====================================================
  // ✅ TYPING SYSTEM (SAFE ✅)
  // =====================================================

  static Future<void> setTyping(String chatId, String userId) async {
    try {
      await conversations.doc(chatId).set({
        'typingUsers': FieldValue.arrayUnion([userId]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("❌ Typing error: $e");
    }
  }

  static Future<void> stopTyping(String chatId, String userId) async {
    try {
      await conversations.doc(chatId).set({
        'typingUsers': FieldValue.arrayRemove([userId]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("❌ Stop typing error: $e");
    }
  }

  // =====================================================
  // ✅ DELETE CONVERSATION
  // =====================================================

  static Future<void> deleteConversation(String chatId) async {
    try {
      await conversations.doc(chatId).delete();
    } catch (e) {
      debugPrint("❌ Delete error: $e");
      rethrow;
    }
  }

  // =====================================================
  // ✅ CLEAR MESSAGES (BATCH SAFE ✅)
  // =====================================================

  static Future<void> clearMessages(String chatId) async {
    try {
      final collection = chats.doc(chatId).collection('messages');

      final snapshot = await collection.limit(500).get();

      final batch = _db.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // ✅ recursive delete if more documents exist
      if (snapshot.docs.length == 500) {
        await clearMessages(chatId);
      }
    } catch (e) {
      debugPrint("❌ Clear messages error: $e");
      rethrow;
    }
  }
}
