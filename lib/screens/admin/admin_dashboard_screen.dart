import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

import 'tabs/admin_overview_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/admin_pets_tab.dart';
import 'tabs/admin_appointments_tab.dart';
import 'tabs/admin_health_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int initialIndex;

  const AdminDashboardScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AuthProvider _authProvider;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(AuthService());
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  void _handleSignOut() async {
    await _authProvider.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  List<Widget> _buildTabs() {
    return [
      AdminOverviewTab(
        authProvider: _authProvider,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      const AdminUsersTab(),
      const AdminPetsTab(),
      const AdminAppointmentsTab(),
      AdminHealthTab(authProvider: _authProvider),
    ];
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.dividerTheme.color ?? AppTheme.primary.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                      ),
                    ),
                    child: Icon(Icons.pets, size: 20, color: theme.colorScheme.surface),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PawPulse",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        "Admin Panel",
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerTheme.color, height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _AdminNavItem(
                    icon: Icons.dashboard_outlined,
                    label: "Overview",
                    index: 0,
                    currentIndex: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _AdminNavItem(
                    icon: Icons.people_outlined,
                    label: "Users",
                    index: 1,
                    currentIndex: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _AdminNavItem(
                    icon: Icons.pets_outlined,
                    label: "Pets",
                    index: 2,
                    currentIndex: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _AdminNavItem(
                    icon: Icons.calendar_month_outlined,
                    label: "Schedule",
                    index: 3,
                    currentIndex: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                  _AdminNavItem(
                    icon: Icons.health_and_safety_outlined,
                    label: "Health Records",
                    index: 4,
                    currentIndex: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 4),
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerTheme.color, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              child: _AdminNavItem(
                icon: Icons.logout,
                label: "Sign Out",
                index: -1,
                currentIndex: _currentIndex,
                onTap: _handleSignOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _buildTabs(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _buildTabs(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: theme.navigationBarTheme.backgroundColor,
        indicatorColor: theme.navigationBarTheme.indicatorColor,
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: "Overview"),
          NavigationDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people), label: "Users"),
          NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: "Pets"),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: "Schedule"),
          NavigationDestination(icon: Icon(Icons.health_and_safety_outlined), selectedIcon: Icon(Icons.health_and_safety), label: "Health"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = index == currentIndex;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? AppTheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppTheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
