import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/core/services/app_user.dart';

abstract class LoginRepo {
  Future<Either<Failure, AppUser>> login(String email, String password);
}