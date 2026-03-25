import 'dart:io';

import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

class AddProductInputModel {
  final String name;
  final String description;
  final num price;
  final String code;
  final bool isFeatured;
  final File image;
  String? imageUrl;

  AddProductInputModel(
    {required this.name, 
    required this.description, 
    required this.price, 
    required this.code, 
    required this.isFeatured, 
    required this.image, 
    this.imageUrl});

  factory AddProductInputModel.fromEntity(AddProductInputEntity) {
    return AddProductInputModel(
      name: AddProductInputEntity.name,
      description: AddProductInputEntity.description,
      price: AddProductInputEntity.price,
      code: AddProductInputEntity.code,
      isFeatured: AddProductInputEntity.isFeatured,
      image: AddProductInputEntity.image,
      imageUrl: AddProductInputEntity.imageUrl,
    );
  }

  toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'code': code,
      'isFeatured': isFeatured,
      'imageUrl': imageUrl,
    };
  }
  
}
