import 'dart:io';

class AddProductInputEntity {
  final String name;
  final String description;
  final num price;
  final String code;
  final bool isFeatured;
  final File image;
  String? imageUrl;

  AddProductInputEntity(
    {required this.name, 
    required this.description, 
    required this.price, 
    required this.code, 
    required this.isFeatured, 
    required this.image, 
    this.imageUrl});

  
}
