import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/pet_model.dart';
import '../../services/admin_user_service.dart';
import '../../screens/admin/tabs/admin_users_tab.dart'; // for RoleChip
import '../../core/utils/result.dart';
import '../../core/errors/app_exceptions.dart';

class UserDetailBottomSheet extends StatelessWidget {
  final UserModel user;
  final AdminUserService adminUserService;

  const UserDetailBottomSheet({
    super.key,
    required this.user,
    required this.adminUserService,
  });

  static void show(BuildContext context, UserModel user, AdminUserService adminUserService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailBottomSheet(
        user: user,
        adminUserService: adminUserService,
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _getSpeciesEmoji(String species) {
    switch (species.toLowerCase()) {
      case 'dog': return '🐶';
      case 'cat': return '🐱';
      case 'bird': return '🐦';
      case 'rabbit': return '🐰';
      case 'fish': return '🐟';
      case 'reptile': return '🦎';
      default: return '🐾';
    }
  }

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
      Navigator.pop(context); // Close sheet
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
      Navigator.pop(context);
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
                  Navigator.pop(context); // Close bottom sheet
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

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primary),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.nunito(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text(value, style: GoogleFonts.nunito(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthChip(BuildContext context, String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'healthy':
        color = AppTheme.success;
        break;
      case 'sick':
        color = AppTheme.error;
        break;
      case 'recovering':
        color = AppTheme.secondary;
        break;
      default:
        color = Theme.of(context).colorScheme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = "Unknown";
    if (user.createdAt != null) {
      formattedDate = DateFormat("MMMM d, yyyy - h:mm a").format(user.createdAt!);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                          child: Text(
                            _getInitials(user.name),
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                user.email,
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RoleChip(role: user.role),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface)),
                    const SizedBox(height: 16),

                    // Info Rows
                    _buildDetailRow(
                      context,
                      "Phone",
                      (user.phone == null || user.phone!.isEmpty) ? "Not provided" : user.phone!,
                      Icons.phone_outlined,
                    ),
                    _buildDetailRow(
                      context,
                      "Location",
                      (user.location == null || user.location!.isEmpty) ? "Not provided" : user.location!,
                      Icons.location_on_outlined,
                    ),
                    _buildDetailRow(
                      context,
                      "Joined",
                      formattedDate,
                      Icons.calendar_today_outlined,
                    ),
                    _buildDetailRow(
                      context,
                      "User ID",
                      user.uid,
                      Icons.fingerprint,
                    ),

                    const SizedBox(height: 20),

                    // Pets Section
                    Text(
                      "Registered Pets",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<Result<List<PetModel>, AppException>>(
                      future: adminUserService.getPetsByUser(user.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                        }
                        final data = snapshot.data;
                        if (snapshot.hasError || data == null || data is! Success) {
                          return Text(
                            "Error loading pets",
                            style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.error),
                          );
                        }

                        final pets = (data as Success<List<PetModel>, AppException>).value;
                        if (pets.isEmpty) {
                          return Text(
                            "No pets registered",
                            style: GoogleFonts.nunito(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pets.length,
                          itemBuilder: (context, index) {
                            final pet = pets[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _getSpeciesEmoji(pet.species),
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.name,
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        pet.breed,
                                        style: GoogleFonts.nunito(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  _buildHealthChip(context, pet.healthStatus),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Actions
                    Row(
                      children: [
                        if (user.role == "user")
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _promoteUser(context),
                              child: const Text("Promote to Admin"),
                            ),
                          ),
                        if (user.role == "admin")
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _demoteUser(context),
                              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.secondary, side: const BorderSide(color: AppTheme.secondary)),
                              child: const Text("Demote to User"),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _deleteUser(context),
                            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error, side: const BorderSide(color: AppTheme.error)),
                            child: const Text("Delete Account"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
