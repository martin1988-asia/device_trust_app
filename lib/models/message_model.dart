class MessageModel {
  /// ✅ Unique message ID (important for updates)
  final String? id;

  /// ✅ sender (user id or email)
  final String sender;

  /// ✅ optional receiver (for direct chat)
  final String? receiver;

  /// ✅ message content
  final String text;

  /// ✅ message type (text, image, system)
  final String type;

  /// ✅ timestamp (milliseconds)
  final int timestamp;

  /// ✅ message status
  final bool seen;

  /// ✅ delivery status
  final bool delivered;

  /// ✅ optional attachment (image/file path or URL)
  final String? attachment;

  const MessageModel({
    this.id,
    required this.sender,
    this.receiver,
    required this.text,
    this.type = "text",
    required this.timestamp,
    this.seen = false,
    this.delivered = false,
    this.attachment,
  });

  // =====================================================
  // ✅ TO JSON (FIRESTORE)
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'receiver': receiver,
      'text': text,
      'type': type,
      'timestamp': timestamp,
      'seen': seen,
      'delivered': delivered,
      'attachment': attachment,
    };
  }

  // =====================================================
  // ✅ FROM JSON (SAFE + EXTENSIBLE)
  // =====================================================

  factory MessageModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return MessageModel(
      id: id,
      sender: json['sender'] ?? 'Unknown',
      receiver: json['receiver'],
      text: json['text'] ?? '',
      type: json['type'] ?? 'text',
      timestamp: json['timestamp'] ?? 0,
      seen: json['seen'] ?? false,
      delivered: json['delivered'] ?? false,
      attachment: json['attachment'],
    );
  }

  // =====================================================
  // ✅ COPY WITH (IMMUTABLE UPDATE)
  // =====================================================

  MessageModel copyWith({
    String? id,
    String? sender,
    String? receiver,
    String? text,
    String? type,
    int? timestamp,
    bool? seen,
    bool? delivered,
    String? attachment,
  }) {
    return MessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      text: text ?? this.text,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      seen: seen ?? this.seen,
      delivered: delivered ?? this.delivered,
      attachment: attachment ?? this.attachment,
    );
  }

  // =====================================================
  // ✅ UI HELPERS
  // =====================================================

  bool get isText => type == "text";
  bool get isImage => type == "image";
  bool get isSystem => type == "system";

  bool get hasAttachment =>
      attachment != null && attachment!.isNotEmpty;

  bool isFrom(String userId) {
    return sender == userId;
  }

  // =====================================================
  // ✅ DEBUG
  // =====================================================

  @override
  String toString() {
    return 'Message(sender: $sender, text: $text, time: $timestamp)';
  }

  // =====================================================
  // ✅ EQUALITY
  // =====================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageModel &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.text == text;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        timestamp.hashCode ^
        text.hashCode;
  }
}
