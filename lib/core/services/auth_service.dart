

import 'package:xspire_dashboard/core/services/app_user.dart';

abstract class AuthService {
  Future<AppUser> signIn(String email, String password);
}