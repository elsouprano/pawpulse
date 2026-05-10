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
                            Icon(Icons.calendar_month_rounded, size: 80, color: AppTheme.textSecondary.withValues(alpha: 0.2)),
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

                        final statusLower = appointment.status.toLowerCase();
                        final isCancelable = statusLower == 'confirmed' || statusLower == 'pending';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: AppointmentCard(
                            appointment: appointment,
                            petName: pet?.name,
                            appointmentProvider: _appointmentProvider,
                            pets: pList,
                            onCancel: isCancelable ? () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  backgroundColor: AppTheme.surface,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Text("Cancel Appointment", style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                                  content: Text(
                                    "Are you sure you want to cancel this appointment?",
                                    style: GoogleFonts.nunito(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext),
                                      child: Text("No", style: GoogleFonts.nunito(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(dialogContext);
                                        await _appointmentProvider.cancelAppointment(appointment.id);
                                        if (!context.mounted) return;
                                        if (_appointmentProvider.value.error == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Appointment cancelled', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                                              backgroundColor: AppTheme.success,
                                            ),
                                          );
                                        }
                                      },
                                      child: Text("Yes, Cancel", style: GoogleFonts.nunito(color: AppTheme.error, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            } : null,
                            onReschedule: isCancelable ? () {
                              if (_petProvider.value.petList.isEmpty) return;
                              BookAppointmentBottomSheet.show(context, _appointmentProvider, _petProvider.value.petList);
                            } : null,
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
          color: isActive ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.1),
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
