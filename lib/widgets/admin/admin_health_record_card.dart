import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/health_record_model.dart';
import '../../services/clinical_notes_service.dart';
import '../../providers/auth_provider.dart';
import 'clinical_notes_bottom_sheet.dart';

class AdminHealthRecordCard extends StatelessWidget {
  final HealthRecordModel record;
  final ClinicalNotesService clinicalNotesService;
  final AuthProvider authProvider;

  const AdminHealthRecordCard({
    super.key,
    required this.record,
    required this.clinicalNotesService,
    required this.authProvider,
  });

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination': return Icons.vaccines_outlined;
      case 'check-up': 
      case 'checkup': return Icons.monitor_heart_outlined;
      case 'surgery': return Icons.medical_services_outlined;
      case 'medication': return Icons.medication_outlined;
      default: return Icons.health_and_safety_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination': return AppTheme.primary;
      case 'check-up':
      case 'checkup': return AppTheme.accent;
      case 'surgery': return AppTheme.error;
      case 'medication': return const Color(0xFFFFD166);
      default: return AppTheme.textSecondary;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Remove Clinical Notes", style: GoogleFonts.outfit(color: theme.colorScheme.onSurface)),
          content: Text("Are you sure you want to remove the clinical notes from this record?", style: GoogleFonts.nunito(color: theme.colorScheme.onSurfaceVariant)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: GoogleFonts.nunito(color: theme.colorScheme.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await clinicalNotesService.removeClinicalNotes(record.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Clinical notes removed")),
                  );
                }
              },
              child: Text("Remove", style: GoogleFonts.nunito(color: AppTheme.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _getTypeColor(record.type);
    
    String formattedDate = "Unknown Date";
    if (record.date != null) {
      formattedDate = DateFormat("MMM d, yyyy").format(record.date!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerTheme.color ?? AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_getTypeIcon(record.type), size: 18, color: typeColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.type,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                record.vetName,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formattedDate,
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (record.clinicalNotes != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Notes Added",
                                  style: GoogleFonts.nunito(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accent,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "No Notes",
                                  style: GoogleFonts.nunito(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    
                    if (record.clinicalNotes != null) ...[
                      const SizedBox(height: 10),
                      Divider(color: theme.dividerTheme.color),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.medical_information_outlined, size: 14, color: AppTheme.accent),
                          const SizedBox(width: 6),
                          Text(
                            "Dr. ${record.addedByAdminName}",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.clinicalNotes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (record.clinicalNotes == null)
                          TextButton.icon(
                            onPressed: () {
                              ClinicalNotesBottomSheet.show(context, record, clinicalNotesService, authProvider, isEditing: false);
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text("Add Clinical Notes"),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              textStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          )
                        else ...[
                          TextButton.icon(
                            onPressed: () {
                              ClinicalNotesBottomSheet.show(context, record, clinicalNotesService, authProvider, isEditing: true);
                            },
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text("Edit Notes"),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              textStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _showDeleteConfirmation(context),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text("Remove"),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.error,
                              textStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
