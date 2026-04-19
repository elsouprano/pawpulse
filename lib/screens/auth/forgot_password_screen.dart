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
      labelStyle: GoogleFonts.nunito(color: AppTheme.textSecondary),
      prefixIcon: Icon(prefixIcon, color: AppTheme.textSecondary),
      filled: true,
      fillColor: AppTheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
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
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
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
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your email and we'll send a reset link.",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                decoration: _buildInputDecoration("Email Address", Icons.email_outlined),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Email is required';
                  if (!val.contains('@')) return 'Enter a valid email';
                  return null;
                },
                enabled: !_emailSent,
              ),
              const SizedBox(height: 32),
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
                      const SizedBox(height: 16),
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
