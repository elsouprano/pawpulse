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
        await credential.user!.sendEmailVerification();
        return Success(credential.user!);
      }
      return Failure(AuthException('User creation failed: Unknown error'));
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Authentication error';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please log in instead.';
      } else if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'Please provide a valid email address.';
      }
      return Failure(AuthException(message));
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
      String message = e.message ?? 'Authentication error';
      if (e.code == 'invalid-credential' || e.code == 'wrong-password' || e.code == 'user-not-found') {
        message = 'Invalid email or password. Please try again or register if you do not have an account.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled. Please contact support.';
      } else if (e.code == 'invalid-email') {
        message = 'Please provide a valid email address.';
      }
      return Failure(AuthException(message));
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
