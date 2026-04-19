// lib/features/manage_data/domain/entities/local_data_entity.dart

class LocalDataEntity {
  final String id;
  final String name;
  final String branches;
  final String distance;
  final bool isOpend;
  final bool isAvailable;
  final String? imageUrl;

  const LocalDataEntity({
    required this.id,
    required this.name,
    required this.branches,
    required this.distance,
    required this.isOpend,
    required this.isAvailable,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'branches': branches,
        'distance': distance,
        'isOpend': isOpend,
        'isAvailable': isAvailable,
        'imageUrl': imageUrl,
      };

  factory LocalDataEntity.fromJson(Map<String, dynamic> json) {
    return LocalDataEntity(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      branches: json['branches'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      isOpend: json['isOpend'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
