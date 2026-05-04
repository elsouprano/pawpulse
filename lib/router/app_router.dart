import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/pet_model.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/auth/registration_success_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/scanner/ai_scanner_screen.dart';
import '../screens/pets/pet_detail_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/about/about_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.value.currentUser != null;
        final role = authProvider.value.role;
        final path = state.uri.path;
        final isAuthRoute =
            path == '/' ||
            path == '/login' ||
            path == '/onboarding' ||
            path == '/forgot-password';

        if (isLoggedIn) {
          if (isAuthRoute) {
            return role == 'admin' ? '/admin/dashboard' : '/dashboard';
          }
          if (role == 'admin' && path.startsWith('/dashboard')) {
            return '/admin/dashboard';
          }
          if (role == 'user' && path.startsWith('/admin')) {
            return '/dashboard';
          }
        }

        if (!isLoggedIn &&
            (path.startsWith('/admin') || path.startsWith('/dashboard'))) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegistrationScreen(),
        ),
        GoRoute(
          path: '/registration-success',
          builder: (context, state) => const RegistrationSuccessScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) =>
              const AdminDashboardScreen(initialIndex: 0),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) =>
              const AdminDashboardScreen(initialIndex: 1),
        ),
        GoRoute(
          path: '/admin/pets',
          builder: (context, state) =>
              const AdminDashboardScreen(initialIndex: 2),
        ),
        GoRoute(
          path: '/admin/appointments',
          builder: (context, state) =>
              const AdminDashboardScreen(initialIndex: 3),
        ),
        GoRoute(
          path: '/admin/health',
          builder: (context, state) =>
              const AdminDashboardScreen(initialIndex: 4),
        ),
        GoRoute(
          path: '/scanner',
          builder: (context, state) {
            final petId = state.extra as String?;
            return AiScannerScreen(overridePetId: petId);
          },
        ),
        GoRoute(
          path: '/pet-detail',
          builder: (context, state) {
            final pet = state.extra as PetModel;
            return PetDetailScreen(pet: pet);
          },
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    );
  }
}
