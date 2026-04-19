import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/error_card.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(AuthService());
  }

  @override
  void dispose() {
    _authProvider.value = _authProvider.value.copyWith(clearError: true);
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _authProvider.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _authProvider.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (_authProvider.value.currentUser != null && mounted) {
        context.go('/dashboard');
      }
    }
  }

  InputDecoration _buildInputDecoration(String hint, IconData prefixIcon, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: AppTheme.textSecondary.withOpacity(0.5)),
      prefixIcon: Icon(prefixIcon, color: AppTheme.textSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF1A1200).withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF8C42), width: 1.5),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: const Color(0xFF1A1200)),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [const Color(0xFFFF8C42).withOpacity(0.08), Colors.transparent],
              center: Alignment.center,
              radius: 1.5,
            ),
          ),
        ),
        Positioned(top: -50, left: -100, child: _Circle(size: 300, color: const Color(0xFFFF8C42).withOpacity(0.06))),
        Positioned(bottom: -50, right: -100, child: _Circle(size: 350, color: const Color(0xFFFF8C42).withOpacity(0.06))),
        Positioned(top: 200, right: -50, child: _Circle(size: 200, color: const Color(0xFFFF8C42).withOpacity(0.06))),
        Positioned(bottom: 150, left: -50, child: _Circle(size: 150, color: const Color(0xFFFFD166).withOpacity(0.04))),
        Positioned(top: 100, left: 150, child: _Circle(size: 100, color: const Color(0xFFFFD166).withOpacity(0.04))),
      ],
    );
  }

  Widget _buildFloatingCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFF8C42).withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C42).withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(28),
            color: const Color(0xFF3D2C00).withOpacity(0.92),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF8C42), Color(0xFFFFD166)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.pets, size: 36, color: Color(0xFF1A1200)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "PawPulse",
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Welcome back! \u{1F43E}",
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildFloatingCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Sign In",
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Enter your credentials to continue",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                              decoration: _buildInputDecoration("Email", Icons.email_outlined),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Email is required';
                                if (!val.contains('@')) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                              decoration: _buildInputDecoration(
                                "Password",
                                Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    color: AppTheme.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Password is required';
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.push('/forgot-password'),
                                child: Text(
                                  "Forgot Password?",
                                  style: GoogleFonts.nunito(color: AppTheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ValueListenableBuilder(
                              valueListenable: _authProvider,
                              builder: (context, state, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    GradientButton(
                                      label: "Sign In",
                                      isLoading: state.isLoading,
                                      onPressed: _handleLogin,
                                    ),
                                    if (state.error != null) ...[
                                      const SizedBox(height: 12),
                                      ErrorCard(message: state.error!),
                                    ],
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppTheme.textSecondary.withOpacity(0.3), thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    "or",
                                    style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.normal),
                                  ),
                                ),
                                Expanded(child: Divider(color: AppTheme.textSecondary.withOpacity(0.3), thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton(
                              onPressed: () => context.go('/register'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18.0),
                                side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                              ),
                              child: Text(
                                "Create an account",
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;

  const _Circle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
