// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/features/auth/domain/repo/login_repo.dart';
import 'package:xspire_dashboard/features/auth/presentation/manager/Login_cubit/login_cubit.dart';
import 'package:xspire_dashboard/features/auth/presentation/views/widgets/login_view_body_bloc_consumer.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  static const routeName = 'LoginView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFAFAFA),
              const Color(0xFFF0F4F3).withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1F5E3B).withOpacity(0.1),
                      const Color(0xFF1F5E3B).withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF4A91F).withOpacity(0.08),
                      const Color(0xFFF4A91F).withOpacity(0.03),
                    ],
                  ),
                ),
              ),
            ),
            // Login content
            Center(
              child: BlocProvider(
                create: (context) => LoginCubit(getIt.get<LoginRepo>()),
                child: const LoginViewBodyBlocConsumer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
