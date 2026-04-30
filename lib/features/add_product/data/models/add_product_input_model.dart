import 'dart:io';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

class AddProductInputModel {
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
  final String? userEmail;
  final File? image;
  String? imageUrl;
  bool isOpend;

  AddProductInputModel({
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
    this.userEmail,
    this.image,
    this.imageUrl,
    this.isOpend = false,
  });

  factory AddProductInputModel.fromEntity(AddProductInputEntity entity) {
    return AddProductInputModel(
      docId: entity.docId,
      name: entity.name,
      logoImage: entity.logoImage,
      branches: entity.branches,
      distance: entity.distance,
      isAvailable: entity.isAvailable,
      isOpenNow: entity.isOpenNow,
      title: entity.title,
      price: entity.price,
      oldPrice: entity.oldPrice,
      bagsLeft: entity.bagsLeft,
      rating: entity.rating,
      detectedItems: entity.detectedItems,
      userEmail: entity.userEmail,
      image: entity.image,
      imageUrl: entity.imageUrl,
      isOpend: entity.isOpend,
    );
  }

  factory AddProductInputModel.fromJson(Map<String, dynamic> json) {
    return AddProductInputModel(
      docId: json['docId'] as String?,
      name: json['name'] as String? ?? '',
      logoImage: json['logoImage'] as String? ?? '',
      branches: json['branches'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (json['oldPrice'] as num?)?.toDouble() ?? 0.0,
      bagsLeft: json['bagsLeft'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      detectedItems: (json['detectedItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userEmail: json['userEmail'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isOpend: json['isOpend'] as bool? ?? false,
    );
  }

  AddProductInputEntity toEntity() {
    return AddProductInputEntity(
      docId: docId,
      name: name,
      logoImage: logoImage,
      branches: branches,
      distance: distance,
      isAvailable: isAvailable,
      isOpenNow: isOpenNow,
      title: title,
      price: price,
      oldPrice: oldPrice,
      bagsLeft: bagsLeft,
      rating: rating,
      detectedItems: detectedItems,
      userEmail: userEmail,
      image: image,
      imageUrl: imageUrl,
      isOpend: isOpend,
    );
  }

 Map<String, dynamic> toJson() {
    return {
      'name'         : name,
      'logoImage'    : logoImage,
      'branches'     : branches,
      'distance'     : distance,
      'isAvailable'  : isAvailable,
      'isOpenNow'    : isOpenNow,
      'title'        : title,
      'price'        : price,
      'oldPrice'     : oldPrice,
      'bagsLeft'     : bagsLeft,
      'rating'       : rating,
      'detectedItems': detectedItems ?? [],
      'userEmail'    : userEmail,   // ← موجود
      'imageUrl'     : imageUrl,
      'isOpend'      : isOpend,
    };
  }
}