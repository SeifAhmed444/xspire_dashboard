import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xspire_dashboard/constant.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/core/services/app_user.dart';
import 'package:xspire_dashboard/core/services/shared_preferences_singletone.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/features/auth/domain/repo/login_repo.dart';

class LoginRepoImpl implements LoginRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<Either<Failure, AppUser>> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return left(ServerFailure("Authentication failed"));
      }

      await Prefs.setBool(isloggedin, true);
      await Prefs.saveEmail(email);
      UserSession.instance.setUser(email, userId: user.uid);

      return right(AppUser(id: user.uid, email: email));
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      switch (e.code) {
        case 'user-not-found':
          message = "No user found with this email";
          break;
        case 'wrong-password':
          message = "Wrong password";
          break;
        case 'invalid-email':
          message = "Invalid email format";
          break;
        case 'user-disabled':
          message = "This account has been disabled";
          break;
        default:
          message = e.message ?? "Authentication error";
      }
      return left(ServerFailure(message));
    } catch (e) {
      return left(ServerFailure("Unexpected error: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _auth.signOut();
      await Prefs.setBool(isloggedin, false);
      UserSession.instance.clear();
      return const Right(null);
    } catch (e) {
      return left(ServerFailure("Logout failed: $e"));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> checkAuthStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final email = user.email ?? '';
        UserSession.instance.setUser(email, userId: user.uid);
        return right(AppUser(id: user.uid, email: email));
      }
      return right(null);
    } catch (e) {
      return left(ServerFailure("Auth check failed: $e"));
    }
  }
}
