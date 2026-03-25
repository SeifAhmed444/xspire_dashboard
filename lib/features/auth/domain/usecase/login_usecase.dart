import 'package:xspire_dashboard/features/auth/domain/repo/login_repo.dart';

abstract class UseCase<T, P> {
  Future<T> call(P params);
}

class LoginUseCase {
  final LoginRepo repo;

  LoginUseCase(this.repo);
}