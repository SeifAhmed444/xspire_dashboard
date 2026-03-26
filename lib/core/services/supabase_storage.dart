import 'dart:io';
import 'package:path/path.dart' as b;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xspire_dashboard/core/services/storage_service.dart';
import 'package:xspire_dashboard/core/utils/supabase_key.dart';

class SupabaseStorageService implements StorageService {
  static late Supabase _supabase;

  static createBuckets(String bucketName) async {
    var buckets = await _supabase.client.storage.listBuckets();

    bool isBucketExits = false;

    for (var buckete in buckets) {
      if (buckete.id == bucketName) {
        isBucketExits = true;
        break;
      }
    }
    if (!isBucketExits) {
  await _supabase.client.storage.createBucket(bucketName);
}
  }

  static initSupabase() async {
    _supabase = await Supabase.initialize(
      url: SupabaseKey.KSupabaseUrl,
      anonKey: SupabaseKey.KSupabaseKey,
    );
  }

  @override
  Future<String> uploadFile(File file, String path) async {
    String fileName = b.basename(file.path);
    String extensionName = b.extension(file.path);
    var result = await _supabase.client.storage
        .from('food_images')
        .upload('$path/$fileName.$extensionName', file);
    final String publicUrl = _supabase.client.storage
      .from('food_images')
      .getPublicUrl('$path/$fileName.$extensionName');
    return result;
  }
}
