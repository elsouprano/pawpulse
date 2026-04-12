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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            onPrimary: Colors.white,
            surface: AppTheme.surface,
            onSurface: Colors.white,
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
          const SnackBar(content: Text('Record saved!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save record.')),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textSecondary) : null,
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFF94A3B8).withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFF94A3B8).withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      "Add Health Record",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                            dropdownColor: AppTheme.background,
                            items: const [
                              DropdownMenuItem(value: 'Vaccination', child: Text('Vaccination')),
                              DropdownMenuItem(value: 'Check-up', child: Text('Check-up')),
                              DropdownMenuItem(value: 'Medication', child: Text('Medication')),
                              DropdownMenuItem(value: 'Other', child: Text('Other')),
                            ],
                            onChanged: (v) => setState(() => _typeValue = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _vetNameCtrl,
                            decoration: _buildInputDecoration("Vet Name", prefixIcon: Icons.person_outline),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A2E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.textSecondary.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesCtrl,
                            maxLines: 3,
                            decoration: _buildInputDecoration("Notes (optional)", prefixIcon: Icons.notes_outlined),
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            label: "Save Record",
                            isLoading: _isLoading,
                            onPressed: _handleSave,
                          ),
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
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
