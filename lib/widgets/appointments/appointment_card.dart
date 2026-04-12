import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/appointment_model.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  // Extra mapping optionally passed if we have pet data
  final String? petName;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onReschedule,
    this.petName,
  });

  @override
  Widget build(BuildContext context) {
    final dt = appointment.dateTime ?? DateTime.now();
    final dayStr = DateFormat('dd').format(dt);
    final monthStr = DateFormat('MMM').format(dt).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayStr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  monthStr,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.vetName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.type,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.pets, size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      petName ?? "Pet", // Fallback to "Pet" if mapped name isn't provided directly
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusChip(status: appointment.status),
              const SizedBox(height: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.textSecondary),
                padding: EdgeInsets.zero,
                color: AppTheme.surface,
                onSelected: (value) {
                  if (value == "reschedule" && onReschedule != null) {
                    onReschedule!();
                  } else if (value == "cancel" && onCancel != null) {
                    onCancel!();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "reschedule",
                    child: Row(
                      children: [
                        const Icon(Icons.edit_calendar, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text("Reschedule", style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "cancel",
                    child: Row(
                      children: [
                        const Icon(Icons.cancel_outlined, size: 18, color: AppTheme.error),
                        const SizedBox(width: 8),
                        Text("Cancel", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    if (lowerStatus.contains('confirmed')) {
      bgColor = const Color(0xFF00D4AA).withOpacity(0.15);
      textColor = const Color(0xFF00D4AA);
    } else if (lowerStatus.contains('pending')) {
      bgColor = const Color(0xFFFFB347).withOpacity(0.15);
      textColor = const Color(0xFFFFB347);
    } else if (lowerStatus.contains('cancel')) {
      bgColor = const Color(0xFFFF6B6B).withOpacity(0.15);
      textColor = const Color(0xFFFF6B6B);
    } else {
      bgColor = AppTheme.textSecondary.withOpacity(0.15);
      textColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
