import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/features/auth/presentation/manager/Login_cubit/login_cubit.dart';
import 'package:xspire_dashboard/features/dashboard/view/widgets/dashboard_view_body.dart';

class DashboardView extends StatelessWidget {
  static const routeName = 'dashboard';

  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(getIt()),
      child: const DashboardViewBody(),
    );
  }
}
