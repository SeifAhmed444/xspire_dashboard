import 'dart:io';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

class AddProductInputModel {
  final String? docId;
  final bool isAvailable;
  final String title;
  final double price;
  final double oldPrice;
  final int bagsLeft;
  final double rating;
  final List<String>? detectedItems;
  final String? userEmail;
  final File? image;
  String? imageUrl;
  String? docId;    
  String? userEmail;        
  final String? price;

  AddProductInputModel({
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

  factory AddProductInputModel.fromEntity(AddProductInputEntity entity) {
    return AddProductInputModel(
      docId: entity.docId,
      isAvailable: entity.isAvailable,
      title: entity.title,
      price: entity.price,
      oldPrice: entity.oldPrice,
      bagsLeft: entity.bagsLeft,
      rating: entity.rating,
      detectedItems: entity.detectedItems,
      userEmail: entity.userEmail,
      image: entity.image,
      imageUrl: entity.imageUrl,
      docId: entity.docId,
      userEmail: entity.userEmail,
      price: entity.price,
    );
  }

  factory AddProductInputModel.fromJson(Map<String, dynamic> json) {
    return AddProductInputModel(
      docId: json['docId'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? false,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (json['oldPrice'] as num?)?.toDouble() ?? 0.0,
      bagsLeft: json['bagsLeft'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      detectedItems: (json['detectedItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userEmail: json['userEmail'] as String?,
      price: json['price'] as String?,
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
      rating: rating,
      detectedItems: detectedItems,
      userEmail: userEmail,
      image: image,
      imageUrl: imageUrl,
      userEmail: userEmail,
      price: price,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'distance': distance,
      'branches': branches,
      'isOpend': isOpend,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'userEmail': userEmail,
      'price': price,
    };
  }
}