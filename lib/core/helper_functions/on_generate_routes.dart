import 'package:flutter/material.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/add_product_view.dart';
import 'package:xspire_dashboard/features/auth/presentation/views/Login_view.dart';
import 'package:xspire_dashboard/features/dashboard/view/dashboard_view.dart';
import 'package:xspire_dashboard/features/products/presentation/views/edit_product_view.dart';
import 'package:xspire_dashboard/features/products/presentation/views/products_list_view.dart';

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

    case ProductsListView.routeName:
      return MaterialPageRoute(
        builder: (_) => const ProductsListView(),
      );

    case EditProductView.routeName:
      final product = settings.arguments as AddProductInputEntity;
      return MaterialPageRoute(
        builder: (_) => EditProductView(product: product),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
  }
}
