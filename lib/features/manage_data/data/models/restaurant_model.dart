import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';

/// Data model — handles Firestore JSON serialization only.
/// Each branch is stored as a separate restaurant document.
class RestaurantModel {
  final String? docId;
  final String name;
  final String branchLocation;
  final int totalBranches;
  final int branchIndex;
  final bool isOpend;
  final bool isAvailable;
  final String? imageUrl;
  final String? userEmail;
  final DateTime? createdAt;

  const RestaurantModel({
    this.docId,
    required this.name,
    required this.branchLocation,
    required this.totalBranches,
    required this.branchIndex,
    required this.isOpend,
    required this.isAvailable,
    this.imageUrl,
    this.userEmail,
    this.createdAt,
  });

  // ── from Firestore document ───────────────────────────────────────────────
  factory RestaurantModel.fromFirestore(
      Map<String, dynamic> json, String docId) {
    // Safe timestamp parsing - handles both Timestamp and FieldValue
    DateTime? parsedCreatedAt;
    final rawCreatedAt = json['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      parsedCreatedAt = rawCreatedAt;
    }
    // FieldValue (serverTimestamp) will be null until server resolves it

    return RestaurantModel(
      docId: docId,
      name: json['name'] as String? ?? '',
      branchLocation: json['branchLocation'] as String? ?? '',
      totalBranches: json['totalBranches'] as int? ?? 1,
      branchIndex: json['branchIndex'] as int? ?? 1,
      isOpend: json['isOpend'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      userEmail: json['userEmail'] as String?,
      createdAt: parsedCreatedAt,
    );
  }

  // ── from domain entity ────────────────────────────────────────────────────
  factory RestaurantModel.fromEntity(RestaurantEntity entity) {
    return RestaurantModel(
      docId: entity.docId,
      name: entity.name,
      branchLocation: entity.branchLocation,
      totalBranches: entity.totalBranches,
      branchIndex: entity.branchIndex,
      isOpend: entity.isOpend,
      isAvailable: entity.isAvailable,
      imageUrl: entity.imageUrl,
      userEmail: entity.userEmail,
    );
  }

  // ── to Firestore JSON (never include docId in the document body) ──────────
  Map<String, dynamic> toJson() => {
        'name': name,
        'branchLocation': branchLocation,
        'totalBranches': totalBranches,
        'branchIndex': branchIndex,
        'isOpend': isOpend,
        'isAvailable': isAvailable,
        'imageUrl': imageUrl,
        'userEmail': userEmail,
        'createdAt': FieldValue.serverTimestamp(),
      };

  // ── update JSON (preserve original createdAt) ─────────────────────────────
  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'branchLocation': branchLocation,
        'totalBranches': totalBranches,
        'branchIndex': branchIndex,
        'isOpend': isOpend,
        'isAvailable': isAvailable,
        'imageUrl': imageUrl,
        'userEmail': userEmail,
      };

  // ── to domain entity ──────────────────────────────────────────────────────
  RestaurantEntity toEntity() => RestaurantEntity(
        docId: docId,
        name: name,
        branchLocation: branchLocation,
        totalBranches: totalBranches,
        branchIndex: branchIndex,
        isOpend: isOpend,
        isAvailable: isAvailable,
        imageUrl: imageUrl,
        userEmail: userEmail,
      );
}