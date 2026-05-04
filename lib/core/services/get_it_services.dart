import 'package:get_it/get_it.dart';

// ── Core ──────────────────────────────────────────────────────────────────────
import 'package:xspire_dashboard/core/repos/image_repo/image_repo.dart';
import 'package:xspire_dashboard/core/repos/image_repo/image_repo_impl.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo_impl.dart';
import 'package:xspire_dashboard/core/services/database_services.dart';
import 'package:xspire_dashboard/core/services/firestore_services.dart';
import 'package:xspire_dashboard/core/services/storage_service.dart';
import 'package:xspire_dashboard/core/services/supabase_storage.dart';
import 'package:xspire_dashboard/core/services/food_detection_service.dart';

// ── Auth ──────────────────────────────────────────────────────────────────────
import 'package:xspire_dashboard/features/auth/data/repo/login_repo_impl.dart';
import 'package:xspire_dashboard/features/auth/domain/repo/login_repo.dart';

// ── Manage Data — NEW clean-arch restaurant feature ───────────────────────────
import 'package:xspire_dashboard/features/manage_data/data/datasources/restaurant_remote_datasource.dart';
import 'package:xspire_dashboard/features/manage_data/data/repos/restaurant_repository_impl.dart';
import 'package:xspire_dashboard/features/manage_data/domain/repos/restaurant_repository.dart';
import 'package:xspire_dashboard/features/manage_data/domain/usecases/restaurant_usecases.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  // ── Infrastructure ────────────────────────────────────────────────────────
  getIt.registerSingleton<StorageService>(SupabaseStorageService());
  getIt.registerSingleton<DatabaseServies>(FirestoreServices());
  getIt.registerSingleton<FoodDetectionService>(FoodDetectionService()..init());

  // ── Legacy repos (kept for AddProductCubit) ───────────────────────────────
  getIt.registerSingleton<ImageRepo>(
      ImageRepoImpl(getIt.get<StorageService>()));
  getIt.registerSingleton<ProductsRepo>(
      ProductsRepoImpl(getIt.get<DatabaseServies>()));

  // ── Auth ──────────────────────────────────────────────────────────────────
  getIt.registerSingleton<LoginRepo>(LoginRepoImpl());

  // ── Restaurant feature ────────────────────────────────────────────────────
  getIt.registerSingleton<RestaurantRemoteDatasource>(
    RestaurantRemoteDatasourceImpl(),
  );
  getIt.registerSingleton<RestaurantRepository>(
    RestaurantRepositoryImpl(getIt.get<RestaurantRemoteDatasource>()),
  );
  getIt.registerSingleton<FetchRestaurantsUseCase>(
    FetchRestaurantsUseCase(getIt.get<RestaurantRepository>()),
  );
  getIt.registerSingleton<AddRestaurantUseCase>(
    AddRestaurantUseCase(getIt.get<RestaurantRepository>()),
  );
  getIt.registerSingleton<UpdateRestaurantUseCase>(
    UpdateRestaurantUseCase(getIt.get<RestaurantRepository>()),
  );
  getIt.registerSingleton<DeleteRestaurantUseCase>(
    DeleteRestaurantUseCase(getIt.get<RestaurantRepository>()),
  );
  getIt.registerSingleton<UploadRestaurantImageUseCase>(
    UploadRestaurantImageUseCase(getIt.get<RestaurantRepository>()),
  );
}