import 'package:flutter/foundation.dart';

@immutable
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

  // ✅ OWNERSHIP (IMMUTABLE ✅)
  final List<String> ownershipHistory;
  final String currentOwner;
  final String? ownerId;

  DeviceModel({
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
    List<String> ownershipHistory = const [],
    this.currentOwner = "unknown",
    this.ownerId,
  }) : ownershipHistory = List.unmodifiable(ownershipHistory);

  // =====================================================
  // ✅ TRUST SCORE ENGINE (PURE FUNCTION ✅)
  // =====================================================
  double calculateTrustScore() {
    double score = 50;

    if (status == "Clean") score += 25;
    if (status == "Stolen") score -= 50;

    if ((frontImage ?? "").isNotEmpty) score += 5;
    if ((backImage ?? "").isNotEmpty) score += 5;

    if ((description ?? "").trim().length > 10) score += 5;

    if (isVerified) score += 10;

    score += ownershipYears * 2;
    score += ownershipHistory.length * 2;

    if (forSale) score += 3;

    score -= reportCount * 10;

    return score.clamp(0, 100);
  }

  // =====================================================
  // ✅ EMPTY FACTORY
  // =====================================================
  factory DeviceModel.empty() {
    return DeviceModel(
      id: 'unknown',
      name: '',
      imei: '',
      model: '',
    );
  }

  // =====================================================
  // ✅ FROM JSON (SAFE + OPTIMIZED ✅)
  // =====================================================
  factory DeviceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DeviceModel.empty();

    final device = DeviceModel(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? '',
      imei: json['imei'] as String? ?? '',
      model: json['model'] as String? ?? '',
      status: json['status'] as String?,
      forSale: json['forSale'] ?? false,
      price: (json['price'] as num?)?.toDouble(),
      description: json['description'] as String?,
      contact: json['contact'] as String?,
      frontImage: json['frontImage'] as String?,
      backImage: json['backImage'] as String?,
      location: json['location'] as String?,
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 50,
      isVerified: json['isVerified'] ?? false,
      ownershipYears: json['ownershipYears'] is int
          ? json['ownershipYears']
          : int.tryParse(json['ownershipYears']?.toString() ?? '') ?? 0,
      reportCount: json['reportCount'] is int
          ? json['reportCount']
          : int.tryParse(json['reportCount']?.toString() ?? '') ?? 0,
      ownershipHistory: List<String>.from(json['ownershipHistory'] ?? const []),
      currentOwner: json['currentOwner'] as String? ?? "unknown",
      ownerId: json['ownerId'] as String?,
    );

    // ✅ single recalculation (no extra object creation)
    return device.copyWith(
      trustScore: device.calculateTrustScore(),
    );
  }

  // =====================================================
  // ✅ TO JSON
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

  // =====================================================
  // ✅ COPY WITH (IMMUTABLE)
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
  // ✅ UI HELPERS
  // =====================================================
  bool get isClean => status == "Clean";
  bool get isStolen => status == "Stolen";

  bool get hasImages =>
      (frontImage ?? "").isNotEmpty || (backImage ?? "").isNotEmpty;

  // =====================================================
  // ✅ DEBUG
  // =====================================================
  @override
  String toString() {
    return 'Device(id: $id, name: $name, trust: ${trustScore.toInt()})';
  }

  // =====================================================
  // ✅ EQUALITY (CRITICAL ✅)
  // =====================================================
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceModel &&
        other.id == id &&
        other.name == name &&
        other.imei == imei &&
        other.model == model &&
        other.status == status &&
        other.forSale == forSale &&
        other.price == price &&
        other.description == description &&
        other.contact == contact &&
        other.frontImage == frontImage &&
        other.backImage == backImage &&
        other.location == location &&
        other.trustScore == trustScore &&
        other.isVerified == isVerified &&
        other.ownershipYears == ownershipYears &&
        other.reportCount == reportCount &&
        other.currentOwner == currentOwner &&
        other.ownerId == ownerId &&
        listEquals(other.ownershipHistory, ownershipHistory);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      imei,
      model,
      status,
      forSale,
      price,
      description,
      contact,
      frontImage,
      backImage,
      location,
      trustScore,
      isVerified,
      ownershipYears,
      reportCount,
      currentOwner,
      ownerId,
      Object.hashAll(ownershipHistory),
    );
  }
}
