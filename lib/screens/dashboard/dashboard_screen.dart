import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'dashboard_inherited.dart';
import 'tabs/overview_tab.dart';
import 'tabs/pets_tab.dart';
import 'tabs/appointments_tab.dart';
import 'tabs/health_tab.dart';
import 'tabs/settings_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    OverviewTab(),
    MyPetsTab(),
    AppointmentsTab(),
    HealthTab(),
    SettingsTab(),
  ];

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: DashboardScope(
        currentIndex: _currentIndex,
        onTabSwitch: switchTab,
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              );
            }
            return GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            );
          }),
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: switchTab,
            backgroundColor: AppTheme.surface,
            indicatorColor: AppTheme.primary.withOpacity(0.15),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primary),
                label: "Overview",
              ),
              NavigationDestination(
                icon: Icon(Icons.pets_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.pets_rounded, color: AppTheme.primary),
                label: "My Pets",
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
                label: "Schedule", // Shortened
              ),
              NavigationDestination(
                icon: Icon(Icons.health_and_safety_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.health_and_safety_rounded, color: AppTheme.primary),
                label: "Health",
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.settings_rounded, color: AppTheme.primary),
                label: "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
