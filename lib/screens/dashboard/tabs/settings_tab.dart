import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../core/utils/result.dart';

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
      if (result is Success && mounted) {
        setState(() {
          _currentUserData = (result as Success).value;
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

    // Also try checking DisplayName
    if (authUser.displayName != nameController.text.trim()) {
      await authUser.updateDisplayName(nameController.text.trim());
    }

    setState(() => _isSaving = false);

    if (!context.mounted) return;
    if (result is Success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile updated!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to update profile: ${(result as Failure).error}",
            ),
          ),
        );
      }
  }

  void _handleResetPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Reset Password",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "A reset link will be sent to ${emailController.text}.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () async {
              Navigator.pop(context);
              await _authProvider.resetPassword(emailController.text);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Reset link sent!")),
              );
            },
            child: const Text(
              "Send Link",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Color(0xFFFF6B6B)),
            const SizedBox(width: 8),
            Text(
              "Delete Account",
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          "This will permanently delete your PawPulse account and all pet data. This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppTheme.textSecondary),
            ),
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
                  SnackBar(content: Text("Failed to delete account: $e")),
                );
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Out", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to sign out of PawPulse?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFB347),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _authProvider.logout();
            },
            child: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.white.withValues(alpha: 0.05),
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
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: readOnly ? AppTheme.textSecondary : Colors.white,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
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
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppTheme.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
        activeThumbColor: AppTheme.primary,
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
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Settings",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // ── Profile Section ──
            _sectionLabel("Profile"),
            const SizedBox(height: 12),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      _getInitials(
                        nameController.text.isNotEmpty
                            ? nameController.text
                            : "User",
                      ),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
                          const SnackBar(
                            content: Text(
                              "Photo upload available on Blaze plan",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  _settingsTextField(
                    label: "Full Name",
                    controller: nameController,
                    icon: Icons.person_outline,
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
            const SizedBox(height: 12),
            GradientButton(
              label: "Save Changes",
              isLoading: _isSaving,
              onPressed: _saveProfile,
            ),

            const SizedBox(height: 28),

            // ── Notifications Section ──
            _sectionLabel("Notifications"),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  _toggleTile(
                    icon: Icons.calendar_month_outlined,
                    title: "Appointment Reminders",
                    value: _notifAppointments,
                    onChanged: (v) => setState(() => _notifAppointments = v),
                  ),
                  _divider(),
                  _toggleTile(
                    icon: Icons.health_and_safety_outlined,
                    title: "Health Alerts",
                    value: _notifHealth,
                    onChanged: (v) => setState(() => _notifHealth = v),
                  ),
                  _divider(),
                  _toggleTile(
                    icon: Icons.notifications_outlined,
                    title: "Weekly Reports",
                    value: _notifWeekly,
                    onChanged: (v) => setState(() => _notifWeekly = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Account Section ──
            _sectionLabel("Account"),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  _actionTile(
                    icon: Icons.lock_reset,
                    iconColor: AppTheme.primary,
                    title: "Reset Password",
                    subtitle: "Send a reset link to your email",
                    onTap: _handleResetPassword,
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.delete_forever,
                    iconColor: const Color(0xFFFF6B6B),
                    title: "Delete Account",
                    subtitle: "Permanently delete your account and all data",
                    onTap: _handleDeleteAccount,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── App Section ──
            _sectionLabel("App"),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  _actionTile(
                    icon: Icons.logout,
                    iconColor: const Color(0xFFFFB347),
                    title: "Sign Out",
                    subtitle: "You can sign back in anytime",
                    onTap: _handleSignOut,
                  ),
                  _divider(),
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    title: Text(
                      "App Version",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Text(
                      "v1.0.0",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
