import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/constant.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/core/services/app_user.dart';
import 'package:xspire_dashboard/core/services/shared_preferences_singletone.dart';
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
      return right(
        AppUser(id: 'manual_${email.split('@').first}', email: email),
      );
    } else {
      return left(ServerFailure("Not a managed user"));
    }
  }
}
