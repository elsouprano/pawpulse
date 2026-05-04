import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../models/appointment_model.dart';
import '../../../services/admin_appointment_service.dart';
import '../../../services/admin_pet_service.dart';
import '../../../widgets/admin/admin_appointment_card.dart';
import '../../../widgets/admin/appointment_action_menu.dart';
import '../../../core/utils/result.dart';

class AdminAppointmentsTab extends StatefulWidget {
  const AdminAppointmentsTab({super.key});

  @override
  State<AdminAppointmentsTab> createState() => _AdminAppointmentsTabState();
}

class _AdminAppointmentsTabState extends State<AdminAppointmentsTab> {
  final AdminAppointmentService _adminAppointmentService = AdminAppointmentService();
  final AdminPetService _adminPetService = AdminPetService();
  
  String _statusFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        return Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Appointments",
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        "All appointments across users",
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  StreamBuilder<List<AppointmentModel>>(
                    stream: _adminAppointmentService.watchAllAppointments(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "$count total",
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by vet name or type...",
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── Status Filter Chips ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["All", "Confirmed", "Pending", "Cancelled"].map((status) {
                    return _FilterChip(
                      label: status,
                      isActive: _statusFilter == status,
                      onTap: () {
                        setState(() {
                          _statusFilter = status;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Appointments List ──
            Expanded(
              child: StreamBuilder<List<AppointmentModel>>(
                stream: _adminAppointmentService.watchAllAppointments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error fetching appointments", style: GoogleFonts.nunito(color: AppTheme.error)));
                  }

                  var appointments = snapshot.data ?? [];

                  // Apply filters
                  if (_searchQuery.isNotEmpty) {
                    appointments = appointments.where((a) =>
                        a.vetName.toLowerCase().contains(_searchQuery) ||
                        a.type.toLowerCase().contains(_searchQuery)).toList();
                  }
                  if (_statusFilter != 'All') {
                    appointments = appointments.where((a) => a.status.toLowerCase() == _statusFilter.toLowerCase()).toList();
                  }

                  if (appointments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                          SizedBox(height: 8),
                          Text("No appointments found", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }

                  if (isDesktop) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 24,
                          headingRowColor: WidgetStateProperty.all((Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface)),
                          dataRowColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.hovered)
                                  ? AppTheme.primary.withValues(alpha: 0.05)
                                  : Theme.of(context).colorScheme.surface),
                          columns: [
                            DataColumn(label: Text("Date", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            DataColumn(label: Text("Vet Name", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            DataColumn(label: Text("Type", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            DataColumn(label: Text("Pet", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            DataColumn(label: Text("Owner", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            DataColumn(label: Text("Status", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                            DataColumn(label: Text("Actions", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                          ],
                          rows: appointments.map((a) {
                            String formattedDate = "Unknown";
                            if (a.dateTime != null) {
                              formattedDate = DateFormat("MMM d, yyyy · h:mm a").format(a.dateTime!);
                            }
                            return DataRow(
                              cells: [
                                DataCell(Text(formattedDate, style: GoogleFonts.nunito(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                DataCell(Text(a.vetName, style: GoogleFonts.nunito(fontSize: 14, color: Theme.of(context).colorScheme.onSurface))),
                                DataCell(Text(a.type, style: GoogleFonts.nunito(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                DataCell(FutureBuilder(
                                  future: _adminPetService.getPetById(a.petId),
                                  builder: (context, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) return const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary));
                                    String name = "Unknown";
                                    if (snap.hasData && snap.data is Success) {
                                      name = (snap.data as dynamic).value.name;
                                    }
                                    return Text(name, style: GoogleFonts.nunito(fontSize: 13, color: Theme.of(context).colorScheme.onSurface));
                                  },
                                )),
                                DataCell(FutureBuilder(
                                  future: _adminPetService.getOwnerByUid(a.ownerId),
                                  builder: (context, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) return const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary));
                                    String name = "Unknown";
                                    if (snap.hasData && snap.data is Success) {
                                      name = (snap.data as dynamic).value.name;
                                    }
                                    return Text(name, style: GoogleFonts.nunito(fontSize: 13, color: Theme.of(context).colorScheme.onSurface));
                                  },
                                )),
                                DataCell(_StatusChip(status: a.status)),
                                DataCell(AppointmentActionMenu(appointment: a, adminAppointmentService: _adminAppointmentService)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        return AdminAppointmentCard(
                          appointment: appointments[index],
                          adminAppointmentService: _adminAppointmentService,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withValues(alpha: 0.15) : (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.primary : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isActive ? AppTheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = AppTheme.accent;
        break;
      case 'pending':
        color = AppTheme.secondary;
        break;
      case 'cancelled':
        color = AppTheme.error;
        break;
      default:
        color = Theme.of(context).colorScheme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
