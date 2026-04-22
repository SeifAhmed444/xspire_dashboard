import 'dart:io';
import 'package:path/path.dart' as b;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xspire_dashboard/core/services/storage_service.dart';
import 'package:xspire_dashboard/core/utils/supabase_key.dart';

class SupabaseStorageService implements StorageService {
  static late Supabase _supabase;

  static Future<void> createBuckets(String bucketName) async {
    final buckets = await _supabase.client.storage.listBuckets();
    final exists = buckets.any((b) => b.id == bucketName);
    if (!exists) {
      await _supabase.client.storage.createBucket(bucketName);
    }
  }

  static Future<void> initSupabase() async {
    _supabase = await Supabase.initialize(
      url: SupabaseKey.KSupabaseUrl,
      anonKey: SupabaseKey.KSupabaseKey,
    );
  }

  @override
  Future<String> uploadFile(File file, String path) async {
    // basename already contains the extension — do NOT append it again.
    final String fileName = b.basename(file.path);
    final String uploadPath = '$path/$fileName';

    await _supabase.client.storage
        .from('food_images')
        .upload(uploadPath, file);

    try {
      final String publicUrl = _supabase.client.storage
          .from('food_images')
          .getPublicUrl(uploadPath);
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }
}
