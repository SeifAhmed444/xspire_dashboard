import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';

/// Data model — handles Firestore JSON serialization only.
class RestaurantModel {
  final String? docId;
  final String name;
  final String branches;
  final String distance;
  final bool isOpend;
  final bool isAvailable;
  final String? imageUrl;
  final String? userEmail;
  final DateTime? createdAt;

  const RestaurantModel({
    this.docId,
    required this.name,
    required this.branches,
    required this.distance,
    required this.isOpend,
    required this.isAvailable,
    this.imageUrl,
    this.userEmail,
    this.createdAt,
  });

  // ── from Firestore document ───────────────────────────────────────────────
  factory RestaurantModel.fromFirestore(
      Map<String, dynamic> json, String docId) {
    return RestaurantModel(
      docId: docId,
      name: json['name'] as String? ?? '',
      branches: json['branches'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      isOpend: json['isOpend'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      userEmail: json['userEmail'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // ── from domain entity ────────────────────────────────────────────────────
  factory RestaurantModel.fromEntity(RestaurantEntity entity) {
    return RestaurantModel(
      docId: entity.docId,
      name: entity.name,
      branches: entity.branches,
      distance: entity.distance,
      isOpend: entity.isOpend,
      isAvailable: entity.isAvailable,
      imageUrl: entity.imageUrl,
      userEmail: entity.userEmail,
    );
  }

  // ── to Firestore JSON (never include docId in the document body) ──────────
  Map<String, dynamic> toJson() => {
        'name': name,
        'branches': branches,
        'distance': distance,
        'isOpend': isOpend,
        'isAvailable': isAvailable,
        'imageUrl': imageUrl,
        'userEmail': userEmail,
        'createdAt': FieldValue.serverTimestamp(),
      };

  // ── update JSON (preserve original createdAt) ─────────────────────────────
  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'branches': branches,
        'distance': distance,
        'isOpend': isOpend,
        'isAvailable': isAvailable,
        'imageUrl': imageUrl,
        'userEmail': userEmail,
      };

  // ── to domain entity ──────────────────────────────────────────────────────
  RestaurantEntity toEntity() => RestaurantEntity(
        docId: docId,
        name: name,
        branches: branches,
        distance: distance,
        isOpend: isOpend,
        isAvailable: isAvailable,
        imageUrl: imageUrl,
        userEmail: userEmail,
      );
}