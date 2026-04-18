import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xspire_dashboard/core/services/database_services.dart';

class FirestoreServices implements DatabaseServies {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      if (documentId != null) {
        await firestore.collection(path).doc(documentId).set(data);
      } else {
        await firestore.collection(path).add(data);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> getData({
    required String path,
    String? docuementId,
    Map<String, dynamic>? query,
  }) async {
    if (docuementId != null) {
      final doc = await firestore.collection(path).doc(docuementId).get();
      return {'docId': doc.id, ...?doc.data()};
    } else {
      Query<Map<String, dynamic>> ref = firestore.collection(path);

      if (query != null) {
        if (query['orderBy'] != null) {
          ref = ref.orderBy(
            query['orderBy'],
            descending: query['descending'] ?? false,
          );
        }
        if (query['limit'] != null) {
          ref = ref.limit(query['limit']);
        }
      }

      final result = await ref.get();
      // include docId inside every document map
      return result.docs.map((e) => {'docId': e.id, ...e.data()}).toList();
    }
  }

  @override
  Future<void> updateData({
    required String path,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore.collection(path).doc(documentId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> checkifDataExists({
    required String path,
    required String documentId,
  }) async {
    final doc = await firestore.collection(path).doc(documentId).get();
    return doc.exists;
  }
}
