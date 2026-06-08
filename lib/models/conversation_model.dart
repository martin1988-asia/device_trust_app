import 'package:flutter/foundation.dart';

@immutable
class ConversationModel {
  final String id;

  /// ✅ human-readable name (e.g. device or group name)
  final String deviceName;

  /// ✅ last message preview
  final String lastMessage;

  /// ✅ last message timestamp
  final int lastTimestamp;

  /// ✅ participants in this conversation (IMMUTABLE)
  final List<String> participants;

  /// ✅ unread count
  final int unreadCount;

  /// ✅ typing users (IMMUTABLE)
  final List<String> typingUsers;

  const ConversationModel({
    required this.id,
    required this.deviceName,
    required this.lastMessage,
    required this.lastTimestamp,
    List<String> participants = const [],
    this.unreadCount = 0,
    List<String> typingUsers = const [],
  })  : participants = List.unmodifiable(participants),
        typingUsers = List.unmodifiable(typingUsers);

  // =====================================================
  // ✅ EMPTY FACTORY (SAFE DEFAULT)
  // =====================================================
  factory ConversationModel.empty() {
    return const ConversationModel(
      id: 'unknown',
      deviceName: '',
      lastMessage: '',
      lastTimestamp: 0,
    );
  }

  // =====================================================
  // ✅ FROM JSON (SAFE + ROBUST)
  // =====================================================
  factory ConversationModel.fromJson(String id, Map<String, dynamic>? json) {
    if (json == null) return ConversationModel.empty();

    return ConversationModel(
      id: id,
      deviceName: json['deviceName'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',

      // ✅ safe timestamp parsing
      lastTimestamp: json['lastTimestamp'] is int
          ? json['lastTimestamp']
          : int.tryParse(json['lastTimestamp']?.toString() ?? '') ?? 0,

      // ✅ FIXED parsing
      participants: List<String>.from(json['participants'] ?? const []),

      unreadCount: json['unreadCount'] is int
          ? json['unreadCount']
          : int.tryParse(json['unreadCount']?.toString() ?? '') ?? 0,

      typingUsers: List<String>.from(json['typingUsers'] ?? const []),
    );
  }

  // =====================================================
  // ✅ TO JSON
  // =====================================================
  Map<String, dynamic> toJson() {
    return {
      'deviceName': deviceName,
      'lastMessage': lastMessage,
      'lastTimestamp': lastTimestamp,
      'participants': participants,
      'unreadCount': unreadCount,
      'typingUsers': typingUsers,
    };
  }

  // =====================================================
  // ✅ COPY WITH (IMMUTABLE SAFE)
  // =====================================================
  ConversationModel copyWith({
    String? deviceName,
    String? lastMessage,
    int? lastTimestamp,
    List<String>? participants,
    int? unreadCount,
    List<String>? typingUsers,
  }) {
    return ConversationModel(
      id: id,
      deviceName: deviceName ?? this.deviceName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastTimestamp: lastTimestamp ?? this.lastTimestamp,
      participants: participants ?? this.participants,
      unreadCount: unreadCount ?? this.unreadCount,
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }

  // =====================================================
  // ✅ HELPERS
  // =====================================================

  bool containsUser(String userId) {
    return participants.contains(userId);
  }

  bool isUserTyping(String userId) {
    return typingUsers.contains(userId);
  }

  ConversationModel updateLastMessage(String message, int timestamp) {
    return copyWith(
      lastMessage: message,
      lastTimestamp: timestamp,
    );
  }

  ConversationModel incrementUnread() {
    return copyWith(unreadCount: unreadCount + 1);
  }

  ConversationModel clearUnread() {
    return copyWith(unreadCount: 0);
  }

  // =====================================================
  // ✅ DEBUG
  // =====================================================
  @override
  String toString() {
    return 'Conversation(id: $id, device: $deviceName, lastMessage: $lastMessage, unread: $unreadCount)';
  }

  // =====================================================
  // ✅ EQUALITY (FULL + CORRECT ✅)
  // =====================================================
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConversationModel &&
        other.id == id &&
        other.deviceName == deviceName &&
        other.lastMessage == lastMessage &&
        other.lastTimestamp == lastTimestamp &&
        other.unreadCount == unreadCount &&
        listEquals(other.participants, participants) &&
        listEquals(other.typingUsers, typingUsers);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      deviceName,
      lastMessage,
      lastTimestamp,
      unreadCount,
      Object.hashAll(participants),
      Object.hashAll(typingUsers),
    );
  }
}
