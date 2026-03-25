import 'package:flutter/material.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/add_product_view.dart';
import 'package:xspire_dashboard/features/dashboard/view/dashboard_view.dart';

Route<dynamic> onGenerateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case DashboardView.routeName:
      return MaterialPageRoute(builder: (context) => const DashboardView());
      
    case AddProductView.routeName:
      return MaterialPageRoute(builder: (context) => const AddProductView());
    
    default:
      return MaterialPageRoute(builder: (context) => const Scaffold());
  }
}