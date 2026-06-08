class Circle {
  final String id;
  final String name;

  /// ✅ users inside the circle
  final List<String> memberIds;

  /// ✅ optional enhancements (future-ready)
  final String? ownerId;
  final int createdAt;
  final String? description;

  const Circle({
    required this.id,
    required this.name,
    required this.memberIds,
    this.ownerId,
    this.createdAt = 0,
    this.description,
  });

  // =====================================================
  // ✅ FROM JSON (FIRESTORE)
  // =====================================================

  factory Circle.fromJson(String id, Map<String, dynamic> json) {
    return Circle(
      id: id,
      name: json['name'] ?? '',
      memberIds: List<String>.from(json['memberIds'] ?? []),
      ownerId: json['ownerId'],
      createdAt: json['createdAt'] ?? 0,
      description: json['description'],
    );
  }

  // =====================================================
  // ✅ TO JSON (FIRESTORE)
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
  // ✅ HELPER METHODS
  // =====================================================

  /// ✅ Check if user is in circle
  bool containsUser(String userId) {
    return memberIds.contains(userId);
  }

  /// ✅ Add member safely
  Circle addMember(String userId) {
    if (memberIds.contains(userId)) return this;

    return copyWith(
      memberIds: [...memberIds, userId],
    );
  }

  /// ✅ Remove member safely
  Circle removeMember(String userId) {
    return copyWith(
      memberIds:
          memberIds.where((id) => id != userId).toList(),
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
  // ✅ EQUALITY (IMPORTANT FOR STATE MGMT)
  // =====================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Circle &&
        other.id == id &&
        other.name == name &&
        other.memberIds.toString() == memberIds.toString();
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        memberIds.hashCode;
  }
}
