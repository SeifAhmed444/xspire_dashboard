// lib/features/manage_data/data/datasources/manage_data_local_datasource.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xspire_dashboard/core/errors/exceptions.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/local_data_entity.dart';

// ── المفتاح المستخدم لحفظ البيانات في SharedPreferences ──────────────────────
// يجب أن يتطابق مع المفتاح الذي يستخدمه AddProductCubit عند الحفظ
const String kCachedRestaurantsKey = 'cached_restaurants';

abstract class ManageDataLocalDatasource {
  Future<List<LocalDataEntity>> getLocalData();
  Future<void> deleteLocalData(String id);
}

class ManageDataLocalDatasourceImpl implements ManageDataLocalDatasource {
  @override
  Future<List<LocalDataEntity>> getLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kCachedRestaurantsKey);
      if (raw == null || raw.isEmpty) return [];

      final List decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => LocalDataEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CustomException(message: 'Failed to load local data: $e');
    }
  }

  @override
  Future<void> deleteLocalData(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kCachedRestaurantsKey);
      if (raw == null || raw.isEmpty) return;

      final List decoded = jsonDecode(raw) as List;
      decoded.removeWhere((e) => e['id'] == id);
      await prefs.setString(kCachedRestaurantsKey, jsonEncode(decoded));
    } catch (e) {
      throw CustomException(message: 'Failed to delete item: $e');
    }
  }
}
