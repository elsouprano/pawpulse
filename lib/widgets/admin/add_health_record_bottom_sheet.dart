import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../models/pet_model.dart';
import '../../theme/app_theme.dart';
import '../common/gradient_button.dart';

class AddHealthRecordBottomSheet extends StatefulWidget {
  const AddHealthRecordBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddHealthRecordBottomSheet(),
    );
  }

  @override
  State<AddHealthRecordBottomSheet> createState() => _AddHealthRecordBottomSheetState();
}

class _AddHealthRecordBottomSheetState extends State<AddHealthRecordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _vetNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedPetId;
  String _selectedType = 'Vaccination';
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextVaccinationDate;
  bool _isSaving = false;

  final List<String> _types = ['Vaccination', 'Check-up', 'Medication', 'Other'];

  @override
  void dispose() {
    _vetNameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
      prefixIcon: icon != null ? Icon(icon, color: AppTheme.primary, size: 20) : null,
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.error, width: 1.5)),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickNextVaccinationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextVaccinationDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTheme.secondary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _nextVaccinationDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a pet', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final id = const Uuid().v4();
      final data = <String, dynamic>{
        'petId': _selectedPetId,
        'type': _selectedType,
        'date': Timestamp.fromDate(_selectedDate),
        'vetName': _vetNameCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'attachmentUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (_selectedType == 'Vaccination' && _nextVaccinationDate != null) {
        data['nextVaccinationDate'] = Timestamp.fromDate(_nextVaccinationDate!);
      }
      await FirebaseFirestore.instance.collection('health_records').doc(id).set(data);

      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Health record added successfully', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
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
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Health Record',
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Create a new health record for a pet',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pet selector
                          Text('Pet', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('pets').orderBy('createdAt', descending: true).snapshots(),
                            builder: (context, snapshot) {
                              final pets = (snapshot.data?.docs ?? [])
                                  .map((doc) => PetModel.fromFirestore(doc))
                                  .toList();

                              return DropdownButtonFormField<String>(
                                initialValue: _selectedPetId,
                                decoration: _inputDecoration('Select a pet', icon: Icons.pets_rounded),
                                dropdownColor: theme.colorScheme.surface,
                                style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                                hint: Text('Choose a pet...', style: GoogleFonts.nunito(color: theme.colorScheme.onSurfaceVariant)),
                                items: pets.map((pet) {
                                  String emoji = '🐾';
                                  if (pet.species.contains('Dog')) {
                                    emoji = '🐕';
                                  } else if (pet.species.contains('Cat')) {
                                    emoji = '🐈';
                                  } else if (pet.species.contains('Bird')) {
                                    emoji = '🐦';
                                  } else if (pet.species.contains('Rabbit')) {
                                    emoji = '🐇';
                                  }
                                  return DropdownMenuItem<String>(
                                    value: pet.id,
                                    child: Text('$emoji  ${pet.name}', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedPetId = val),
                                validator: (val) => val == null ? 'Please select a pet' : null,
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Vet name
                          Text('Vet Name', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _vetNameCtrl,
                            style: GoogleFonts.nunito(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
                            decoration: _inputDecoration('e.g. Dr. Santos', icon: Icons.person_outline_rounded),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Vet name is required' : null,
                          ),
                          const SizedBox(height: 16),

                          // Record type
                          Text('Record Type', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedType,
                            decoration: _inputDecoration('Select type', icon: Icons.category_outlined),
                            dropdownColor: theme.colorScheme.surface,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                            items: _types.map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                            )).toList(),
                            onChanged: (val) { if (val != null) setState(() => _selectedType = val); },
                          ),
                          const SizedBox(height: 16),

                          // Next Vaccination Due Date (conditional)
                          if (_selectedType == 'Vaccination') ...[
                            Row(
                              children: [
                                Text(
                                  'Next Vaccination Due Date',
                                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Optional',
                                    style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickNextVaccinationDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _nextVaccinationDate != null
                                        ? AppTheme.secondary.withValues(alpha: 0.5)
                                        : AppTheme.secondary.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.vaccines_outlined,
                                      color: AppTheme.secondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _nextVaccinationDate != null
                                          ? '${_nextVaccinationDate!.day}/${_nextVaccinationDate!.month}/${_nextVaccinationDate!.year}'
                                          : 'Select due date (optional)',
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _nextVaccinationDate != null
                                            ? theme.colorScheme.onSurface
                                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_nextVaccinationDate != null)
                                      GestureDetector(
                                        onTap: () => setState(() => _nextVaccinationDate = null),
                                        child: Icon(Icons.close_rounded, color: AppTheme.secondary, size: 18),
                                      )
                                    else
                                      Text('Tap to set', style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.secondary)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Date picker
                          Text('Date', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                                  ),
                                  const Spacer(),
                                  Text('Tap to change', style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.primary)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Notes
                          Text('Notes', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _notesCtrl,
                            maxLines: 4,
                            style: GoogleFonts.nunito(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
                            decoration: _inputDecoration('Enter any notes or observations...'),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Notes are required' : null,
                          ),
                          const SizedBox(height: 28),

                          GradientButton(
                            label: 'Save Health Record',
                            isLoading: _isSaving,
                            onPressed: _save,
                          ),
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
