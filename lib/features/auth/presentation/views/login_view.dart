// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/features/auth/domain/repo/login_repo.dart';
import 'package:xspire_dashboard/features/auth/presentation/cubit/login_cubit.dart';
import 'package:xspire_dashboard/features/auth/presentation/views/widgets/login_bloc_listener.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  static const routeName = 'LoginView';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocProvider(
          create: (context) => LoginCubit(getIt.get<LoginRepo>()),
          child: const LoginViewBodyBlocConsumer(),
        ),
      ),
    );
  }
}