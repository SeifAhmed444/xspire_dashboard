import 'dart:io';

import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

class AddProductInputModel {
  final String name;
  final String distance;
  final String branches;
  final bool isOpend;
  final bool isAvailable;
  final File image;
  String? imageUrl;

  AddProductInputModel(
    {required this.name, 
    required this.distance, 
    required this.branches, 
    required this.isOpend, 
    required this.isAvailable, 
    required this.image, 
    this.imageUrl});

  factory AddProductInputModel.fromEntity(AddProductInputEntity) {
    return AddProductInputModel(
      name: AddProductInputEntity.name,
      distance: AddProductInputEntity.distance,
      branches: AddProductInputEntity.branches,
      isOpend: AddProductInputEntity.isOpend,
      isAvailable: AddProductInputEntity.isAvailable,
      image: AddProductInputEntity.image,
      imageUrl: AddProductInputEntity.imageUrl,
    );
  }

  toJson() {
    return {
      'name': name,
      'distance': distance,
      'branches': branches,
      'isOpend': isOpend,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
    };
  }
  
}
