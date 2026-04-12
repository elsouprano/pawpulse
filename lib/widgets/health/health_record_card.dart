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
      typeColor = const Color(0xFF00D4AA); // accent
      typeIcon = Icons.vaccines;
    } else if (t.contains('check')) {
      typeColor = const Color(0xFF6C63FF); // primary
      typeIcon = Icons.medical_services;
    } else if (t.contains('medication')) {
      typeColor = const Color(0xFFFFB347);
      typeIcon = Icons.medication;
    } else {
      typeColor = AppTheme.textSecondary;
      typeIcon = Icons.health_and_safety;
    }

    final dateStr = widget.record.date != null 
        ? DateFormat('MMM d, yyyy').format(widget.record.date!) 
        : 'Unknown Date';

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: _expanded ? 120 : 64, // Approximate scaling for visual
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(typeIcon, size: 18, color: typeColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.record.type,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.record.vetName.isNotEmpty ? widget.record.vetName : "Unknown Vet",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 11,
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
                          const SizedBox(height: 10),
                          Divider(color: Colors.white.withOpacity(0.05)),
                          const SizedBox(height: 8),
                          Text("Notes", style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            widget.record.notes.isEmpty ? "No notes recorded." : widget.record.notes,
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                      crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
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
