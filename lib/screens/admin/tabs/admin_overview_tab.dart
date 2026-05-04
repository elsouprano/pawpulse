import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/admin_stats_service.dart';
import '../../../widgets/admin/admin_stat_card.dart';
import '../../../models/user_model.dart';
import '../../../models/appointment_model.dart';

class AdminOverviewTab extends StatefulWidget {
  final AuthProvider authProvider;
  final Function(int) onNavigate;

  const AdminOverviewTab({
    super.key,
    required this.authProvider,
    required this.onNavigate,
  });

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  final AdminStatsService _statsService = AdminStatsService();

  int _totalUsers = 0;
  int _totalPets = 0;
  int _totalAppointments = 0;
  int _totalHealthRecords = 0;

  bool _isLoadingStats = true;

  late Future<List<UserModel>> _recentUsersFuture;
  late Future<List<AppointmentModel>> _recentAppointmentsFuture;
  late Future<List<int>> _monthlyCountsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _recentUsersFuture = _statsService.getRecentUsers(limit: 5);
    _recentAppointmentsFuture = _statsService.getRecentAppointments(limit: 5);
    _monthlyCountsFuture = _fetchMonthlyAppointmentCounts();
  }

  Future<List<int>> _fetchMonthlyAppointmentCounts() async {
    final now = DateTime.now();
    final counts = <int>[];
    for (int i = 5; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 1);
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .where('dateTime', isLessThan: Timestamp.fromDate(monthEnd))
          .count()
          .get();
      counts.add(snapshot.count ?? 0);
    }
    return counts;
  }

  Future<void> _loadStats() async {
    try {
      final users = await _statsService.getTotalUsers();
      final pets = await _statsService.getTotalPets();
      final appointments = await _statsService.getTotalAppointments();
      final health = await _statsService.getTotalHealthRecords();

      if (mounted) {
        setState(() {
          _totalUsers = users;
          _totalPets = pets;
          _totalAppointments = appointments;
          _totalHealthRecords = health;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, min(2, parts[0].length)).toUpperCase();
  }

  Widget _buildStatusChip(String status) {
    Color color;
    Color bg;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = const Color(0xFF4ADE80);
        bg = color.withValues(alpha: 0.15);
        break;
      case 'pending':
        color = const Color(0xFFFFD166);
        bg = color.withValues(alpha: 0.15);
        break;
      case 'completed':
        color = AppTheme.primary;
        bg = color.withValues(alpha: 0.15);
        break;
      default:
        color = Theme.of(context).colorScheme.onSurfaceVariant;
        bg = color.withValues(alpha: 0.15);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.authProvider.value.currentUser?.displayName ?? 'Admin';
    final today = DateFormat('EEEE, MMMM d yyyy').format(DateTime.now());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,",
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            name,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            today,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await widget.authProvider.logout();
                        if (context.mounted) {
                          GoRouter.of(context).go('/login');
                        }
                      },
                      icon: const Icon(Icons.logout),
                      color: AppTheme.error,
                      tooltip: "Sign Out",
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            (Theme.of(context).cardTheme.color ??
                            Theme.of(context).colorScheme.surface),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Stats Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Platform Overview",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: isDesktop ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isDesktop ? 1.6 : 1.25,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        AdminStatCard(
                          icon: Icons.people,
                          label: "Total Users",
                          value: _isLoadingStats ? "-" : _totalUsers.toString(),
                          color: AppTheme.primary,
                        ),
                        AdminStatCard(
                          icon: Icons.pets,
                          label: "Total Pets",
                          value: _isLoadingStats ? "-" : _totalPets.toString(),
                          color: AppTheme.accent,
                        ),
                        AdminStatCard(
                          icon: Icons.calendar_month,
                          label: "Appointments",
                          value: _isLoadingStats
                              ? "-"
                              : _totalAppointments.toString(),
                          color: AppTheme.secondary,
                        ),
                        AdminStatCard(
                          icon: Icons.health_and_safety,
                          label: "Health Records",
                          value: _isLoadingStats
                              ? "-"
                              : _totalHealthRecords.toString(),
                          color: const Color(0xFFFF6B6B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Registrations
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Recent User Registrations",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => widget.onNavigate(1),
                          child: Text(
                            "See All",
                            style: GoogleFonts.nunito(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<UserModel>>(
                      future: _recentUsersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "No users yet",
                                style: GoogleFonts.nunito(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }

                        final users = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final dateStr = user.createdAt != null
                                ? DateFormat('MMM d').format(user.createdAt!)
                                : '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    (Theme.of(context).cardTheme.color ??
                                    Theme.of(context).colorScheme.surface),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppTheme.primary
                                        .withValues(alpha: 0.15),
                                    child: Text(
                                      _getInitials(user.name),
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name.isEmpty
                                              ? 'Unknown'
                                              : user.name,
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          user.email,
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    dateStr,
                                    style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Recent Appointments
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Recent Appointments",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => widget.onNavigate(3),
                          child: Text(
                            "See All",
                            style: GoogleFonts.nunito(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<AppointmentModel>>(
                      future: _recentAppointmentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "No appointments yet",
                                style: GoogleFonts.nunito(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }

                        final appointments = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            final apt = appointments[index];
                            final dt = apt.dateTime;
                            final day = dt != null ? dt.day.toString() : '--';
                            final month = dt != null
                                ? DateFormat('MMM').format(dt)
                                : '---';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    (Theme.of(context).cardTheme.color ??
                                    Theme.of(context).colorScheme.surface),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          day,
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary,
                                            height: 1.1,
                                          ),
                                        ),
                                        Text(
                                          month,
                                          style: GoogleFonts.nunito(
                                            fontSize: 10,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          apt.vetName.isEmpty
                                              ? 'Unknown Vet'
                                              : apt.vetName,
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          apt.type,
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusChip(apt.status),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Appointment Trends Chart
              _buildTrendsChart(),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendsChart() {
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i), 1);
      return DateFormat('MMM').format(m);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Appointment Trends",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Last 6 months · appointment volume",
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<int>>(
            future: _monthlyCountsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final counts = snapshot.data ?? List.filled(6, 0);
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ??
                      Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 160,
                      child: CustomPaint(
                        painter: _AppointmentTrendsPainter(
                          counts: counts,
                          months: months,
                          activeColor: AppTheme.primary,
                          inactiveColor: AppTheme.primary.withValues(alpha: 0.35),
                          labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                          activeMonthIndex: 5, // current month is always last
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Current month",
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Total: ${counts.fold(0, (a, b) => a + b)}",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AppointmentTrendsPainter extends CustomPainter {
  final List<int> counts;
  final List<String> months;
  final Color activeColor;
  final Color inactiveColor;
  final Color labelColor;
  final int activeMonthIndex;

  _AppointmentTrendsPainter({
    required this.counts,
    required this.months,
    required this.activeColor,
    required this.inactiveColor,
    required this.labelColor,
    required this.activeMonthIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double labelHeight = 20.0;
    const double barAreaBottom = 4.0;
    final double chartHeight = size.height - labelHeight - barAreaBottom;

    final int maxCount = counts.isEmpty ? 1 : counts.reduce(max);
    final int effectiveMax = maxCount == 0 ? 1 : maxCount;

    final int n = counts.length;
    final double totalBarWidth = size.width;
    final double barWidth = (totalBarWidth / n) * 0.5;
    final double gap = (totalBarWidth - barWidth * n) / (n + 1);

    // Horizontal grid lines
    final gridPaint = Paint()
      ..color = labelColor.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    const int gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = barAreaBottom + chartHeight * (1 - i / gridLines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < n; i++) {
      final bool isActive = i == activeMonthIndex;
      final double barHeight =
          chartHeight * (counts[i] / effectiveMax);
      final double left = gap + i * (barWidth + gap);
      final double top = barAreaBottom + chartHeight - barHeight;
      final double bottom = barAreaBottom + chartHeight;

      // Shadow for active bar
      if (isActive && counts[i] > 0) {
        final shadowPaint = Paint()
          ..color = activeColor.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(left - 2, top + 4, left + barWidth + 2, bottom + 2),
            const Radius.circular(8),
          ),
          shadowPaint,
        );
      }

      // Bar
      final barPaint = Paint()
        ..color = isActive ? activeColor : inactiveColor
        ..style = PaintingStyle.fill;

      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, left + barWidth, bottom),
        const Radius.circular(8),
      );

      if (counts[i] == 0) {
        // Draw a thin placeholder line
        final emptyPaint = Paint()
          ..color = labelColor.withValues(alpha: 0.15)
          ..strokeWidth = barWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(left + barWidth / 2, bottom - 2),
          Offset(left + barWidth / 2, bottom - 4),
          emptyPaint,
        );
      } else {
        canvas.drawRRect(barRect, barPaint);

        // Count label on top of bar
        final countSpan = TextSpan(
          text: counts[i].toString(),
          style: TextStyle(
            color: isActive ? activeColor : labelColor.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        final countPainter = TextPainter(
          text: countSpan,
          textDirection: ui.TextDirection.ltr,
        )..layout();
        countPainter.paint(
          canvas,
          Offset(left + (barWidth - countPainter.width) / 2, top - 16),
        );
      }

      // Month label
      final labelSpan = TextSpan(
        text: months[i],
        style: TextStyle(
          color: isActive
              ? activeColor
              : labelColor.withValues(alpha: 0.7),
          fontSize: 11,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      );
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: ui.TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(
          left + (barWidth - labelPainter.width) / 2,
          size.height - labelHeight + 4,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AppointmentTrendsPainter old) =>
      old.counts != counts || old.activeMonthIndex != activeMonthIndex;
}
