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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayStr,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  monthStr,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.vetName,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.type,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.pets_rounded, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      petName ?? "Pet", // Fallback to "Pet" if mapped name isn't provided directly
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
              const SizedBox(height: 12),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppTheme.textSecondary),
                padding: EdgeInsets.zero,
                color: AppTheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        const Icon(Icons.edit_calendar_rounded, size: 18, color: AppTheme.textPrimary),
                        const SizedBox(width: 12),
                        Text("Reschedule", style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "cancel",
                    child: Row(
                      children: [
                        const Icon(Icons.cancel_outlined, size: 18, color: AppTheme.error),
                        const SizedBox(width: 12),
                        Text("Cancel", style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.error)),
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
      bgColor = AppTheme.success.withOpacity(0.15);
      textColor = AppTheme.success;
    } else if (lowerStatus.contains('pending')) {
      bgColor = AppTheme.secondary.withOpacity(0.15);
      textColor = AppTheme.secondary;
    } else if (lowerStatus.contains('cancel')) {
      bgColor = AppTheme.error.withOpacity(0.15);
      textColor = AppTheme.error;
    } else {
      bgColor = AppTheme.textSecondary.withOpacity(0.15);
      textColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
