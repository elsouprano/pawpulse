import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/health_record_model.dart';
import '../../services/clinical_notes_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/result.dart';
import '../common/gradient_button.dart';

class ClinicalNotesBottomSheet extends StatefulWidget {
  final HealthRecordModel record;
  final ClinicalNotesService clinicalNotesService;
  final AuthProvider authProvider;
  final bool isEditing;

  const ClinicalNotesBottomSheet({
    super.key,
    required this.record,
    required this.clinicalNotesService,
    required this.authProvider,
    this.isEditing = false,
  });

  static void show(
    BuildContext context,
    HealthRecordModel record,
    ClinicalNotesService clinicalNotesService,
    AuthProvider authProvider, {
    bool isEditing = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClinicalNotesBottomSheet(
        record: record,
        clinicalNotesService: clinicalNotesService,
        authProvider: authProvider,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<ClinicalNotesBottomSheet> createState() =>
      _ClinicalNotesBottomSheetState();
}

class _ClinicalNotesBottomSheetState extends State<ClinicalNotesBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;
  late TextEditingController _medsController;
  late TextEditingController _actionsController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.isEditing ? widget.record.clinicalNotes : null,
    );
    _medsController = TextEditingController(
      text: widget.isEditing ? widget.record.prescribedMedications : null,
    );
    _actionsController = TextEditingController(
      text: widget.isEditing ? widget.record.recommendedActions : null,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _medsController.dispose();
    _actionsController.dispose();
    super.dispose();
  }

  void _saveClinicalNotes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    Result result;
    if (widget.isEditing) {
      result = await widget.clinicalNotesService.updateClinicalNotes(
        healthRecordId: widget.record.id,
        clinicalNotes: _notesController.text.trim(),
        prescribedMedications: _medsController.text.trim(),
        recommendedActions: _actionsController.text.trim(),
      );
    } else {
      final user = widget.authProvider.value.currentUser;
      final uid = user?.uid ?? 'unknown';
      final name = user?.displayName ?? 'Admin';

      result = await widget.clinicalNotesService.addClinicalNotes(
        healthRecordId: widget.record.id,
        clinicalNotes: _notesController.text.trim(),
        prescribedMedications: _medsController.text.trim(),
        recommendedActions: _actionsController.text.trim(),
        adminUid: uid,
        adminName: name,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result is Success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? "Clinical notes updated"
                : "Clinical notes saved successfully",
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save clinical notes")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isEditing
                                    ? "Edit Clinical Notes"
                                    : "Add Clinical Notes",
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                "Pet health record · ${widget.record.type}",
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Record info card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Adding notes as Dr. ${widget.authProvider.value.currentUser?.displayName ?? 'Admin'}",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Clinical Observations & Diagnosis",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText:
                                  "Enter your clinical observations, symptoms noted, and diagnosis...",
                            ),
                            style: GoogleFonts.nunito(
                              color: theme.colorScheme.onSurface,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty)
                                return "This field is required";
                              if (val.trim().length < 10)
                                return "Please enter at least 10 characters";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          Text(
                            "Prescribed Medications",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _medsController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText:
                                  "e.g. Amoxicillin 50mg twice daily for 7 days, Vitamin B complex supplement...",
                            ),
                            style: GoogleFonts.nunito(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            "Recommended Actions for Owner",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _actionsController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText:
                                  "e.g. Keep pet indoors and rested for 3 days, ensure fresh water availability, follow-up check in 2 weeks, monitor food intake daily...",
                            ),
                            style: GoogleFonts.nunito(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 24),

                          GradientButton(
                            label: widget.isEditing
                                ? "Update Clinical Notes"
                                : "Save Clinical Notes",
                            isLoading: _isSaving,
                            onPressed: _saveClinicalNotes,
                          ),
                          const SizedBox(height: 8),

                          Center(
                            child: Text(
                              "⚕️ These notes will be visible to the pet owner in their health records.",
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (isKeyboardOpen) const SizedBox(height: 200),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
