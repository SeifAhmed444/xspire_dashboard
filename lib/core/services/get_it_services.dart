import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:xspire_dashboard/core/repos/image_repo/image_repo.dart';
import 'package:xspire_dashboard/core/repos/image_repo/image_repo_impl.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo_impl.dart';
import 'package:xspire_dashboard/core/services/database_services.dart';
import 'package:xspire_dashboard/core/services/fire_storage.dart';
import 'package:xspire_dashboard/core/services/firestore_services.dart';
import 'package:xspire_dashboard/core/services/storage_service.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<StorageService>(FireStorage());
  getIt.registerSingleton<DatabaseServies>(FirestoreServices());
  getIt.registerSingleton<ImageRepo>(
    ImageRepoImpl(getIt.get<StorageService>()),
  );
  getIt.registerSingleton<ProductsRepo>(
    ProductsRepoImpl(getIt.get<DatabaseServies>()),
  );
}
