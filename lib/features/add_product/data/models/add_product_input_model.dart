import 'dart:io';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

class AddProductInputModel {
  final String? docId;
  final bool isAvailable;
  final String title;
  final double price;
  final double? oldPrice;
  final int bagsLeft;
  final List<String>? detectedItems;
  final String? userEmail;
  final File? image;
  String? imageUrl;
  final String? restaurantId;
  final String? restaurantName;
  final String? pickupTime;

  AddProductInputModel({
    this.docId,
    required this.isAvailable,
    required this.title,
    required this.price,
    this.oldPrice,
    required this.bagsLeft,
    this.detectedItems,
    this.userEmail,
    this.image,
    this.imageUrl,
    this.restaurantId,
    this.restaurantName,
    this.pickupTime,
  });

  factory AddProductInputModel.fromEntity(AddProductInputEntity entity) {
    return AddProductInputModel(
      docId: entity.docId,
      isAvailable: entity.isAvailable,
      title: entity.title,
      price: entity.price,
      oldPrice: entity.oldPrice,
      bagsLeft: entity.bagsLeft,
      detectedItems: entity.detectedItems,
      userEmail: entity.userEmail,
      image: entity.image,
      imageUrl: entity.imageUrl,
      restaurantId: entity.restaurantId,
      restaurantName: entity.restaurantName,
      pickupTime: entity.pickupTime,
    );
  }

  factory AddProductInputModel.fromJson(Map<String, dynamic> json) {
    return AddProductInputModel(
      docId: json['docId'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? false,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (json['oldPrice'] as num?)?.toDouble(),
      bagsLeft: json['bagsLeft'] as int? ?? 0,
      detectedItems: (json['detectedItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userEmail: json['userEmail'] as String?,
      imageUrl: json['imageUrl'] as String?,
      restaurantId: json['restaurantId'] as String?,
      restaurantName: json['restaurantName'] as String?,
      pickupTime: json['pickupTime'] as String?,
    );
  }

  AddProductInputEntity toEntity() {
    return AddProductInputEntity(
      docId: docId,
      isAvailable: isAvailable,
      title: title,
      price: price,
      oldPrice: oldPrice,
      bagsLeft: bagsLeft,
      pickupTime: pickupTime,
      detectedItems: detectedItems,
      userEmail: userEmail,
      image: image,
      imageUrl: imageUrl,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'isAvailable': isAvailable,
      'title': title,
      'price': price,
      'bagsLeft': bagsLeft,
      'detectedItems': detectedItems,
      'userEmail': userEmail,
      'imageUrl': imageUrl,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'oldPrice': oldPrice,
      'pickupTime': pickupTime,
    };
  }
}
