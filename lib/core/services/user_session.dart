class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  String? _email;
  String? _userId;

  String get currentEmail {
    assert(_email != null, 'UserSession: لم يتم تعيين البريد بعد اللوجين');
    return _email!;
  }

  String get currentUserId {
    assert(_userId != null, 'UserSession: لم يتم تعيين معرف المستخدم بعد اللوجين');
    return _userId!;
  }

  bool get isLoggedIn => _email != null;

  void setUser(String email, {String? userId}) {
    _email = email;
    _userId = userId;
  }

  void clear() {
    _email = null;
    _userId = null;
  }
}