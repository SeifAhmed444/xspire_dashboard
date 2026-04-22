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

// manage_data
import 'package:xspire_dashboard/features/manage_data/data/data_source/manage_data_local_datasource.dart';
import 'package:xspire_dashboard/features/manage_data/data/repos/manage_data_repo_impl.dart';
import 'package:xspire_dashboard/features/manage_data/domain/repos/manage_data_repo.dart';
import 'package:xspire_dashboard/features/manage_data/domain/usecases/delete_local_data_usecase.dart';
import 'package:xspire_dashboard/features/manage_data/domain/usecases/get_local_data_usecase.dart';

// products (ProductCubit use-cases)
import 'package:xspire_dashboard/features/products/data/repos/product_repo_impl.dart';
import 'package:xspire_dashboard/features/products/domain/repos/product_repo.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/add_product_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/get_products_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/update_product_usecase.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  // ── Core services ───────────────────────────────────────────────────────────
  getIt.registerSingleton<StorageService>(SupabaseStorageService());
  getIt.registerSingleton<DatabaseServies>(FirestoreServices());

  // ── Core repos ──────────────────────────────────────────────────────────────
  getIt.registerSingleton<ImageRepo>(
    ImageRepoImpl(getIt.get<StorageService>()),
  );
  getIt.registerSingleton<ProductsRepo>(
    ProductsRepoImpl(getIt.get<DatabaseServies>()),
  );

  // ── Auth ────────────────────────────────────────────────────────────────────
  getIt.registerSingleton<LoginRepo>(LoginRepoImpl());

  // ── Manage Data (local cache) ───────────────────────────────────────────────
  getIt.registerSingleton<ManageDataLocalDatasource>(
    ManageDataLocalDatasourceImpl(),
  );
  getIt.registerSingleton<ManageDataRepo>(
    ManageDataRepoImpl(getIt.get<ManageDataLocalDatasource>()),
  );
  getIt.registerSingleton<GetLocalDataUseCase>(
    GetLocalDataUseCase(getIt.get<ManageDataRepo>()),
  );
  getIt.registerSingleton<DeleteLocalDataUseCase>(
    DeleteLocalDataUseCase(getIt.get<ManageDataRepo>()),
  );

  // ── Products (ProductCubit use-cases) ───────────────────────────────────────
  getIt.registerSingleton<ProductRepo>(ProductRepoImpl());
  getIt.registerSingleton<AddProductUseCase>(
    AddProductUseCase(getIt.get<ProductRepo>()),
  );
  getIt.registerSingleton<GetProductsUseCase>(
    GetProductsUseCase(getIt.get<ProductRepo>()),
  );
  getIt.registerSingleton<UpdateProductUseCase>(
    UpdateProductUseCase(getIt.get<ProductRepo>()),
  );
  getIt.registerSingleton<DeleteProductUseCase>(
    DeleteProductUseCase(getIt.get<ProductRepo>()),
  );
}