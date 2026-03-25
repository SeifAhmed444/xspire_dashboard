sealed class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginfailureState extends LoginState {
  final String message;
  LoginfailureState(this.message);
}

class LoginSuccesState extends LoginState {}
