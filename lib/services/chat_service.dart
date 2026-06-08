import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // ✅ COLLECTIONS
  // =====================================================

  static CollectionReference get chats => _db.collection('chats');
  static CollectionReference get conversations =>
      _db.collection('conversations');

  // =====================================================
  // ✅ SEND MESSAGE (OPTIMIZED + SAFE)
  // =====================================================

  static Future<void> sendMessage(
    String chatId,
    String deviceName,
    MessageModel message,
  ) async {
    try {
      final batch = _db.batch();

      final messageRef =
          chats.doc(chatId).collection('messages').doc();

      // ✅ Save message with ID
      batch.set(
        messageRef,
        message.copyWith(id: messageRef.id).toJson(),
      );

      // ✅ Update conversation summary
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
      print("❌ Send message error: $e");
    }
  }

  // =====================================================
  // ✅ MARK AS SEEN (BATCH OPTIMIZED)
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
          .get();

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
      print("❌ Seen update error: $e");
    }
  }

  // =====================================================
  // ✅ MESSAGE STREAM (REAL-TIME + PAGINATION READY)
  // =====================================================

  static Stream<QuerySnapshot> getMessages(String chatId) {
    return chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // =====================================================
  // ✅ PAGINATED LOAD (FOR BIG CHATS)
  // =====================================================

  static Future<QuerySnapshot> getMessagesPage(
    String chatId, {
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    Query query = chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return await query.get();
  }

  // =====================================================
  // ✅ CONVERSATIONS STREAM
  // =====================================================

  static Stream<QuerySnapshot> getConversations() {
    return conversations
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  // =====================================================
  // ✅ TYPING SYSTEM
  // =====================================================

  static Future<void> setTyping(
    String chatId,
    String userId,
  ) async {
    try {
      await conversations.doc(chatId).set({
        'typingUsers': FieldValue.arrayUnion([userId]),
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Typing error: $e");
    }
  }

  static Future<void> stopTyping(
    String chatId,
    String userId,
  ) async {
    try {
      await conversations.doc(chatId).set({
        'typingUsers': FieldValue.arrayRemove([userId]),
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Stop typing error: $e");
    }
  }

  // =====================================================
  // ✅ DELETE CONVERSATION
  // =====================================================

  static Future<void> deleteConversation(String chatId) async {
    try {
      await conversations.doc(chatId).delete();
    } catch (e) {
      print("❌ Delete error: $e");
    }
  }

  // =====================================================
  // ✅ CLEAR MESSAGES (BATCH SAFE)
  // =====================================================

  static Future<void> clearMessages(String chatId) async {
    try {
      final snapshot =
          await chats.doc(chatId).collection('messages').get();

      final batch = _db.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print("❌ Clear messages error: $e");
    }
  }
}
