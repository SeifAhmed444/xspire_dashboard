import 'dart:io';

class AddProductInputEntity {
  final String? docId;
  final bool isAvailable;
  final String title;
  final double price;
  final double oldPrice;
  final int bagsLeft;
  final double rating;
  final List<String>? detectedItems;
  String? userEmail;
  final File? image;
  String? imageUrl;
  String? docId;
  String? userEmail;
  final String? price;

  AddProductInputEntity({
    this.docId,
    required this.isAvailable,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.bagsLeft,
    required this.rating,
    this.detectedItems,
    this.userEmail,
    this.image,
    this.imageUrl,
    this.docId,
    this.userEmail,
    this.price,
  });
}