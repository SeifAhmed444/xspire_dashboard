import 'package:bloc/bloc.dart';

import 'package:xspire_dashboard/features/auth/domain/repo/login_repo.dart';
import 'package:xspire_dashboard/features/auth/presentation/manager/Login_cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo loginRepo;
  LoginCubit(this.loginRepo) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoadingState());
    var result = await loginRepo.login(email, password);
    result.fold(
      (l) => emit(LoginfailureState(l.message)),
      (r) => emit(LoginSuccesState()),
    );
  }

  Future<void> logout() async {
    emit(LoginLoadingState());
    var result = await loginRepo.logout();
    result.fold(
      (l) => emit(LoginfailureState(l.message)),
      (r) => emit(LogoutSuccessState()),
    );
  }

  Future<void> checkAuthStatus() async {
    emit(LoginLoadingState());
    var result = await loginRepo.checkAuthStatus();
    result.fold(
      (l) => emit(LoginfailureState(l.message)),
      (r) {
        if (r != null) {
          emit(LoginSuccesState());
        } else {
          emit(LoginInitial());
        }
      },
    );
  }
}
