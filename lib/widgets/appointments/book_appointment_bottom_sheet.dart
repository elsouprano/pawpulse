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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            onPrimary: Colors.white,
            surface: AppTheme.surface,
            onSurface: Colors.white,
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
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: Colors.white,
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
        const SnackBar(content: Text('Please select a date and time')),
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
      status: 'Pending',
      notes: _notesCtrl.text.trim(),
    );

    await widget.appointmentProvider.bookAppointment(appointment);

    if (widget.appointmentProvider.value.error == null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked!')),
      );
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
                      "Book Appointment",
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
                          TextFormField(
                            controller: _vetNameCtrl,
                            decoration: _buildInputDecoration("Vet Name", prefixIcon: Icons.person_outline),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _typeValue,
                            decoration: _buildInputDecoration("Type"),
                            dropdownColor: AppTheme.background,
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
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _petIdValue,
                            decoration: _buildInputDecoration("Select Pet"),
                            dropdownColor: AppTheme.background,
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
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _pickDateTime,
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
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _selectedDateTime != null ? Colors.white : AppTheme.textSecondary,
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
                            decoration: _buildInputDecoration("Notes", prefixIcon: Icons.notes_outlined),
                          ),
                          const SizedBox(height: 24),
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
                                    const SizedBox(height: 8),
                                    ErrorCard(message: state.error!),
                                  ]
                                ],
                              );
                            },
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
