import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';
import 'package:xspire_dashboard/features/manage_data/data/models/review_model.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';

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
  final String? imageUrl;
  final String? restaurantId;
  final String? restaurantName;
  final String? pickupTime;
  final String? productId;
  final List<ReviewEntity> reviews;
  final double avgRating;

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
    this.productId,
    this.reviews = const [],
    this.avgRating = 0.0,
  });

  factory AddProductInputModel.fromEntity(AddProductInputEntity entity) {
    return AddProductInputModel(
      isAvailable: entity.isAvailable,
      title: entity.title,
      price: entity.price,
      oldPrice: entity.oldPrice,
      reviews: entity.reviews,
      bagsLeft: entity.bagsLeft,
      detectedItems: entity.detectedItems,
      userEmail: entity.userEmail,
      image: entity.image,
      imageUrl: entity.imageUrl,
      restaurantId: entity.restaurantId,
      restaurantName: entity.restaurantName,
      pickupTime: entity.pickupTime,
      productId: entity.productId,
      avgRating: entity.avgRating,
    );
  }

  factory AddProductInputModel.fromJson(Map<String, dynamic> json) {
    final reviewsList =
        (json['reviews'] as List<dynamic>?)
            ?.map(
              (rev) =>
                  ReviewModel.fromMap(rev as Map<String, dynamic>).toEntity(),
            )
            .toList() ??
        [];

    return AddProductInputModel(
      isAvailable: json['isAvailable'] as bool? ?? false,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (json['oldPrice'] as num?)?.toDouble(),
      bagsLeft: json['bagsLeft'] as int? ?? 0,
      reviews: reviewsList,
      detectedItems: (json['detectedItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userEmail: json['userEmail'] as String?,
      imageUrl: json['imageUrl'] as String?,
      restaurantId: json['restaurantId'] as String?,
      restaurantName: json['restaurantName'] as String?,
      pickupTime: json['pickupTime'] as String?,
      productId: json['productId'] as String?,
      docId: json['docId'] as String?,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
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
      productId: productId,
      reviews: reviews,
      avgRating: avgRating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'title': title,
      'price': price,
      'bagsLeft': bagsLeft,
      'reviews': reviews
          .map(
            (r) => ReviewModel(
              id: r.id,
              userId: r.userId,
              name: r.name,
              image: r.image,
              review: r.review,
              rating: r.rating,
              date: r.date,
            ).toJson(),
          )
          .toList(),
      'detectedItems': detectedItems,
      'userEmail': userEmail,
      'imageUrl': imageUrl,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'oldPrice': oldPrice,
      'pickupTime': pickupTime,
      'productId': productId ?? const Uuid().v4(),
      'avgRating': avgRating,
    };
  }
}
