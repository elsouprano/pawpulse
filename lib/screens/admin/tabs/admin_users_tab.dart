import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../services/admin_user_service.dart';
import '../../../models/user_model.dart';
import '../../../widgets/admin/user_card.dart';
import '../../../widgets/admin/user_action_menu.dart';
import '../../../core/utils/result.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final AdminUserService _adminUserService = AdminUserService();
  String _searchQuery = '';
  String _roleFilter = 'All';

  // Helper for generating initials
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        return Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User Management",
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        "Manage all registered users",
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Total user count badge (will be updated dynamically via StreamBuilder)
                  StreamBuilder<List<UserModel>>(
                    stream: _adminUserService.watchAllUsers(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "$count users",
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by name or email...",
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── Role Filter Chips ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["All", "user", "admin"].map((role) {
                    return _FilterChip(
                      label: role == 'All' ? 'All' : (role == 'admin' ? 'Admin' : 'User'),
                      isActive: _roleFilter == role,
                      onTap: () {
                        setState(() {
                          _roleFilter = role;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Users List ──
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: _adminUserService.watchAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error fetching users."));
                  }

                  var users = snapshot.data ?? [];

                  // Apply filters
                  if (_searchQuery.isNotEmpty) {
                    users = users.where((u) =>
                        u.name.toLowerCase().contains(_searchQuery) ||
                        u.email.toLowerCase().contains(_searchQuery)).toList();
                  }
                  if (_roleFilter != 'All') {
                    users = users.where((u) => u.role == _roleFilter).toList();
                  }

                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                          SizedBox(height: 8),
                          Text("No users found", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }

                  if (isDesktop) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 24,
                          headingRowColor: WidgetStateProperty.all((Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface)),
                          dataRowColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.hovered)
                                  ? AppTheme.primary.withValues(alpha: 0.05)
                                  : Theme.of(context).colorScheme.surface),
                          columns: [
                            DataColumn(label: Text("User", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            DataColumn(label: Text("Email", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            DataColumn(label: Text("Role", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            DataColumn(label: Text("Joined", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            DataColumn(label: Text("Pets", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            DataColumn(label: Text("Actions", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                          ],
                          rows: users.map((u) {
                            String formattedDate = "Unknown";
                            if (u.createdAt != null) {
                              formattedDate = DateFormat("MMM d, yyyy").format(u.createdAt!);
                            }
                            return DataRow(
                              cells: [
                                DataCell(Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                                      child: Text(_getInitials(u.name), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                    ),
                                    SizedBox(width: 10),
                                    Text(u.name, style: GoogleFonts.nunito(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                                  ],
                                )),
                                DataCell(Text(u.email, style: GoogleFonts.nunito(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                DataCell(RoleChip(role: u.role)),
                                DataCell(Text(formattedDate, style: GoogleFonts.nunito(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                DataCell(FutureBuilder(
                                  future: _adminUserService.getPetsByUser(u.uid),
                                  builder: (context, petSnapshot) {
                                    if (petSnapshot.connectionState == ConnectionState.waiting) {
                                      return Text("...", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
                                    }
                                    int count = 0;
                                    final data = petSnapshot.data;
                                    if (data case Success(value: final pets)) {
                                      count = pets.length;
                                    }
                                    return Text("$count", style: GoogleFonts.nunito(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant));
                                  },
                                )),
                                DataCell(UserActionMenu(user: u, adminUserService: _adminUserService)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return UserCard(
                          user: users[index],
                          adminUserService: _adminUserService,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class RoleChip extends StatelessWidget {
  final String role;
  const RoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    final color = isAdmin ? AppTheme.primary : AppTheme.accent;
    final text = isAdmin ? "Admin" : "User";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withValues(alpha: 0.15) : (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.primary : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isActive ? AppTheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
