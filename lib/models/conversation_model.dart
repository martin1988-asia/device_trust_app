class ConversationModel {
  final String id;

  /// ✅ human-readable name (e.g. device or group name)
  final String deviceName;

  /// ✅ last message preview
  final String lastMessage;

  /// ✅ last message timestamp
  final int lastTimestamp;

  /// ✅ participants in this conversation
  final List<String> participants;

  /// ✅ unread count (optional, fast UI use)
  final int unreadCount;

  /// ✅ typing users (for live UI)
  final List<String> typingUsers;

  const ConversationModel({
    required this.id,
    required this.deviceName,
    required this.lastMessage,
    required this.lastTimestamp,
    this.participants = const [],
    this.unreadCount = 0,
    this.typingUsers = const [],
  });

  // =====================================================
  // ✅ FROM JSON (FIRESTORE)
  // =====================================================

  factory ConversationModel.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return ConversationModel(
      id: id,
      deviceName: json['deviceName'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastTimestamp: json['lastTimestamp'] ?? 0,
      participants: List<String>.from(json['participants'] ?? []),
      unreadCount: json['unreadCount'] ?? 0,
      typingUsers: List<String>.from(json['typingUsers'] ?? []),
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
  // ✅ COPY WITH (IMMUTABLE UPDATE)
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

  /// ✅ check if user is part of conversation
  bool containsUser(String userId) {
    return participants.contains(userId);
  }

  /// ✅ check if user is typing
  bool isUserTyping(String userId) {
    return typingUsers.contains(userId);
  }

  /// ✅ update last message safely
  ConversationModel updateLastMessage(
    String message,
    int timestamp,
  ) {
    return copyWith(
      lastMessage: message,
      lastTimestamp: timestamp,
    );
  }

  // =====================================================
  // ✅ DEBUG
  // =====================================================

  @override
  String toString() {
    return 'Conversation(id: $id, device: $deviceName, lastMessage: $lastMessage)';
  }

  // =====================================================
  // ✅ EQUALITY
  // =====================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConversationModel &&
        other.id == id &&
        other.lastMessage == lastMessage &&
        other.lastTimestamp == lastTimestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        lastMessage.hashCode ^
        lastTimestamp.hashCode;
  }
}
