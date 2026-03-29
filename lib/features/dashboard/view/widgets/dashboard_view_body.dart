import 'package:flutter/material.dart';
import 'package:xspire_dashboard/constant.dart';
import 'package:xspire_dashboard/core/services/shared_preferences_singletone.dart';
import 'package:xspire_dashboard/core/widgets/custom_button.dart';
import 'package:xspire_dashboard/core/widgets/special_logout_button.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/add_product_view.dart';

class DashboardViewBody extends StatelessWidget {
  const DashboardViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add Data Button
            CustomButton(
              onPressed: () {
                Navigator.pushNamed(context, AddProductView.routeName);
              },
              text: 'Add Data',
              useGradient: true,
              fontSize: 16,
            ),
            const SizedBox(height: 24),

            // Logout Button
            SpecialLogoutButton(
              onPressed: () {
                Prefs.setBool(isloggedin, false);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'LoginView',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
