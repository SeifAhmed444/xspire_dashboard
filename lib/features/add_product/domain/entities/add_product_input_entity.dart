import 'dart:io';

class AddProductInputEntity {
  final String? docId;
  final bool isAvailable;
  final String title;
  final double price;
  final double? oldPrice;
  final int bagsLeft;
  final List<String>? detectedItems;
  final File? image;
  String? imageUrl;
  String? userEmail;
  String? restaurantId;
  String? restaurantName;
  final String? pickupTime;

  AddProductInputEntity({
    this.docId,
    required this.isAvailable,
    required this.title,
    required this.price,
    this.oldPrice,
    required this.bagsLeft,
    this.detectedItems,
    this.image,
    this.imageUrl,
    this.userEmail,
    this.restaurantId,
    this.restaurantName,
    this.pickupTime,
  });
}