// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../core/utils/result.dart';

class AuthState {
  final User? currentUser;
  final bool isLoading;
  final String? error;
  final String role;

  AuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
    this.role = 'user',
  });

  AuthState copyWith({
    User? currentUser,
    bool? isLoading,
    String? error,
    String? role,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      role: role ?? this.role,
    );
  }
}

class AuthProvider extends ValueNotifier<AuthState> {
  final AuthService _authService;

  AuthProvider(this._authService) : super(AuthState(currentUser: _authService.getCurrentUser())) {
    _initRole();
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        final roleResult = await UserService().getRoleByUid(user.uid);
        final role = roleResult is Success<String, Exception> ? (roleResult as Success<String, Exception>).value : 'user';
        value = value.copyWith(
          currentUser: user, 
          clearUser: false,
          clearError: true,
          isLoading: false,
          role: role,
        );
      } else {
        value = value.copyWith(
          clearUser: true,
          clearError: true,
          isLoading: false,
          role: 'user',
        );
      }
    });
  }

  Future<void> refreshCurrentUser() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      await user.reload();
      final refreshedUser = _authService.getCurrentUser();
      value = value.copyWith(currentUser: refreshedUser, clearError: true);
    }
  }

  Future<void> _initRole() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      final roleResult = await UserService().getRoleByUid(user.uid);
      final role = roleResult is Success<String, Exception> ? (roleResult as Success<String, Exception>).value : 'user';
      value = value.copyWith(role: role);
    }
  }

  Future<void> register(String email, String password) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _authService.signUpWithEmail(email, password);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      await refreshCurrentUser();
    }
  }

  Future<void> login(String email, String password) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _authService.signInWithEmail(email, password);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
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
