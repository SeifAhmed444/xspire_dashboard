class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  String? _email;

  String get currentEmail {
    assert(_email != null, 'UserSession: لم يتم تعيين البريد بعد اللوجين');
    return _email!;
  }

  bool get isLoggedIn => _email != null;

  void setUser(String email) {
    _email = email;
  }

  void clear() {
    _email = null;
  }
}