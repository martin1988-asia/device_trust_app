class UserModel {
  final String id; // ✅ unique user id (VERY IMPORTANT)
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
  // ✅ REPUTATION ENGINE (IMMUTABLE SAFE)
  // =====================================================

  double calculateReputation() {
    double score = 50;

    score += successfulSales * 5;
    score -= reportedCases * 10;

    if (isVerifiedSeller) score += 20;

    return score.clamp(0, 100).toDouble();
  }

  // =====================================================
  // ✅ COPY WITH (IMMUTABLE UPDATE)
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
  // ✅ REPUTATION HELPERS (UI READY)
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
  // ✅ LOCATION HELPERS
  // =====================================================

  bool get hasLocation =>
      latitude != null && longitude != null;

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
  // ✅ SERIALIZATION
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      circleId: json['circleId'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      lastSeen: json['lastSeen'],
      reputationScore:
          (json['reputationScore'] ?? 50).toDouble(),
      successfulSales: json['successfulSales'] ?? 0,
      reportedCases: json['reportedCases'] ?? 0,
      isVerifiedSeller: json['isVerifiedSeller'] ?? false,
      profileImage: json['profileImage'],
      phoneNumber: json['phoneNumber'],
    );

    return user.copyWith(
      reputationScore: user.calculateReputation(),
    );
  }

  // =====================================================
  // ✅ DEBUG
  // =====================================================

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, reputation: ${reputationScore.toInt()})';
  }

  // =====================================================
  // ✅ EQUALITY
  // =====================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.username == username;
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode;
}
