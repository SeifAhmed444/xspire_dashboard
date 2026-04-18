import 'dart:io';

class AddProductInputEntity {
  final String name;
  final String distance;
  final String branches;
  final bool isOpend;
  final bool isAvailable;
  final File? image;
  String? imageUrl;
  String? docId;

  AddProductInputEntity({
    required this.name,
    required this.distance,
    required this.branches,
    required this.isOpend,
    required this.isAvailable,
    this.image,
    this.imageUrl,
    this.docId,
  });
}
