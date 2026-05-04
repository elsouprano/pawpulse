import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'theme/admin_theme.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'router/app_router.dart';

// ─── Main ─────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase not configured: $e');
  }

  runApp(const PawPulseApp());
}

// ─── App ──────────────────────────────────────────────────────────────────────

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
    _router = AppRouter.createRouter(_authProvider);
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthState>(
      valueListenable: _authProvider,
      builder: (context, authState, child) {
        return MaterialApp.router(
          title: 'PawPulse',
          theme: authState.role == 'admin'
              ? AdminTheme.adminLightTheme
              : AppTheme.darkTheme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
