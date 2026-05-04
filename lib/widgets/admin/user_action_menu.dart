import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/admin_user_service.dart';
import 'user_detail_bottom_sheet.dart';
import '../../core/utils/result.dart';

class UserActionMenu extends StatelessWidget {
  final UserModel user;
  final AdminUserService adminUserService;

  const UserActionMenu({
    super.key,
    required this.user,
    required this.adminUserService,
  });

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isSelf(String uid) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && currentUser.uid == uid;
  }

  void _promoteUser(BuildContext context) async {
    if (_isSelf(user.uid)) {
      _showSnackBar(context, "You cannot modify your own account");
      return;
    }
    final result = await adminUserService.promoteToAdmin(user.uid);
    if (!context.mounted) return;
    if (result is Success) {
      _showSnackBar(context, "User promoted to admin");
    } else {
      _showSnackBar(context, "Failed to promote user");
    }
  }

  void _demoteUser(BuildContext context) async {
    if (_isSelf(user.uid)) {
      _showSnackBar(context, "You cannot modify your own account");
      return;
    }
    final result = await adminUserService.demoteToUser(user.uid);
    if (!context.mounted) return;
    if (result is Success) {
      _showSnackBar(context, "User demoted to regular user");
    } else {
      _showSnackBar(context, "Failed to demote user");
    }
  }

  void _deleteUser(BuildContext context) {
    if (_isSelf(user.uid)) {
      _showSnackBar(context, "You cannot modify your own account");
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Delete User", style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface)),
          content: Text("This will permanently delete this user account. This cannot be undone.", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final result = await adminUserService.deleteUser(user.uid);
                if (!context.mounted) return;
                if (result is Success) {
                  _showSnackBar(context, "User deleted");
                } else {
                  _showSnackBar(context, "Failed to delete user");
                }
              },
              child: Text("Delete", style: GoogleFonts.nunito(color: AppTheme.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'admin';

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        switch (value) {
          case 'view':
            UserDetailBottomSheet.show(context, user, adminUserService);
            break;
          case 'promote':
            _promoteUser(context);
            break;
          case 'demote':
            _demoteUser(context);
            break;
          case 'delete':
            _deleteUser(context);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.person_outline, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
              SizedBox(width: 12),
              Text("View Details", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
        if (!isAdmin)
          PopupMenuItem(
            value: 'promote',
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: AppTheme.primary, size: 20),
                const SizedBox(width: 12),
                Text("Promote to Admin", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        if (isAdmin)
          PopupMenuItem(
            value: 'demote',
            child: Row(
              children: [
                const Icon(Icons.person_remove, color: AppTheme.secondary, size: 20),
                const SizedBox(width: 12),
                Text("Demote to User", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_forever, color: AppTheme.error, size: 20),
              const SizedBox(width: 12),
              Text("Delete Account", style: GoogleFonts.nunito(color: AppTheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}
