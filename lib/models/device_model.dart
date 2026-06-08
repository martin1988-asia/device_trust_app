class DeviceModel {
  final String id;

  final String name;
  final String imei;
  final String model;

  final String? status;
  final String? contact;
  final String? frontImage;
  final String? backImage;
  final String? location;

  final bool forSale;

  // ✅ MARKETPLACE
  final double? price;
  final String? description;

  // ✅ TRUST SYSTEM
  final double trustScore;
  final bool isVerified;
  final int ownershipYears;
  final int reportCount;

  // ✅ OWNERSHIP
  final List<String> ownershipHistory;
  final String currentOwner;
  final String? ownerId;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.imei,
    required this.model,
    this.status,
    this.forSale = false,
    this.price,
    this.description,
    this.contact,
    this.frontImage,
    this.backImage,
    this.location,
    this.trustScore = 50,
    this.isVerified = false,
    this.ownershipYears = 0,
    this.reportCount = 0,
    this.ownershipHistory = const [],
    this.currentOwner = "unknown",
    this.ownerId,
  });

  // =====================================================
  // ✅ TRUST SCORE ENGINE
  // =====================================================

  double calculateTrustScore() {
    double score = 50;

    if (status == "Clean") score += 25;
    if (status == "Stolen") score -= 50;

    if ((frontImage ?? "").isNotEmpty) score += 5;
    if ((backImage ?? "").isNotEmpty) score += 5;

    if ((description ?? "").length > 10) score += 5;

    if (isVerified) score += 10;

    score += ownershipYears * 2;
    score += ownershipHistory.length * 2;

    if (forSale) score += 3;

    score -= reportCount * 10;

    return score.clamp(0, 100);
  }

  // =====================================================
  // ✅ COPY WITH (IMMUTABLE UPDATE)
  // =====================================================

  DeviceModel copyWith({
    String? name,
    String? imei,
    String? model,
    String? status,
    String? contact,
    String? frontImage,
    String? backImage,
    String? location,
    bool? forSale,
    double? price,
    String? description,
    double? trustScore,
    bool? isVerified,
    int? ownershipYears,
    int? reportCount,
    List<String>? ownershipHistory,
    String? currentOwner,
    String? ownerId,
  }) {
    return DeviceModel(
      id: id,
      name: name ?? this.name,
      imei: imei ?? this.imei,
      model: model ?? this.model,
      status: status ?? this.status,
      contact: contact ?? this.contact,
      frontImage: frontImage ?? this.frontImage,
      backImage: backImage ?? this.backImage,
      location: location ?? this.location,
      forSale: forSale ?? this.forSale,
      price: price ?? this.price,
      description: description ?? this.description,
      trustScore: trustScore ?? this.trustScore,
      isVerified: isVerified ?? this.isVerified,
      ownershipYears: ownershipYears ?? this.ownershipYears,
      reportCount: reportCount ?? this.reportCount,
      ownershipHistory: ownershipHistory ?? this.ownershipHistory,
      currentOwner: currentOwner ?? this.currentOwner,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  // =====================================================
  // ✅ TRUST BADGES
  // =====================================================

  List<String> getTrustBadges() {
    final List<String> badges = [];

    if (isVerified) badges.add("✅ Verified");

    if (trustScore >= 85) {
      badges.add("🏆 Highly Trusted");
    } else if (trustScore >= 70) {
      badges.add("👍 Trusted");
    } else if (trustScore >= 40) {
      badges.add("⚠️ Medium Trust");
    } else {
      badges.add("🚨 Risky");
    }

    if (reportCount > 0) {
      badges.add("🚨 Reports: $reportCount");
    }

    if (ownershipHistory.length >= 2) {
      badges.add("📜 Multi-owner");
    }

    if (status == "Clean") badges.add("✅ Clean IMEI");
    if (status == "Stolen") badges.add("🚨 Stolen");

    return badges;
  }

  // =====================================================
  // ✅ UI HELPERS
  // =====================================================

  bool get isClean => status == "Clean";
  bool get isStolen => status == "Stolen";

  bool get hasImages =>
      (frontImage ?? "").isNotEmpty ||
      (backImage ?? "").isNotEmpty;

  // =====================================================
  // ✅ SERIALIZATION
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imei': imei,
      'model': model,
      'status': status,
      'forSale': forSale,
      'price': price,
      'description': description,
      'contact': contact,
      'frontImage': frontImage,
      'backImage': backImage,
      'location': location,
      'trustScore': trustScore,
      'isVerified': isVerified,
      'ownershipYears': ownershipYears,
      'reportCount': reportCount,
      'ownershipHistory': ownershipHistory,
      'currentOwner': currentOwner,
      'ownerId': ownerId,
    };
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final device = DeviceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imei: json['imei'] ?? '',
      model: json['model'] ?? '',
      status: json['status'],
      forSale: json['forSale'] ?? false,
      price: (json['price'] as num?)?.toDouble(),
      description: json['description'],
      contact: json['contact'],
      frontImage: json['frontImage'],
      backImage: json['backImage'],
      location: json['location'],
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 50,
      isVerified: json['isVerified'] ?? false,
      ownershipYears: json['ownershipYears'] ?? 0,
      reportCount: json['reportCount'] ?? 0,
      ownershipHistory:
          List<String>.from(json['ownershipHistory'] ?? []),
      currentOwner: json['currentOwner'] ?? "unknown",
      ownerId: json['ownerId'],
    );

    return device.copyWith(
      trustScore: device.calculateTrustScore(),
    );
  }

  // =====================================================
  // ✅ DEBUG
  // =====================================================

  @override
  String toString() {
    return 'Device(id: $id, name: $name, trust: ${trustScore.toInt()})';
  }
}
