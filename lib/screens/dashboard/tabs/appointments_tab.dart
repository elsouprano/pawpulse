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
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final pets = _petProvider.value.petList;
          if (pets.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please add a pet first', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                backgroundColor: AppTheme.primary,
              ),
            );
            return;
          }
          BookAppointmentBottomSheet.show(context, _appointmentProvider, pets);
        },
        backgroundColor: AppTheme.primary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: AppTheme.background, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    "Appointments",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            // ── Filter Chips ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            Icon(Icons.calendar_month_rounded, size: 80, color: AppTheme.textSecondary.withOpacity(0.2)),
                            const SizedBox(height: 24),
                            Text(
                              "No $_filter appointments",
                              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tap Book to schedule one",
                              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final appointment = filtered[index];
                        // Find pet name
                        final pList = _petProvider.value.petList;
                        final pet = pList.where((p) => p.id == appointment.petId).firstOrNull;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: AppointmentCard(
                            appointment: appointment,
                            petName: pet?.name,
                            onCancel: () async {
                              await _appointmentProvider.cancelAppointment(appointment.id);
                              if (mounted && _appointmentProvider.value.error == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Appointment cancelled', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                                    backgroundColor: AppTheme.success,
                                  ),
                                );
                              }
                            },
                            onReschedule: () {
                              if (_petProvider.value.petList.isEmpty) return;
                              BookAppointmentBottomSheet.show(context, _appointmentProvider, _petProvider.value.petList);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.1),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
