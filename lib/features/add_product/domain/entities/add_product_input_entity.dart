import 'dart:io';

class AddProductInputEntity {
  final String name;
  final String distance;
  final String branches;
  bool isOpend;
  final bool isAvailable;
  final File? image;
  String? imageUrl;
  String? docId;
  String? userEmail;
  final String? price;

  AddProductInputEntity({
    required this.name,
    required this.distance,
    required this.branches,
    required this.isOpend,
    required this.isAvailable,
    this.image,
    this.imageUrl,
    this.docId,
    this.userEmail,
    this.price,
  });
}
