
import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/constant.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/core/services/app_user.dart';
import 'package:xspire_dashboard/core/services/shared_preferences_singletone.dart';
import 'package:xspire_dashboard/core/services/user_session.dart'; 
import 'package:xspire_dashboard/features/auth/domain/repo/login_repo.dart';

final Map<String, String> emailAndPassword = {
  'belal@gmail.com': '123456789',
  'seif@gmail.com': '123456780',
};

class LoginRepoImpl implements LoginRepo {
  @override
  Future<Either<Failure, AppUser>> login(String email, String password) async {
    final savedPassword = emailAndPassword[email];

    if (savedPassword != null && savedPassword == password) {
      Prefs.setBool(isloggedin, true);

      final userId = 'manual_${email.split('@').first}';
      UserSession.instance.setUser(email, userId: userId);
      return right(
        AppUser(id: userId, email: email),
      );
    } else {
      return left(ServerFailure("Not a managed user"));
    }
  }
}