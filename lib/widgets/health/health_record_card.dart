import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/health_record_model.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class HealthRecordCard extends StatefulWidget {
  final HealthRecordModel record;

  const HealthRecordCard({super.key, required this.record});

  @override
  State<HealthRecordCard> createState() => _HealthRecordCardState();
}

class _HealthRecordCardState extends State<HealthRecordCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    IconData typeIcon;

    final t = widget.record.type.toLowerCase();
    if (t.contains('vaccination')) {
      typeColor = AppTheme.accent;
      typeIcon = Icons.vaccines_rounded;
    } else if (t.contains('check')) {
      typeColor = AppTheme.primary;
      typeIcon = Icons.medical_services_rounded;
    } else if (t.contains('medication')) {
      typeColor = AppTheme.secondary;
      typeIcon = Icons.medication_rounded;
    } else {
      typeColor = AppTheme.textSecondary;
      typeIcon = Icons.health_and_safety_rounded;
    }

    final dateStr = widget.record.date != null 
        ? DateFormat('MMM d, yyyy').format(widget.record.date!) 
        : 'Unknown Date';

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
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
        child: ClipRRect(
          borderRadius: AppTheme.cardRadius,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  color: typeColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(typeIcon, size: 22, color: typeColor),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.record.type,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.record.vetName.isNotEmpty ? "Dr. ${widget.record.vetName}" : "Unknown Vet",
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              dateStr,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 16),
                              Divider(color: AppTheme.textSecondary.withOpacity(0.1)),
                              const SizedBox(height: 12),
                              Text("Notes", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                              const SizedBox(height: 6),
                              Text(
                                widget.record.notes.isEmpty ? "No additional notes." : widget.record.notes,
                                style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary, height: 1.5),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                          firstCurve: Curves.easeOutCubic,
                          secondCurve: Curves.easeOutCubic,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
