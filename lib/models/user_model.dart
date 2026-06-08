import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String id;
  final String username;

  /// ✅ CIRCLE SYSTEM
  final String? circleId;

  /// ✅ LOCATION
  final double? latitude;
  final double? longitude;
  final int? lastSeen;

  /// ✅ SELLER REPUTATION
  final double reputationScore;
  final int successfulSales;
  final int reportedCases;
  final bool isVerifiedSeller;

  /// ✅ PROFILE
  final String? profileImage;
  final String? phoneNumber;

  const UserModel({
    required this.id,
    required this.username,
    this.circleId,
    this.latitude,
    this.longitude,
    this.lastSeen,
    this.reputationScore = 50,
    this.successfulSales = 0,
    this.reportedCases = 0,
    this.isVerifiedSeller = false,
    this.profileImage,
    this.phoneNumber,
  });

  // =====================================================
  // ✅ EMPTY FACTORY (SAFE DEFAULT)
  // =====================================================
  factory UserModel.empty() {
    return const UserModel(
      id: 'unknown',
      username: '',
    );
  }

  // =====================================================
  // ✅ REPUTATION ENGINE (PURE ✅)
  // =====================================================
  double calculateReputation() {
    double score = 50;

    score += successfulSales * 5;
    score -= reportedCases * 10;

    if (isVerifiedSeller) score += 20;

    return score.clamp(0, 100).toDouble();
  }

  // =====================================================
  // ✅ FROM JSON (SAFE + ROBUST)
  // =====================================================
  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserModel.empty();

    final user = UserModel(
      id: json['id'] as String? ?? 'unknown',
      username: json['username'] as String? ?? '',
      circleId: json['circleId'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),

      // ✅ SAFE lastSeen parsing
      lastSeen: json['lastSeen'] is int
          ? json['lastSeen']
          : int.tryParse(json['lastSeen']?.toString() ?? ''),

      reputationScore: (json['reputationScore'] as num?)?.toDouble() ?? 50,

      successfulSales: json['successfulSales'] is int
          ? json['successfulSales']
          : int.tryParse(json['successfulSales']?.toString() ?? '') ?? 0,

      reportedCases: json['reportedCases'] is int
          ? json['reportedCases']
          : int.tryParse(json['reportedCases']?.toString() ?? '') ?? 0,

      isVerifiedSeller: json['isVerifiedSeller'] ?? false,
      profileImage: json['profileImage'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );

    return user.copyWith(
      reputationScore: user.calculateReputation(),
    );
  }

  // =====================================================
  // ✅ TO JSON
  // =====================================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'circleId': circleId,
      'latitude': latitude,
      'longitude': longitude,
      'lastSeen': lastSeen,
      'reputationScore': reputationScore,
      'successfulSales': successfulSales,
      'reportedCases': reportedCases,
      'isVerifiedSeller': isVerifiedSeller,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
    };
  }

  // =====================================================
  // ✅ COPY WITH (IMMUTABLE SAFE)
  // =====================================================
  UserModel copyWith({
    String? id,
    String? username,
    String? circleId,
    double? latitude,
    double? longitude,
    int? lastSeen,
    double? reputationScore,
    int? successfulSales,
    int? reportedCases,
    bool? isVerifiedSeller,
    String? profileImage,
    String? phoneNumber,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      circleId: circleId ?? this.circleId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastSeen: lastSeen ?? this.lastSeen,
      reputationScore: reputationScore ?? this.reputationScore,
      successfulSales: successfulSales ?? this.successfulSales,
      reportedCases: reportedCases ?? this.reportedCases,
      isVerifiedSeller: isVerifiedSeller ?? this.isVerifiedSeller,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  // =====================================================
  // ✅ UI HELPERS
  // =====================================================
  bool get hasLocation => latitude != null && longitude != null;

  bool get isLocationRecent {
    if (lastSeen == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastSeen!) < (5 * 60 * 1000);
  }

  String get locationDisplay {
    if (!hasLocation) return "Unknown";
    return "${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}";
  }

  // =====================================================
  // ✅ SELLER BADGES
  // =====================================================
  List<String> getSellerBadges() {
    final List<String> badges = [];

    if (isVerifiedSeller) {
      badges.add("✅ Verified Seller");
    }

    if (reputationScore >= 85) {
      badges.add("🏆 Top Seller");
    } else if (reputationScore >= 65) {
      badges.add("👍 Trusted Seller");
    } else if (reputationScore < 40) {
      badges.add("🚨 Risky Seller");
    }

    if (successfulSales >= 5) {
      badges.add("💼 Experienced Seller");
    }

    if (reportedCases > 0) {
      badges.add("⚠️ Reports: $reportedCases");
    }

    return badges;
  }

  String get reputationLevel {
    if (reputationScore >= 85) return "Top Seller";
    if (reputationScore >= 65) return "Trusted";
    if (reputationScore >= 40) return "Moderate";
    return "Risky";
  }

  // =====================================================
  // ✅ DEBUG
  // =====================================================
  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, reputation: ${reputationScore.toInt()})';
  }

  // =====================================================
  // ✅ EQUALITY (FULL ✅)
  // =====================================================
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.circleId == circleId &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.lastSeen == lastSeen &&
        other.reputationScore == reputationScore &&
        other.successfulSales == successfulSales &&
        other.reportedCases == reportedCases &&
        other.isVerifiedSeller == isVerifiedSeller &&
        other.profileImage == profileImage &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      username,
      circleId,
      latitude,
      longitude,
      lastSeen,
      reputationScore,
      successfulSales,
      reportedCases,
      isVerifiedSeller,
      profileImage,
      phoneNumber,
    );
  }
}
