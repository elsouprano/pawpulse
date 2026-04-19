import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/pet_model.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../theme/app_theme.dart';
import '../common/gradient_button.dart';
import '../common/error_card.dart';

class BookAppointmentBottomSheet extends StatefulWidget {
  final AppointmentProvider appointmentProvider;
  final List<PetModel> pets;

  const BookAppointmentBottomSheet({
    super.key,
    required this.appointmentProvider,
    required this.pets,
  });

  static void show(BuildContext context, AppointmentProvider appointmentProvider, List<PetModel> pets) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => BookAppointmentBottomSheet(
        appointmentProvider: appointmentProvider,
        pets: pets,
      ),
    );
  }

  @override
  State<BookAppointmentBottomSheet> createState() => _BookAppointmentBottomSheetState();
}

class _BookAppointmentBottomSheetState extends State<BookAppointmentBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _vetNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _typeValue;
  String? _petIdValue;
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _vetNameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _handleBook() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a date and time', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final appointment = AppointmentModel(
      id: const Uuid().v4(),
      petId: _petIdValue!,
      ownerId: user.uid,
      vetName: _vetNameCtrl.text.trim(),
      type: _typeValue ?? 'Check-up',
      dateTime: _selectedDateTime,
      status: 'Confirmed',
      notes: _notesCtrl.text.trim(),
    );

    await widget.appointmentProvider.bookAppointment(appointment);

    if (widget.appointmentProvider.value.error == null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment booked!', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.success,
        ),
      );
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
    String formattedTime = _selectedDateTime != null 
        ? DateFormat('EEE, MMM d · h:mm a').format(_selectedDateTime!)
        : "Select date & time";

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
                      "Book Appointment",
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
                          TextFormField(
                            controller: _vetNameCtrl,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            decoration: _buildInputDecoration("Vet Name", prefixIcon: Icons.person_outline_rounded),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _typeValue,
                            decoration: _buildInputDecoration("Type"),
                            dropdownColor: AppTheme.card,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            items: const [
                              DropdownMenuItem(value: 'Check-up', child: Text('Check-up')),
                              DropdownMenuItem(value: 'Vaccination', child: Text('Vaccination')),
                              DropdownMenuItem(value: 'Grooming', child: Text('Grooming')),
                              DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
                              DropdownMenuItem(value: 'Follow-up', child: Text('Follow-up')),
                            ],
                            onChanged: (v) => setState(() => _typeValue = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _petIdValue,
                            decoration: _buildInputDecoration("Select Pet"),
                            dropdownColor: AppTheme.card,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            items: widget.pets.map((pet) {
                              String emoji = "🐾";
                              if (pet.species.contains('Dog')) emoji = "🐕";
                              if (pet.species.contains('Cat')) emoji = "🐈";
                              if (pet.species.contains('Bird')) emoji = "🐦";
                              if (pet.species.contains('Rabbit')) emoji = "🐇";
                              return DropdownMenuItem(
                                value: pet.id,
                                child: Text("${pet.name} $emoji"),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _petIdValue = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _pickDateTime,
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
                                    formattedTime,
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedDateTime != null ? AppTheme.textPrimary : AppTheme.textSecondary,
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
                            decoration: _buildInputDecoration("Notes", prefixIcon: Icons.notes_rounded),
                          ),
                          const SizedBox(height: 32),
                          ValueListenableBuilder(
                            valueListenable: widget.appointmentProvider,
                            builder: (context, state, child) {
                              return Column(
                                children: [
                                  GradientButton(
                                    label: "Book Appointment",
                                    isLoading: state.isLoading,
                                    onPressed: _handleBook,
                                  ),
                                  if (state.error != null) ...[
                                    const SizedBox(height: 12),
                                    ErrorCard(message: state.error!),
                                  ]
                                ],
                              );
                            },
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
