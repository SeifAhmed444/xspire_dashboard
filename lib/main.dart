import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xspire_dashboard/core/helper_functions/on_generate_routes.dart';
import 'package:xspire_dashboard/core/services/custom_bolc_observer.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/core/services/supabase_storage.dart';
import 'package:xspire_dashboard/features/auth/presentation/views/Login_view.dart';
import 'package:xspire_dashboard/features/dashboard/view/dashboard_view.dart';
import 'package:xspire_dashboard/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseStorageService.initSupabase();
  await SupabaseStorageService.createBuckets('food_images');
  Bloc.observer = CustomBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupGetIt();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: LoginView.routeName,
      onGenerateRoute: onGenerateRoutes,
    );
  }
}
