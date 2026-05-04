import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/appointment_model.dart';
import '../../services/admin_appointment_service.dart';
import '../../core/utils/result.dart';

class AppointmentActionMenu extends StatelessWidget {
  final AppointmentModel appointment;
  final AdminAppointmentService adminAppointmentService;

  const AppointmentActionMenu({
    super.key,
    required this.appointment,
    required this.adminAppointmentService,
  });

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _updateStatus(BuildContext context, String status) async {
    final result = await adminAppointmentService.updateAppointmentStatus(appointment.id, status);
    if (!context.mounted) return;
    if (result is Success) {
      _showSnackBar(context, "Appointment marked as $status");
    } else {
      _showSnackBar(context, "Failed to update appointment");
    }
  }

  void _deleteAppointment(BuildContext context) {
    if (appointment.status.toLowerCase() == 'confirmed') {
      _showSnackBar(context, "Cannot delete a confirmed appointment. Cancel it first.");
      return;
    }
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Delete Appointment", style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface)),
          content: Text("Permanently delete this appointment?", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final result = await adminAppointmentService.deleteAppointment(appointment.id);
                if (!context.mounted) return;
                if (result is Success) {
                  _showSnackBar(context, "Appointment deleted");
                } else {
                  _showSnackBar(context, "Failed to delete appointment");
                }
              },
              child: Text("Delete", style: GoogleFonts.nunito(color: AppTheme.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = appointment.status.toLowerCase();
    
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        switch (value) {
          case 'confirm':
            _updateStatus(context, "Confirmed");
            break;
          case 'complete':
            _updateStatus(context, "Completed");
            break;
          case 'cancel':
            _updateStatus(context, "Cancelled");
            break;
          case 'delete':
            _deleteAppointment(context);
            break;
        }
      },
      itemBuilder: (context) => [
        if (status == 'pending')
          PopupMenuItem(
            value: 'confirm',
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppTheme.accent, size: 20),
                const SizedBox(width: 12),
                Text("Confirm", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        if (status == 'confirmed')
          PopupMenuItem(
            value: 'complete',
            child: Row(
              children: [
                const Icon(Icons.task_alt_rounded, color: Color(0xFF4C9BE8), size: 20),
                const SizedBox(width: 12),
                Text("Mark as Completed", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        if (status != 'cancelled')
          PopupMenuItem(
            value: 'cancel',
            child: Row(
              children: [
                const Icon(Icons.cancel_outlined, color: AppTheme.error, size: 20),
                const SizedBox(width: 12),
                Text("Cancel", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_forever, color: AppTheme.error, size: 20),
              const SizedBox(width: 12),
              Text("Delete", style: GoogleFonts.nunito(color: AppTheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}
