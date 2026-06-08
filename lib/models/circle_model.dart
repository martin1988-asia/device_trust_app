import 'package:flutter/foundation.dart';

@immutable
class Circle {
  final String id;
  final String name;

  /// ✅ users inside the circle (IMMUTABLE)
  final List<String> memberIds;

  final String? ownerId;
  final int createdAt;
  final String? description;

  Circle({
    required this.id,
    required this.name,
    required List<String> memberIds,
    this.ownerId,
    this.createdAt = 0,
    this.description,
  }) : memberIds = List.unmodifiable(memberIds);

  // =====================================================
  // ✅ EMPTY FACTORY (SAFE DEFAULT)
  // =====================================================
  factory Circle.empty() {
    return Circle(
      id: 'unknown', // ✅ safer than empty string
      name: '',
      memberIds: const [],
    );
  }

  // =====================================================
  // ✅ FROM JSON (SAFE + OPTIMIZED)
  // =====================================================
  factory Circle.fromJson(String id, Map<String, dynamic>? json) {
    if (json == null) return Circle.empty();

    return Circle(
      id: id,
      name: json['name'] as String? ?? '',
      memberIds: List<String>.from(json['memberIds'] ?? const []),
      ownerId: json['ownerId'] as String?,
      createdAt: json['createdAt'] is int
          ? json['createdAt']
          : int.tryParse(json['createdAt']?.toString() ?? '') ?? 0,
      description: json['description'] as String?,
    );
  }

  // =====================================================
  // ✅ TO JSON
  // =====================================================
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'memberIds': memberIds,
      'ownerId': ownerId,
      'createdAt': createdAt,
      'description': description,
    };
  }

  // =====================================================
  // ✅ COPY WITH (IMMUTABLE UPDATE)
  // =====================================================
  Circle copyWith({
    String? name,
    List<String>? memberIds,
    String? ownerId,
    int? createdAt,
    String? description,
  }) {
    return Circle(
      id: id,
      name: name ?? this.name,
      memberIds: memberIds ?? this.memberIds,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  // =====================================================
  // ✅ HELPERS
  // =====================================================

  /// ✅ Check if user is in circle
  bool containsUser(String userId) {
    return memberIds.contains(userId);
  }

  /// ✅ Check ownership
  bool isOwner(String userId) {
    return ownerId != null && ownerId == userId;
  }

  /// ✅ Add member (safe, no duplicates)
  Circle addMember(String userId) {
    if (memberIds.contains(userId)) return this;
    return copyWith(memberIds: [...memberIds, userId]);
  }

  /// ✅ Remove member
  Circle removeMember(String userId) {
    return copyWith(
      memberIds: memberIds.where((id) => id != userId).toList(),
    );
  }

  // =====================================================
  // ✅ DEBUG
  // =====================================================
  @override
  String toString() {
    return 'Circle(id: $id, name: $name, members: ${memberIds.length})';
  }

  // =====================================================
  // ✅ EQUALITY (CRITICAL ✅)
  // =====================================================
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Circle &&
        other.id == id &&
        other.name == name &&
        listEquals(other.memberIds, memberIds);
  }

  @override
  int get hashCode {
    return Object.hash(id, name, Object.hashAll(memberIds));
  }
}
