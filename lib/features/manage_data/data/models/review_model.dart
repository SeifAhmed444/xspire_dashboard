import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/restaurant_entity.dart';

class ReviewModel {
  final String? id;
  final String? userId;
  final String? name;
  final String? image;
  final String? review;
  final int? rating;
  final DateTime? date;

  ReviewModel({
    this.id,
    this.userId,
    this.name,
    this.image,
    this.review,
    this.rating,
    this.date,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDate;
    final raw = map['date'];

    // Handle Firestore Timestamp objects
    if (raw is Timestamp) {
      parsedDate = raw.toDate();
    }
    // Handle ISO 8601 strings
    else if (raw is String) {
      try {
        parsedDate = DateTime.tryParse(raw);
      } catch (_) {}
    }

    return ReviewModel(
      id: map['id'] as String?,
      userId: map['userId'] as String?,
      name: map['name'] as String?,
      image: map['image'] as String?,
      review: map['review'] as String?,
      rating: map['rating'] is int
          ? map['rating'] as int
          : int.tryParse('${map['rating']}'),
      date: parsedDate,
    );
  }

  ReviewEntity toEntity() => ReviewEntity(
    id: id,
    userId: userId,
    name: name,
    image: image,
    review: review,
    rating: rating,
    date: date,
  );
}
