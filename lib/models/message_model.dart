import 'package:flutter/foundation.dart';

@immutable
class MessageModel {
  final String id;
  final String sender;
  final String text;
  final int timestamp;
  final bool seen;

  const MessageModel({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.seen = false,
  });

  // =====================================================
  // ✅ FROM JSON
  // =====================================================
  factory MessageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const MessageModel(
        id: '',
        sender: '',
        text: '',
        timestamp: 0,
      );
    }

    return MessageModel(
      id: json['id'] ?? '',
      sender: json['sender'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      seen: json['seen'] ?? false,
    );
  }

  // =====================================================
  // ✅ TO JSON
  // =====================================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'timestamp': timestamp,
      'seen': seen,
    };
  }

  // =====================================================
  // ✅ COPY WITH
  // =====================================================
  MessageModel copyWith({
    String? id,
    String? sender,
    String? text,
    int? timestamp,
    bool? seen,
  }) {
    return MessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      seen: seen ?? this.seen,
    );
  }

  // =====================================================
  // ✅ DEBUG
  // =====================================================
  @override
  String toString() {
    return 'Message(id: $id, sender: $sender, text: $text)';
  }

  // =====================================================
  // ✅ EQUALITY
  // =====================================================
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageModel &&
        other.id == id &&
        other.sender == sender &&
        other.text == text &&
        other.timestamp == timestamp &&
        other.seen == seen;
  }

  @override
  int get hashCode {
    return Object.hash(id, sender, text, timestamp, seen);
  }
}
