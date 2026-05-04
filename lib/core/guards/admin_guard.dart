import '../../providers/auth_provider.dart';

class AdminGuard {
  static bool isAdmin(AuthProvider authProvider) {
    return authProvider.value.role == 'admin';
  }
}
