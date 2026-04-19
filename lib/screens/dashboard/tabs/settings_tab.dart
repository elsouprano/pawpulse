import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/app_exceptions.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();

  bool _notifAppointments = true;
  bool _notifHealth = true;
  bool _notifWeekly = false;
  bool _isSaving = false;

  late final AuthProvider _authProvider;
  late final UserService _userService;
  UserModel? _currentUserData;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(AuthService());
    _userService = UserService();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      emailController.text = authUser.email ?? '';
      nameController.text = authUser.displayName ?? '';
      final result = await _userService.getUserProfile(authUser.uid);
      if (result is Success<UserModel, AppException> && mounted) {
        setState(() {
          _currentUserData = result.value;
          nameController.text = _currentUserData!.name;
          phoneController.text = _currentUserData!.phone ?? '';
          locationController.text = _currentUserData!.location ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    _authProvider.dispose();
    super.dispose();
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return "US";
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  Future<void> _saveProfile() async {
    final authUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) return;

    setState(() => _isSaving = true);

    final updateModel = UserModel(
      uid: authUser.uid,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      location: locationController.text.trim(),
      createdAt: _currentUserData?.createdAt ?? DateTime.now(),
      photoUrl: _currentUserData?.photoUrl,
    );

    final result = await _userService.updateUserProfile(updateModel);

    if (authUser.displayName != nameController.text.trim()) {
      await authUser.updateDisplayName(nameController.text.trim());
    }

    setState(() => _isSaving = false);

    if (!context.mounted) return;
    if (result is Success<void, AppException>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated!", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.success),
      );
    } else if (result is Failure<void, AppException>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: ${result.error}", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _handleResetPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Reset Password", style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          "A reset link will be sent to ${emailController.text}.",
          style: GoogleFonts.nunito(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.nunito(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _authProvider.resetPassword(emailController.text);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Reset link sent!", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.success),
              );
            },
            child: Text("Send Link", style: GoogleFonts.nunito(color: AppTheme.background, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.error),
            const SizedBox(width: 12),
            Text("Delete Account", style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "This will permanently delete your PawPulse account and all pet data. This action cannot be undone.",
          style: GoogleFonts.nunito(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.nunito(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await firebase_auth.FirebaseAuth.instance.currentUser?.delete();
                await _authProvider.logout();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete account.", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.error),
                );
              }
            },
            child: Text("Delete", style: GoogleFonts.nunito(color: AppTheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Sign Out", style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          "Are you sure you want to sign out of PawPulse?",
          style: GoogleFonts.nunito(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel", style: GoogleFonts.nunito(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _authProvider.logout();
                if (!context.mounted) return;
                setState(() {});
                context.go('/login');
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString(), style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            child: Text("Sign Out", style: GoogleFonts.nunito(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: AppTheme.textSecondary.withOpacity(0.1),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _settingsTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: readOnly ? AppTheme.textSecondary : AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: AppTheme.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.primary.withOpacity(0.5),
        activeColor: AppTheme.primary,
        inactiveTrackColor: AppTheme.textSecondary.withOpacity(0.2),
        inactiveThumbColor: AppTheme.textSecondary,
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Settings",
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 32),

              // ── Profile Section ──
              _sectionLabel("Profile"),
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.primary.withOpacity(0.15),
                      child: Text(
                        _getInitials(
                          nameController.text.isNotEmpty
                              ? nameController.text
                              : "User",
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Photo upload available on Blaze plan", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                              backgroundColor: AppTheme.secondary,
                            ),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.background, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: AppTheme.background,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    _settingsTextField(
                      label: "Full Name",
                      controller: nameController,
                      icon: Icons.person_outline_rounded,
                    ),
                    _divider(),
                    _settingsTextField(
                      label: "Email",
                      controller: emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                    ),
                    _divider(),
                    _settingsTextField(
                      label: "Phone",
                      controller: phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    _divider(),
                    _settingsTextField(
                      label: "Location",
                      controller: locationController,
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: "Save Changes",
                isLoading: _isSaving,
                onPressed: _saveProfile,
              ),

              const SizedBox(height: 40),

              // ── Notifications Section ──
              _sectionLabel("Notifications"),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    _toggleTile(
                      icon: Icons.calendar_month_rounded,
                      title: "Appointment Reminders",
                      value: _notifAppointments,
                      onChanged: (v) => setState(() => _notifAppointments = v),
                    ),
                    _divider(),
                    _toggleTile(
                      icon: Icons.health_and_safety_rounded,
                      title: "Health Alerts",
                      value: _notifHealth,
                      onChanged: (v) => setState(() => _notifHealth = v),
                    ),
                    _divider(),
                    _toggleTile(
                      icon: Icons.notifications_rounded,
                      title: "Weekly Reports",
                      value: _notifWeekly,
                      onChanged: (v) => setState(() => _notifWeekly = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Account Section ──
              _sectionLabel("Account"),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    _actionTile(
                      icon: Icons.lock_reset_rounded,
                      iconColor: AppTheme.primary,
                      title: "Reset Password",
                      subtitle: "Send a reset link to your email",
                      onTap: _handleResetPassword,
                    ),
                    _divider(),
                    _actionTile(
                      icon: Icons.delete_forever_rounded,
                      iconColor: AppTheme.error,
                      title: "Delete Account",
                      subtitle: "Permanently delete your account and all data",
                      onTap: _handleDeleteAccount,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── App Section ──
              _sectionLabel("App"),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    _actionTile(
                      icon: Icons.logout_rounded,
                      iconColor: AppTheme.secondary,
                      title: "Sign Out",
                      subtitle: "You can sign back in anytime",
                      onTap: _handleSignOut,
                    ),
                    _divider(),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      title: Text(
                        "App Version",
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      trailing: Text(
                        "v1.0.0",
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
