import 'package:flutter/material.dart';
import 'package:xspire_dashboard/features/dashboard/view/widgets/dashboard_view_body.dart';

class DashboardView extends StatelessWidget {
  static const routeName = 'dashboard';

  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardViewBody();
  }
}
