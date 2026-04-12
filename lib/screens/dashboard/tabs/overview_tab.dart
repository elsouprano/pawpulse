import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../providers/auth_provider.dart';
import '../../../providers/pet_provider.dart';
import '../../../providers/appointment_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/pet_service.dart';
import '../../../services/appointment_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/dashboard/stat_card.dart';
import '../../../widgets/dashboard/section_header.dart';
import '../../../widgets/pets/pet_card.dart';
import '../../../widgets/pets/add_pet_bottom_sheet.dart';
import '../dashboard_inherited.dart';
import '../../scanner/ai_scanner_screen.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  late final AuthProvider _authProvider;
  late final PetProvider _petProvider;
  late final AppointmentProvider _appointmentProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(AuthService());
    _petProvider = PetProvider(PetService());
    _appointmentProvider = AppointmentProvider(AppointmentService());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        _petProvider.loadPets(user.uid);
        _appointmentProvider.loadAppointments(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _petProvider.dispose();
    _appointmentProvider.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: _authProvider,
                builder: (context, dynamic authState, child) {
                  final name = authState.currentUser?.displayName ?? "there";
                  return Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Good morning,", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                          Text("$name 👋", style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => DashboardScope.of(context).onTabSwitch(4),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTheme.primary.withOpacity(0.2),
                          child: Text(
                            _getInitials(name),
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder(
                valueListenable: _petProvider,
                builder: (context, petState, _) {
                  return ValueListenableBuilder(
                    valueListenable: _appointmentProvider,
                    builder: (context, apptState, _) {
                      final petList = petState.petList;
                      final upcomingCount = apptState.upcoming.length;
                      final alertCount = petList.where((p) {
                        final s = p.healthStatus.toLowerCase();
                        return s.contains('attention') || s.contains('issue') || s.contains('critical');
                      }).length;

                      return GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatCard(
                            icon: Icons.pets,
                            label: "Pets Registered",
                            value: petList.length.toString(),
                            trendUp: true,
                            trendLabel: "Active",
                          ),
                          StatCard(
                            icon: Icons.calendar_month,
                            label: "Upcoming",
                            value: upcomingCount.toString(),
                            trendUp: null, // intentionally null
                            trendLabel: null,
                          ),
                          StatCard(
                            icon: Icons.warning_amber_outlined,
                            label: "Health Alerts",
                            value: alertCount.toString(),
                            trendUp: false,
                            trendLabel: "Check now",
                          ),
                          const StatCard(
                            icon: Icons.vaccines_outlined,
                            label: "Vaccinations Due",
                            value: "2",
                            trendUp: false,
                            trendLabel: "This month",
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: "My Pets",
                actionLabel: "See All",
                onAction: () => DashboardScope.of(context).onTabSwitch(1),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder(
                valueListenable: _petProvider,
                builder: (context, state, child) {
                  if (state.petList.isEmpty) {
                    return Text("No pets added yet.", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary));
                  }
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.petList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.petList.length) {
                          return GestureDetector(
                            onTap: () => AddPetBottomSheet.show(context, _petProvider),
                            child: Container(
                              width: 155,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.textSecondary.withOpacity(0.3), style: BorderStyle.solid), // Flutter has no pure dashed border out of box without package, using solid
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add, color: AppTheme.primary, size: 28),
                                  const SizedBox(height: 8),
                                  Text("Add Pet", style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primary)),
                                ],
                              ),
                            ),
                          );
                        }
                        return Container(
                          width: 155,
                          margin: const EdgeInsets.only(right: 12),
                          child: PetCard(
                            pet: state.petList[index],
                            onTap: () => DashboardScope.of(context).onTabSwitch(1),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: "Upcoming",
                actionLabel: "See All",
                onAction: () => DashboardScope.of(context).onTabSwitch(2),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder(
                valueListenable: _appointmentProvider,
                builder: (context, state, child) {
                  if (state.upcoming.isEmpty) {
                    return Text("No upcoming appointments.", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary));
                  }
                  final count = min(3, state.upcoming.length);
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: count,
                    itemBuilder: (context, index) {
                      final appt = state.upcoming[index];
                      final dt = appt.dateTime ?? DateTime.now();
                      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("${dt.day}", style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                  Text(months[dt.month - 1], style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(appt.vetName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text(appt.type, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            _StatusChip(status: appt.status),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 28),
              const SectionHeader(title: "Recent Activity"),
              const SizedBox(height: 12),
              Card(
                color: AppTheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildActivityTile(Icons.pets, AppTheme.primary, "Max had a check-up", "Vet: Dr. Santos", "2h ago"),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    _buildActivityTile(Icons.vaccines, AppTheme.accent, "Vaccination recorded", "Rabies shot", "Yesterday"),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    _buildActivityTile(Icons.calendar_month, const Color(0xFFFFB347), "Appointment booked", "Dr. Reyes, Fri", "2d ago"),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    _buildActivityTile(Icons.warning_amber, const Color(0xFFFF6B6B), "Health alert", "Bella needs attention", "3d ago"),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    _buildActivityTile(Icons.check_circle, AppTheme.accent, "Profile updated", "Luna's weight updated", "5d ago"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiScannerScreen()),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 20),
                  Text("AI", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
  }

  Widget _buildActivityTile(IconData icon, Color color, String title, String subtitle, String time) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
      trailing: Text(time, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.textSecondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
      ),
    );
  }
}
