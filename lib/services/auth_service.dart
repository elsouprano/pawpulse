// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/result.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? getCurrentUser() => _auth.currentUser;

  Future<Result<User, AuthException>> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return Success(credential.user!);
      }
      return Failure(AuthException('User creation failed: Unknown error'));
    } on FirebaseAuthException catch (e) {
      return Failure(AuthException(e.message ?? 'Authentication error'));
    } catch (e) {
      return Failure(AuthException(e.toString()));
    }
  }

  Future<Result<User, AuthException>> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return Success(credential.user!);
      }
      return Failure(AuthException('Sign in failed: Unknown error'));
    } on FirebaseAuthException catch (e) {
      return Failure(AuthException(e.message ?? 'Authentication error'));
    } catch (e) {
      return Failure(AuthException(e.toString()));
    }
  }

  Future<Result<void, AuthException>> signOut() async {
    try {
      await _auth.signOut().timeout(
        const Duration(milliseconds: 500), 
        onTimeout: () {},
      );
      return const Success(null);
    } catch (e) {
      return Failure(AuthException(e.toString()));
    }
  }

  Future<Result<void, AuthException>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      return Failure(AuthException(e.message ?? 'Password reset error'));
    } catch (e) {
      return Failure(AuthException(e.toString()));
    }
  }

  Future<Result<void, AuthException>> deleteAccount() async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
        return const Success(null);
      }
      return Failure(AuthException('No user logged in'));
    } on FirebaseAuthException catch (e) {
      return Failure(AuthException(e.message ?? 'Delete account error'));
    } catch (e) {
      return Failure(AuthException(e.toString()));
    }
  }
}
