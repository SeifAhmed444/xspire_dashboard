import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as pathLib;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xspire_dashboard/core/errors/exceptions.dart';
import 'package:xspire_dashboard/core/utils/backend_endpoints.dart';
import 'package:xspire_dashboard/features/manage_data/data/models/restaurant_model.dart';

abstract class RestaurantRemoteDatasource {
  Future<List<RestaurantModel>> fetchRestaurants(String userEmail);
  Future<RestaurantModel> addRestaurant(RestaurantModel model);
  Future<RestaurantModel> updateRestaurant(RestaurantModel model);
  Future<void> deleteRestaurant(String docId);
  Future<String> uploadImage(String filePath, String fileName);
}

class RestaurantRemoteDatasourceImpl implements RestaurantRemoteDatasource {
  static const _collection = BackendEndpoints.resturantCollection;
  static const _bucket = 'food_images';
  static const _storagePath = 'images';

  final FirebaseFirestore _firestore;
  final Supabase _supabase;

  RestaurantRemoteDatasourceImpl({
    FirebaseFirestore? firestore,
    Supabase? supabase,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _supabase = supabase ?? Supabase.instance;

  // ── Fetch all for user ────────────────────────────────────────────────────
  @override
  Future<List<RestaurantModel>> fetchRestaurants(String userEmail) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userEmail', isEqualTo: userEmail)
          .get();

      return snapshot.docs
          .map((doc) => RestaurantModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw CustomException(message: 'Failed to fetch restaurants: $e');
    }
  }

  // ── Add ───────────────────────────────────────────────────────────────────
  @override
  Future<RestaurantModel> addRestaurant(RestaurantModel model) async {
    try {
      final restaurantId = model.docId ?? const Uuid().v4();
      final data = model.toJson();
      data['restaurantId'] = restaurantId;
      data['docId'] = restaurantId;
      await _firestore.collection(_collection).doc(restaurantId).set(data);
      // Return model with assigned docId
      return RestaurantModel.fromFirestore(data, restaurantId);
    } catch (e) {
      throw CustomException(message: 'Failed to add restaurant: $e');
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────
  @override
  Future<RestaurantModel> updateRestaurant(RestaurantModel model) async {
    if (model.docId == null) {
      throw CustomException(message: 'Cannot update: docId is null');
    }
    try {
      await _firestore
          .collection(_collection)
          .doc(model.docId)
          .update(model.toUpdateJson());
      return model;
    } catch (e) {
      throw CustomException(message: 'Failed to update restaurant: $e');
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  @override
  Future<void> deleteRestaurant(String docId) async {
    try {
      // Fetch restaurant to get nested products array
      final restaurantDoc = await _firestore
          .collection(_collection)
          .doc(docId)
          .get();

      if (restaurantDoc.exists) {
        final data = restaurantDoc.data();
        final products = data?['products'] as List<dynamic>? ?? [];

        // Delete product images from Supabase
        for (final product in products) {
          final productData = product as Map<String, dynamic>?;
          if (productData != null) {
            try {
              final imageUrl = productData['imageUrl'] as String?;
              if (imageUrl != null && imageUrl.isNotEmpty) {
                String? storagePath;

                // common Supabase public url contains '/food_images/' followed by the stored path
                final marker = '/food_images/';
                final idx = imageUrl.indexOf(marker);
                if (idx != -1 && idx + marker.length < imageUrl.length) {
                  storagePath = imageUrl.substring(idx + marker.length);
                } else {
                  // try another common pattern
                  const alt = 'storage/v1/object/public/food_images/';
                  final idx2 = imageUrl.indexOf(alt);
                  if (idx2 != -1 && idx2 + alt.length < imageUrl.length) {
                    storagePath = imageUrl.substring(idx2 + alt.length);
                  }
                }

                if (storagePath != null && storagePath.isNotEmpty) {
                  try {
                    await _supabase.client.storage.from(_bucket).remove([
                      storagePath,
                    ]);
                  } catch (_) {
                    // ignore individual storage deletion errors
                  }
                }
              }
            } catch (_) {}
          }
        }
      }

      // Delete the restaurant document (nested products will be deleted with it)
      await _firestore.collection(_collection).doc(docId).delete();
    } catch (e) {
      throw CustomException(message: 'Failed to delete restaurant: $e');
    }
  }

  // ── Upload image to Supabase ──────────────────────────────────────────────
  @override
  Future<String> uploadImage(String filePath, String fileName) async {
    try {
      final file = File(filePath);
      // Use timestamp to avoid name collisions
      final uniqueName =
          '${DateTime.now().millisecondsSinceEpoch}_${pathLib.basename(fileName)}';
      final uploadPath = '$_storagePath/$uniqueName';

      await _supabase.client.storage.from(_bucket).upload(uploadPath, file);

      final publicUrl = _supabase.client.storage
          .from(_bucket)
          .getPublicUrl(uploadPath);

      return publicUrl;
    } catch (e) {
      throw CustomException(message: 'Failed to upload image: $e');
    }
  }
}
