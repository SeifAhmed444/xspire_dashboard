import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/localization/app_localizations.dart';
import 'package:xspire_dashboard/core/repos/image_repo/image_repo.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/core/widgets/build_app_bar.dart';
import 'package:xspire_dashboard/features/add_product/presentation/manager/cubit/add_product_cubit.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/Add_product_view_body_bloc_builder.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/cubit/restaurant_cubit.dart';

class AddProductView extends StatelessWidget {
  const AddProductView({super.key});
  static const routeName = 'add_product';
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AddProductCubit(
            getIt.get<ImageRepo>(),
            getIt.get<ProductsRepo>(),
          ),
        ),
        BlocProvider(
          create: (context) => RestaurantCubit(
            fetchRestaurantsUseCase: getIt(),
            addRestaurantUseCase: getIt(),
            updateRestaurantUseCase: getIt(),
            deleteRestaurantUseCase: getIt(),
            uploadImageUseCase: getIt(),
          )..fetchRestaurants(UserSession.instance.currentEmail),
        ),
      ],
      child: Scaffold(
        appBar: buildAppBar(AppLocalizations.of(context).addBagItem),
        body: AddProductViewBodyBlocBuilder(),
      ),
    );
  }
}


