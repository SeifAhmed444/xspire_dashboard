import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/features/manage_data/domain/usecases/get_local_data_usecase.dart';
import 'package:xspire_dashboard/features/manage_data/domain/usecases/delete_local_data_usecase.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/manager/manage_data_cubit.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/views/widgets/manage_data_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';

class ManageDataView extends StatelessWidget {
  const ManageDataView({super.key});
  static const routeName = 'manage_data';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ManageDataCubit(
        getLocalDataUseCase: getIt.get<GetLocalDataUseCase>(),
        deleteLocalDataUseCase: getIt.get<DeleteLocalDataUseCase>(),
      )..loadLocalData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F5),
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Manage Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const ManageDataViewBody(),
      ),
    );
  }
}
