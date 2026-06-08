class UserLocation {
  final String userId;

  final double latitude;
  final double longitude;

  /// ✅ when the location was recorded
  final int timestamp;

  /// ✅ optional GPS accuracy (meters)
  final double? accuracy;

  /// ✅ optional speed (m/s)
  final double? speed;

  const UserLocation({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.speed,
  });

  // =====================================================
  // ✅ FROM JSON (FIRESTORE SAFE)
  // =====================================================

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      userId: json['userId'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      timestamp: json['timestamp'] ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
    );
  }

  // =====================================================
  // ✅ TO JSON
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'accuracy': accuracy,
      'speed': speed,
    };
  }

  // =====================================================
  // ✅ COPY WITH (IMMUTABLE UPDATE)
  // =====================================================

  UserLocation copyWith({
    String? userId,
    double? latitude,
    double? longitude,
    int? timestamp,
    double? accuracy,
    double? speed,
  }) {
    return UserLocation(
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
    );
  }

  // =====================================================
  // ✅ HELPERS
  // =====================================================

  /// ✅ simple validation
  bool get isValid =>
      latitude != 0 &&
      longitude != 0 &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  /// ✅ check if location is recent (last 5 minutes)
  bool isRecent() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) < (5 * 60 * 1000);
  }

  /// ✅ format for UI display
  String get shortDisplay =>
      "${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}";

  // =====================================================
  // ✅ DEBUG
  // =====================================================

  @override
  String toString() {
    return "UserLocation(user: $userId, lat: $latitude, lng: $longitude)";
  }

  // =====================================================
  // ✅ EQUALITY
  // =====================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserLocation &&
        other.userId == userId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ timestamp.hashCode;
  }
}
