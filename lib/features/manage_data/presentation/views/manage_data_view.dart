import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/localization/app_localizations.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/manage_data/domain/usecases/restaurant_usecases.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/cubit/restaurant_cubit.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/views/widgets/manage_restaurants_with_bags_body.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/views/widgets/restaurant_form_sheet.dart';

class ManageDataView extends StatelessWidget {
  const ManageDataView({super.key});
  static const routeName = 'manage_data';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RestaurantCubit(
        fetchRestaurantsUseCase: getIt<FetchRestaurantsUseCase>(),
        addRestaurantUseCase: getIt<AddRestaurantUseCase>(),
        updateRestaurantUseCase: getIt<UpdateRestaurantUseCase>(),
        deleteRestaurantUseCase: getIt<DeleteRestaurantUseCase>(),
        uploadImageUseCase: getIt<UploadRestaurantImageUseCase>(),
      )..fetchRestaurants(UserSession.instance.currentEmail),
      child: const _ManageDataScaffold(),
    );
  }
}

class _ManageDataScaffold extends StatelessWidget {
  const _ManageDataScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).manageRestaurants,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context
                .read<RestaurantCubit>()
                .fetchRestaurants(UserSession.instance.currentEmail),
          ),
        ],
      ),
      body: const ManageRestaurantsWithBagsBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final cubit = context.read<RestaurantCubit>();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: const RestaurantFormSheet(),
            ),
          );
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          AppLocalizations.of(context).addRestaurant,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}