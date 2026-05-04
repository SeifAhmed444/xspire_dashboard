import 'package:flutter/material.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/add_product_view.dart';
import 'package:xspire_dashboard/features/auth/presentation/views/Login_view.dart';
import 'package:xspire_dashboard/features/dashboard/view/dashboard_view.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/views/manage_data_view.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/views/widgets/add_restaurant_simple.dart';

Route<dynamic> onGenerateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case DashboardView.routeName:
      return MaterialPageRoute(
        builder: (_) => const DashboardView(),
      );

    case LoginView.routeName:
      return MaterialPageRoute(
        builder: (_) => const LoginView(),
      );

    case AddProductView.routeName:
      return MaterialPageRoute(
        builder: (_) => const AddProductView(),
      );

    case ManageDataView.routeName:
      return MaterialPageRoute(
        builder: (_) => const ManageDataView(),
      );

    case AddRestaurantSimple.routeName:
      return MaterialPageRoute(
        builder: (_) => const AddRestaurantSimplePage(),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
  }
}
