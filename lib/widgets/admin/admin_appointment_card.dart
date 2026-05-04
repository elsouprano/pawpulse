import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/appointment_model.dart';
import '../../services/admin_appointment_service.dart';
import '../../services/admin_pet_service.dart';
import '../../core/utils/result.dart';
import 'appointment_action_menu.dart';

class AdminAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final AdminAppointmentService adminAppointmentService;

  const AdminAppointmentCard({
    super.key,
    required this.appointment,
    required this.adminAppointmentService,
  });

  @override
  Widget build(BuildContext context) {
    String day = "??";
    String month = "???";
    
    if (appointment.dateTime != null) {
      day = DateFormat('dd').format(appointment.dateTime!);
      month = DateFormat('MMM').format(appointment.dateTime!);
    }

    final adminPetService = AdminPetService();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Date block
          Container(
            width: 52,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  month,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        appointment.vetName,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: appointment.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.type,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.pets, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: FutureBuilder(
                        future: Future.wait([
                          adminPetService.getPetById(appointment.petId),
                          adminPetService.getOwnerByUid(appointment.ownerId),
                        ]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                            );
                          }

                          String petName = "Unknown";
                          String ownerName = "Unknown";

                          if (snapshot.hasData) {
                            final results = snapshot.data!;
                            final petResult = results[0];
                            final ownerResult = results[1];

                            if (petResult is Success) {
                              petName = (petResult as dynamic).value.name;
                            }
                            if (ownerResult is Success) {
                              ownerName = (ownerResult as dynamic).value.name;
                            }
                          }

                          return Text(
                            "$petName · $ownerName",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppointmentActionMenu(
            appointment: appointment,
            adminAppointmentService: adminAppointmentService,
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
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = AppTheme.accent;
        break;
      case 'pending':
        color = AppTheme.secondary;
        break;
      case 'cancelled':
        color = AppTheme.error;
        break;
      case 'completed':
        color = const Color(0xFF4C9BE8);
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
}
