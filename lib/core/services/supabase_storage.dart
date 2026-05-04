import 'dart:io';
import 'package:path/path.dart' as b;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xspire_dashboard/core/services/storage_service.dart';
import 'package:xspire_dashboard/core/utils/supabase_key.dart';

class SupabaseStorageService implements StorageService {
  static late Supabase _supabase;

  static Future<void> createBuckets(String bucketName) async {
    try {
      final buckets = await _supabase.client.storage.listBuckets();
      final exists = buckets.any((b) => b.id == bucketName);
      if (!exists) {
        await _supabase.client.storage.createBucket(bucketName);
      }
    } catch (e) {
      // Bucket creation requires service_role key, anon key doesn't have permission
      // We'll assume bucket exists or handle it in uploadFile
      print('Note: Could not verify/create bucket. Ensure "$bucketName" bucket exists in Supabase dashboard.');
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
    try {
      // Check if file exists
      if (!await file.exists()) {
        throw Exception('File does not exist: ${file.path}');
      }

      // Generate unique filename to avoid conflicts
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String originalName = b.basename(file.path);
      final String fileName = '${timestamp}_$originalName';
      final String uploadPath = '$path/$fileName';

      print('Uploading to: food_images/$uploadPath');

      // Read file bytes and upload
      final bytes = await file.readAsBytes();
      await _supabase.client.storage
          .from('food_images')
          .uploadBinary(uploadPath, bytes);

      final String publicUrl = _supabase.client.storage
          .from('food_images')
          .getPublicUrl(uploadPath);
      
      print('Upload successful: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      print('StorageException: ${e.statusCode} - ${e.message}');
      // Handle specific Supabase storage errors
      if (e.statusCode == '403' || e.message.contains('row-level security') || e.message.contains('policy')) {
        throw Exception('Storage permission denied (403). Check RLS policies allow INSERT for anon role.');
      } else if (e.statusCode == '404') {
        throw Exception('Storage bucket "food_images" not found (404).');
      } else if (e.statusCode == '400') {
        throw Exception('Bad request (400): ${e.message}');
      } else {
        throw Exception('Storage error (${e.statusCode}): ${e.message}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Upload failed: $e');
    }
  }
}
