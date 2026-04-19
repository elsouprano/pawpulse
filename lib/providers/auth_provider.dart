// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../core/utils/result.dart';

class AuthState {
  final User? currentUser;
  final bool isLoading;
  final String? error;

  AuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? currentUser,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthProvider extends ValueNotifier<AuthState> {
  final AuthService _authService;

  AuthProvider(this._authService) : super(AuthState(currentUser: _authService.getCurrentUser())) {
    _authService.authStateChanges.listen((user) {
      value = value.copyWith(
        currentUser: user, 
        clearUser: user == null,
        clearError: true,
        isLoading: false, // Fix for Windows plugin where the Future hangs but the stream fires!
      );
    });
  }

  Future<void> register(String email, String password) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _authService.signUpWithEmail(email, password);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(isLoading: false);
    }
  }

  Future<void> login(String email, String password) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _authService.signInWithEmail(email, password);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _authService.signOut();
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(isLoading: false, clearUser: true);
    }
  }

  Future<void> resetPassword(String email) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _authService.resetPassword(email);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(isLoading: false, error: 'Password reset email sent'); // Using error field to show success message briefly for test UI
    }
  }
}
