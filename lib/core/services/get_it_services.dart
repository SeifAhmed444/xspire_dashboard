import 'package:get_it/get_it.dart';
import 'package:xspire_dashboard/core/repos/image_repo/image_repo.dart';
import 'package:xspire_dashboard/core/repos/image_repo/image_repo_impl.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo_impl.dart';

import 'package:xspire_dashboard/core/services/database_services.dart';
import 'package:xspire_dashboard/core/services/firestore_services.dart';
import 'package:xspire_dashboard/core/services/storage_service.dart';
import 'package:xspire_dashboard/core/services/supabase_storage.dart';
import 'package:xspire_dashboard/features/auth/data/repo/login_repo_impl.dart';
import 'package:xspire_dashboard/features/auth/domain/repo/login_repo.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<StorageService>(SupabaseStorageService());
  getIt.registerSingleton<DatabaseServies>(FirestoreServices());
  getIt.registerSingleton<ImageRepo>(
    ImageRepoImpl(getIt.get<StorageService>()),
  );
  getIt.registerSingleton<ProductsRepo>(
    ProductsRepoImpl(getIt.get<DatabaseServies>()),
  );
  getIt.registerSingleton<LoginRepo>(LoginRepoImpl());
}
