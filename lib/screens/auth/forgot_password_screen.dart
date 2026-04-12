import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/error_card.dart';
import '../../widgets/common/success_card.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  late final AuthProvider _authProvider;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(AuthService());
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _authProvider.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _authProvider.resetPassword(_emailCtrl.text.trim());
      if (_authProvider.value.error == null && mounted) {
        setState(() {
          _emailSent = true;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData prefixIcon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: Icon(prefixIcon, color: AppTheme.textSecondary),
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFF94A3B8).withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFF94A3B8).withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                "Reset Password",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your email and we'll send a reset link.",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration("Email", Icons.email_outlined),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Email is required';
                  if (!val.contains('@')) return 'Enter a valid email';
                  return null;
                },
                enabled: !_emailSent,
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder(
                valueListenable: _authProvider,
                builder: (context, state, child) {
                  return Column(
                    children: [
                      GradientButton(
                        label: "Send Reset Link",
                        isLoading: state.isLoading,
                        onPressed: _emailSent ? null : _handleReset,
                      ),
                      const SizedBox(height: 12),
                      if (_emailSent)
                        const SuccessCard(message: "Reset link sent! Check your inbox.")
                      else if (state.error != null)
                        ErrorCard(message: state.error!),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
