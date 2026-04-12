import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/scanner/ai_scanner_screen.dart';
import 'screens/pets/pet_detail_screen.dart';
import 'models/pet_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If not configured, we catch to still allow the UI to load for stubbing
    debugPrint('Firebase not configured: $e');
  }

  runApp(const PawPulseApp());
}

class PawPulseApp extends StatefulWidget {
  const PawPulseApp({super.key});

  @override
  State<PawPulseApp> createState() => _PawPulseAppState();
}

class _PawPulseAppState extends State<PawPulseApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(AuthService());

    _router = GoRouter(
      initialLocation: '/onboarding',
      refreshListenable: _authProvider,
      redirect: (context, state) {
        final isLoggedIn = _authProvider.value.currentUser != null;
        final path = state.uri.path;
        final isAuthRoute =
            path == '/login' ||
            path == '/onboarding' ||
            path == '/register' ||
            path == '/forgot-password';

        if (isLoggedIn && isAuthRoute) {
          return '/dashboard';
        }
        if (!isLoggedIn && !isAuthRoute) {
          return '/login';
        }
        return null;
      },
      routes: [
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
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
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
      ],
    );
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PawPulse',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
