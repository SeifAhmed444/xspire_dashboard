import 'dart:io';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

class AddProductInputModel {
  final String name;
  final String distance;
  final String branches;
  final bool isOpend;
  final bool isAvailable;
  final File? image;        
  String? imageUrl;
  String? docId;    
  String? userEmail;        

  AddProductInputModel({
    required this.name,
    required this.distance,
    required this.branches,
    required this.isOpend,
    required this.isAvailable,
    this.image,
    this.imageUrl,
    this.docId, 
    String? userEmail,

  });

  // From entity (used when saving)
  factory AddProductInputModel.fromEntity(AddProductInputEntity entity) {
    return AddProductInputModel(
      name: entity.name,
      distance: entity.distance,
      branches: entity.branches,
      isOpend: entity.isOpend,
      isAvailable: entity.isAvailable,
      image: entity.image,
      imageUrl: entity.imageUrl,
      docId: entity.docId,

      
    );
  }

  // From Firestore JSON (used when fetching)
  factory AddProductInputModel.fromJson(Map<String, dynamic> json) {
    return AddProductInputModel(
      docId: json['docId'] as String?,
      name: json['name'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      branches: json['branches'] as String? ?? '',
      isOpend: json['isOpend'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      userEmail: json['userEmail'] as String?,
    );
  }

  // To entity (used after fetching, to pass around the app)
  AddProductInputEntity toEntity() {
    return AddProductInputEntity(
      docId: docId,
      name: name,
      distance: distance,
      branches: branches,
      isOpend: isOpend,
      isAvailable: isAvailable,
      image: image,
      imageUrl: imageUrl,
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
    };
  }
}