import 'dart:io';

/// Core domain entity — no dependency on any framework or data layer.
/// Each branch is stored as a separate restaurant with the same name.
class RestaurantEntity {
  final String? docId;       // Firestore document ID
  final String name;
  final String branchLocation;  // Location of this specific branch
  final int totalBranches;      // Total number of branches for this restaurant
  final int branchIndex;        // Index of this branch (1, 2, 3, ...)
  final bool isOpend;
  final bool isAvailable;
  final String? imageUrl;    // Remote URL (Supabase)
  final File? imageFile;     // Local file picked by the user (edit flow)
  final String? userEmail;

  const RestaurantEntity({
    this.docId,
    required this.name,
    required this.branchLocation,
    required this.totalBranches,
    required this.branchIndex,
    required this.isOpend,
    required this.isAvailable,
    this.imageUrl,
    this.imageFile,
    this.userEmail,
  });

  String get displayName => totalBranches > 1 ? '$name - Branch $branchIndex' : name;
  
  String get branchesDisplay => '$totalBranches branch${totalBranches > 1 ? 'es' : ''}';

  RestaurantEntity copyWith({
    String? docId,
    String? name,
    String? branchLocation,
    int? totalBranches,
    int? branchIndex,
    bool? isOpend,
    bool? isAvailable,
    String? imageUrl,
    File? imageFile,
    String? userEmail,
  }) {
    return RestaurantEntity(
      docId: docId ?? this.docId,
      name: name ?? this.name,
      branchLocation: branchLocation ?? this.branchLocation,
      totalBranches: totalBranches ?? this.totalBranches,
      branchIndex: branchIndex ?? this.branchIndex,
      isOpend: isOpend ?? this.isOpend,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}