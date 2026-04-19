import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/health_record_model.dart';
import '../../services/health_record_service.dart';
import '../../core/utils/result.dart';
import '../../theme/app_theme.dart';
import '../common/gradient_button.dart';

class AddHealthRecordBottomSheet extends StatefulWidget {
  final HealthRecordService healthRecordService;
  final String petId;

  const AddHealthRecordBottomSheet({
    super.key,
    required this.healthRecordService,
    required this.petId,
  });

  static void show(BuildContext context, HealthRecordService healthRecordService, String petId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => AddHealthRecordBottomSheet(
        healthRecordService: healthRecordService,
        petId: petId,
      ),
    );
  }

  @override
  State<AddHealthRecordBottomSheet> createState() => _AddHealthRecordBottomSheetState();
}

class _AddHealthRecordBottomSheetState extends State<AddHealthRecordBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _vetNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _typeValue;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _vetNameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            onPrimary: AppTheme.background,
            surface: AppTheme.surface,
            onSurface: AppTheme.textPrimary,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
          ),
        ),
        child: child!,
      ),
    );

    if (date != null && mounted) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final record = HealthRecordModel(
      id: const Uuid().v4(),
      petId: widget.petId,
      type: _typeValue ?? 'Other',
      date: _selectedDate,
      vetName: _vetNameCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    final result = await widget.healthRecordService.addHealthRecord(record);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result is! Failure) { // Wait, result handling logic depends on how Failure is returned
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record saved!', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save record.', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.nunito(color: AppTheme.textSecondary),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textSecondary) : null,
      filled: true,
      fillColor: AppTheme.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMM d, yyyy').format(_selectedDate);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  children: [
                    Text(
                      "Add Health Record",
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _typeValue,
                            decoration: _buildInputDecoration("Type"),
                            dropdownColor: AppTheme.card,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            items: const [
                              DropdownMenuItem(value: 'Vaccination', child: Text('Vaccination')),
                              DropdownMenuItem(value: 'Check-up', child: Text('Check-up')),
                              DropdownMenuItem(value: 'Medication', child: Text('Medication')),
                              DropdownMenuItem(value: 'Other', child: Text('Other')),
                            ],
                            onChanged: (v) => setState(() => _typeValue = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _vetNameCtrl,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            decoration: _buildInputDecoration("Vet Name", prefixIcon: Icons.person_outline_rounded),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    formattedDate,
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesCtrl,
                            maxLines: 3,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            decoration: _buildInputDecoration("Notes (optional)", prefixIcon: Icons.notes_rounded),
                          ),
                          const SizedBox(height: 32),
                          GradientButton(
                            label: "Save Record",
                            isLoading: _isLoading,
                            onPressed: _handleSave,
                          ),
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
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
