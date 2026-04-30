import 'dart:io';

class AddProductInputEntity {
  final String? docId;
  final String name;
  final String logoImage;
  final String branches;
  final String distance;
  final bool isAvailable;
  final bool isOpenNow;
  final String title;
  final double price;
  final double oldPrice;
  final int bagsLeft;
  final double rating;
  final List<String>? detectedItems;
  String? userEmail;
  final File? image;
  String? imageUrl;
  bool isOpend;

  AddProductInputEntity({
    this.docId,
    required this.name,
    required this.logoImage,
    required this.branches,
    required this.distance,
    required this.isAvailable,
    required this.isOpenNow,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.bagsLeft,
    required this.rating,
    this.detectedItems,
     this .userEmail,
    this.image,
    this.imageUrl,
    this.isOpend = false,
  });
}