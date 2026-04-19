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
import '../../../widgets/dashboard/section_header.dart';
import '../dashboard_inherited.dart';
import '../../scanner/ai_scanner_screen.dart';
import '../../../models/pet_model.dart';
import '../../../models/appointment_model.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> with SingleTickerProviderStateMixin {
  late final AuthProvider _authProvider;
  late final PetProvider _petProvider;
  late final AppointmentProvider _appointmentProvider;
  
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(AuthService());
    _petProvider = PetProvider(PetService());
    _appointmentProvider = AppointmentProvider(AppointmentService());

    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.forward();

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
    _animCtrl.dispose();
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

  Widget _staggered(int index, Widget child) {
    final start = (index * 0.15).clamp(0.0, 0.8);
    final end = (start + 0.2).clamp(0.2, 1.0);
    final anim = CurvedAnimation(parent: _animCtrl, curve: Interval(start, end, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(anim),
        child: child,
      ),
    );
  }

  Widget _buildHero(String name, int petCount, int upcomingCount, int alertCount) {
    final int hour = DateTime.now().hour;
    String timeOfDay = "evening";
    if (hour < 12) {
      timeOfDay = "morning";
    } else if (hour < 17) {
      timeOfDay = "afternoon";
    }

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF8C42),
            const Color(0xFFFFD166),
            const Color(0xFFFF8C42).withOpacity(0.6),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30, right: -20,
            child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08))),
          ),
          Positioned(
            bottom: -40, right: 60,
            child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06))),
          ),
          Positioned(
            top: 20, right: 80,
            child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1))),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Good $timeOfDay,", style: GoogleFonts.nunito(fontSize: 15, color: const Color(0xFF1A1200).withOpacity(0.7))),
                        Text(name, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF1A1200))),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => DashboardScope.of(context).onTabSwitch(4),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1A1200).withOpacity(0.15),
                          border: Border.all(color: const Color(0xFF1A1200).withOpacity(0.2), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(name),
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A1200)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _HeroStatPill(icon: Icons.pets, value: "$petCount", label: "Pets"),
                        const SizedBox(width: 12),
                        _HeroStatPill(icon: Icons.calendar_month, value: "$upcomingCount", label: "Upcoming"),
                        const SizedBox(width: 12),
                        _HeroStatPill(icon: Icons.warning_amber, value: "$alertCount", label: "Alerts"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(int petCount, int upcomingCount, int alertCount) {
    final cards = [
      {
        'icon': Icons.pets_rounded, 'value': "$petCount", 'label': "Pets",
        'trendUp': true, 'colors': const [Color(0xFFFF8C42), Color(0xFFE6721A)], 'border': null,
      },
      {
        'icon': Icons.calendar_month_rounded, 'value': "$upcomingCount", 'label': "Appointments",
        'trendUp': true, 'colors': const [Color(0xFF2C1F00), Color(0xFF3D2C00)], 'border': Border.all(color: AppTheme.primary.withOpacity(0.3)),
      },
      {
        'icon': Icons.warning_amber_rounded, 'value': "$alertCount", 'label': "Alerts",
        'trendUp': false, 'colors': [const Color(0xFFFF6B6B).withOpacity(0.8), const Color(0xFFCC4444)], 'border': null,
      },
      {
        'icon': Icons.vaccines_rounded, 'value': "2", 'label': "Vaccinations",
        'trendUp': false, 'colors': [const Color(0xFF06D6A0).withOpacity(0.8), const Color(0xFF04A87D)], 'border': null,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("Overview", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              final c = cards[index];
              return _staggered(
                index,
                Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(colors: c['colors'] as List<Color>),
                    border: c['border'] as Border?,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(c['icon'] as IconData, size: 18, color: Colors.white.withOpacity(0.9)),
                          const Spacer(),
                          Icon((c['trendUp'] as bool) ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: Colors.white.withOpacity(0.7)),
                        ],
                      ),
                      const Spacer(),
                      Text(c['value'] as String, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(c['label'] as String, style: GoogleFonts.nunito(fontSize: 11, color: Colors.white.withOpacity(0.75)), maxLines: 1),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyPetsPreview(List<PetModel> petList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: "My Pets",
            actionLabel: "See All",
            onAction: () => DashboardScope.of(context).onTabSwitch(1),
          ),
        ),
        const SizedBox(height: 12),
        if (petList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.pets, size: 32, color: AppTheme.primary.withOpacity(0.4)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("No pets yet", style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        Text("Add your first pet to get started", style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                    onPressed: () => DashboardScope.of(context).onTabSwitch(1),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: petList.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: () => DashboardScope.of(context).onTabSwitch(1),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: AppTheme.primary, size: 24),
                          const SizedBox(height: 4),
                          Text("Add", style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.primary)),
                        ],
                      ),
                    ),
                  );
                }

                final pet = petList[index - 1];
                final Gradient grad;
                final String emoji;
                if (pet.species.contains('Dog')) {
                  grad = const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]);
                  emoji = "🐕";
                } else if (pet.species.contains('Cat')) {
                  grad = const LinearGradient(colors: [AppTheme.accent, Color(0xFF02A676)]);
                  emoji = "🐈";
                } else if (pet.species.contains('Bird')) {
                  grad = const LinearGradient(colors: [AppTheme.secondary, Color(0xFFFFB347)]);
                  emoji = "🐦";
                } else if (pet.species.contains('Rabbit')) {
                  grad = const LinearGradient(colors: [AppTheme.error, Color(0xFFFF9494)]);
                  emoji = "🐇";
                } else {
                  grad = LinearGradient(colors: [AppTheme.textSecondary, AppTheme.textSecondary.withOpacity(0.7)]);
                  emoji = "🐾";
                }

                Color healthColor = AppTheme.success;
                final s = pet.healthStatus.toLowerCase();
                if (s.contains('attention') || s.contains('issue')) healthColor = AppTheme.secondary;
                else if (s.contains('critical') || s.contains('bad')) healthColor = AppTheme.error;

                return _staggered(
                  index,
                  Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: grad,
                          ),
                          child: Center(
                            child: Text(emoji, style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                pet.name,
                                style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: healthColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildUpcoming(List<AppointmentModel> upcoming) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: "Upcoming",
            actionLabel: "See All",
            onAction: () => DashboardScope.of(context).onTabSwitch(2),
          ),
        ),
        const SizedBox(height: 12),
        if (upcoming.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 32, color: AppTheme.primary.withOpacity(0.4)),
                  const SizedBox(width: 16),
                  Text("No upcoming appointments", style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: upcoming.take(3).map((appt) {
                return _AppointmentRow(appointment: appt);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(title: "Recent Activity"),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                _buildActivityTile(Icons.pets, AppTheme.primary, "Max had a check-up", "Vet: Dr. Santos", "2h ago"),
                Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16),
                _buildActivityTile(Icons.vaccines, AppTheme.accent, "Vaccination recorded", "Rabies shot", "Yesterday"),
                Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16),
                _buildActivityTile(Icons.calendar_month, AppTheme.secondary, "Appointment booked", "Dr. Reyes, Fri", "2d ago"),
                Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16),
                _buildActivityTile(Icons.warning_amber, AppTheme.error, "Health alert", "Bella needs attention", "3d ago"),
                Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16),
                _buildActivityTile(Icons.check_circle, AppTheme.success, "Profile updated", "Luna's weight updated", "5d ago"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTile(IconData icon, Color color, String title, String subtitle, String time) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      subtitle: Text(subtitle, style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textSecondary)),
      trailing: Text(time, style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textSecondary)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                physics: const BouncingScrollPhysics(),
                child: ValueListenableBuilder(
                  valueListenable: _authProvider,
                  builder: (context, authState, child) {
                    final name = authState.currentUser?.displayName ?? "there";
                    final parts = name.split(' ');
                    final firstName = parts.isNotEmpty ? parts[0] : name;

                    return ValueListenableBuilder(
                      valueListenable: _petProvider,
                      builder: (context, petState, _) {
                        return ValueListenableBuilder(
                          valueListenable: _appointmentProvider,
                          builder: (context, apptState, _) {
                            final petList = petState.petList;
                            final upcomingList = apptState.upcoming;
                            final upcomingCount = upcomingList.length;
                            final alertCount = petList.where((p) {
                              final s = p.healthStatus.toLowerCase();
                              return s.contains('attention') || s.contains('issue') || s.contains('critical');
                            }).length;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHero(firstName, petList.length, upcomingCount, alertCount),
                                _buildStatCards(petList.length, upcomingCount, alertCount),
                                _buildMyPetsPreview(petList),
                                _buildUpcoming(upcomingList),
                                _buildRecentActivity(),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.document_scanner_rounded, color: AppTheme.background, size: 24),
                    const SizedBox(height: 2),
                    Text("SCAN", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.background, letterSpacing: 1.0)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HeroStatPill({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1200).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1A1200).withOpacity(0.7)),
          const SizedBox(width: 6),
          Text("$value $label", style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1200).withOpacity(0.8))),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentRow({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final dt = appointment.dateTime ?? DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dStr = dt.day.toString().padLeft(2, '0');
    final mStr = months[dt.month - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dStr, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                Text(mStr, style: GoogleFonts.nunito(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.vetName, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(appointment.type, style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          _StatusChip(status: appointment.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'confirmed') {
      bgColor = AppTheme.success.withOpacity(0.15);
      textColor = AppTheme.success;
    } else if (lowerStatus == 'pending') {
      bgColor = AppTheme.secondary.withOpacity(0.15);
      textColor = AppTheme.secondary;
    } else if (lowerStatus == 'cancelled') {
      bgColor = AppTheme.error.withOpacity(0.15);
      textColor = AppTheme.error;
    } else {
      bgColor = AppTheme.textSecondary.withOpacity(0.15);
      textColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: textColor, letterSpacing: 0.5),
      ),
    );
  }
}
