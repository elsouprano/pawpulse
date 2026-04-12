import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../providers/appointment_provider.dart';
import '../../../providers/pet_provider.dart';
import '../../../services/appointment_service.dart';
import '../../../services/pet_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/appointments/appointment_card.dart';
import '../../../widgets/appointments/book_appointment_bottom_sheet.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../models/appointment_model.dart';

class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({super.key});

  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  late final AppointmentProvider _appointmentProvider;
  late final PetProvider _petProvider;
  String _filter = "All";

  @override
  void initState() {
    super.initState();
    _appointmentProvider = AppointmentProvider(AppointmentService());
    _petProvider = PetProvider(PetService());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        _appointmentProvider.loadAppointments(user.uid);
        _petProvider.loadPets(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _appointmentProvider.dispose();
    _petProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(
                  "Appointments",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 130,
                  height: 38,
                  child: GradientButton(
                    label: "Book",
                    onPressed: () {
                      final pets = _petProvider.value.petList;
                      if (pets.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please add a pet first')),
                        );
                        return;
                      }
                      BookAppointmentBottomSheet.show(context, _appointmentProvider, pets);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // ── Filter Chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["All", "Confirmed", "Pending", "Cancelled"].map((label) {
                  return _FilterChip(
                    label: label,
                    isActive: _filter == label,
                    onTap: () => setState(() => _filter = label),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // ── List ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder(
                valueListenable: _appointmentProvider,
                builder: (context, dynamic state, child) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }

                  final List<AppointmentModel> all = state.appointments;
                  final filtered = _filter == "All" 
                      ? all 
                      : all.where((a) => a.status.toLowerCase() == _filter.toLowerCase()).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.4)),
                          const SizedBox(height: 16),
                          Text(
                            "No $_filter appointments",
                            style: GoogleFonts.spaceGrotesk(fontSize: 18, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tap Book to schedule one",
                            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final appointment = filtered[index];
                      // Find pet name
                      final pList = _petProvider.value.petList;
                      final pet = pList.where((p) => p.id == appointment.petId).firstOrNull;

                      return AppointmentCard(
                        appointment: appointment,
                        petName: pet?.name,
                        onCancel: () async {
                          await _appointmentProvider.cancelAppointment(appointment.id);
                          if (mounted && _appointmentProvider.value.error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Appointment cancelled')),
                            );
                          }
                        },
                        onReschedule: () {
                          if (_petProvider.value.petList.isEmpty) return;
                          BookAppointmentBottomSheet.show(context, _appointmentProvider, _petProvider.value.petList);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
