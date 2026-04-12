import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFF0F0F1A),
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
              return GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6C63FF),
              );
            }
            return GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: switchTab,
          backgroundColor: const Color(0xFF1A1A2E),
          indicatorColor: const Color(0xFF6C63FF).withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: Color(0xFF94A3B8)),
              selectedIcon: Icon(Icons.dashboard, color: Color(0xFF6C63FF)),
              label: "Overview",
            ),
            NavigationDestination(
              icon: Icon(Icons.pets_outlined, color: Color(0xFF94A3B8)),
              selectedIcon: Icon(Icons.pets, color: Color(0xFF6C63FF)),
              label: "My Pets",
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: Color(0xFF94A3B8)),
              selectedIcon: Icon(Icons.calendar_month, color: Color(0xFF6C63FF)),
              label: "Appointments",
            ),
            NavigationDestination(
              icon: Icon(Icons.health_and_safety_outlined, color: Color(0xFF94A3B8)),
              selectedIcon: Icon(Icons.health_and_safety, color: Color(0xFF6C63FF)),
              label: "Health",
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: Color(0xFF94A3B8)),
              selectedIcon: Icon(Icons.settings, color: Color(0xFF6C63FF)),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
