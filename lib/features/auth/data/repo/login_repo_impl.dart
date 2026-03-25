import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/core/services/app_user.dart';
import 'package:xspire_dashboard/core/services/auth_service.dart';
import 'package:xspire_dashboard/features/auth/domain/repo/login_repo.dart';


class LoginRepoImpl implements LoginRepo {
  final AuthService firebaseAuth;

  LoginRepoImpl(this.firebaseAuth);
  @override
  Future<Either<Failure, AppUser>> login(String email, String password) async {
    if (email == 'gg@gmail.com' && password == '123456789') {
      try {
        var result = await firebaseAuth.signIn(email, password);
        return right(result);
      } on Exception catch (e) {
        return left(ServerFailure(e.toString()));
      }
    } else {
      return left(ServerFailure("Not a managed user"));
    }
  }
}