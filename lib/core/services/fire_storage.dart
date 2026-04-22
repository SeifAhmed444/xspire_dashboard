import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as b;
import 'package:xspire_dashboard/core/services/storage_service.dart';

class FireStorage implements StorageService {
  final storageReference = FirebaseStorage.instance.ref();

  @override
  Future<String> uploadFile(File file, String path) async {
    // Use basename WITHOUT appending extension again — basename already
    // includes the extension (e.g. "photo.jpg").
    final String fileName = b.basename(file.path);
    final fileReference = storageReference.child('$path/$fileName');
    await fileReference.putFile(file);
    final fileUrl = await fileReference.getDownloadURL();
    return fileUrl;
  }
}
