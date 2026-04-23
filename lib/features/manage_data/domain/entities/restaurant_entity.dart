import 'dart:io';

/// Core domain entity — no dependency on any framework or data layer.
class RestaurantEntity {
  final String? docId;       // Firestore document ID
  final String name;
  final String branches;
  final String distance;
  final bool isOpend;
  final bool isAvailable;
  final String? imageUrl;    // Remote URL (Supabase)
  final File? imageFile;     // Local file picked by the user (edit flow)
  final String? userEmail;

  const RestaurantEntity({
    this.docId,
    required this.name,
    required this.branches,
    required this.distance,
    required this.isOpend,
    required this.isAvailable,
    this.imageUrl,
    this.imageFile,
    this.userEmail,
  });

  RestaurantEntity copyWith({
    String? docId,
    String? name,
    String? branches,
    String? distance,
    bool? isOpend,
    bool? isAvailable,
    String? imageUrl,
    File? imageFile,
    String? userEmail,
  }) {
    return RestaurantEntity(
      docId: docId ?? this.docId,
      name: name ?? this.name,
      branches: branches ?? this.branches,
      distance: distance ?? this.distance,
      isOpend: isOpend ?? this.isOpend,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}