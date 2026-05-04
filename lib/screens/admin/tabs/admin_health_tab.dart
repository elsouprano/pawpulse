import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../models/health_record_model.dart';
import '../../../models/pet_model.dart';
import '../../../services/admin_stats_service.dart';
import '../../../services/clinical_notes_service.dart';
import '../../../services/admin_pet_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/admin/admin_health_record_card.dart';
import '../../../widgets/admin/clinical_notes_bottom_sheet.dart';
import '../../../core/utils/result.dart';
import '../../../widgets/admin/add_health_record_bottom_sheet.dart';

class AdminHealthTab extends StatefulWidget {
  final AuthProvider authProvider;
  
  const AdminHealthTab({super.key, required this.authProvider});

  @override
  State<AdminHealthTab> createState() => _AdminHealthTabState();
}

class _AdminHealthTabState extends State<AdminHealthTab> {
  final AdminStatsService _statsService = AdminStatsService();
  final ClinicalNotesService _clinicalNotesService = ClinicalNotesService();
  final AdminPetService _petService = AdminPetService();

  String _searchQuery = '';
  String _typeFilter = 'All';
  String _clinicalFilter = 'All';

  final List<String> _types = ["All", "Vaccination", "Check-up", "Medication", "Other"];
  final List<String> _clinicalFilters = ["All", "With Notes", "Without Notes"];

  Widget _buildFilterChip(String label, String currentVal, Function(String) onSelected) {
    final theme = Theme.of(context);
    final isSelected = label == currentVal;
    return GestureDetector(
      onTap: () => onSelected(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : (theme.cardTheme.color ?? theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primary : theme.dividerTheme.color ?? AppTheme.primary.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.textPrimary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    Color color;
    switch (type.toLowerCase()) {
      case 'vaccination': color = AppTheme.primary; break;
      case 'check-up':
      case 'checkup': color = AppTheme.accent; break;
      case 'surgery': color = AppTheme.error; break;
      case 'medication': color = const Color(0xFFFFD166); break;
      default: color = AppTheme.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        type,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, HealthRecordModel record) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Remove Clinical Notes", style: GoogleFonts.outfit(color: theme.colorScheme.onSurface)),
          content: Text("Are you sure you want to remove the clinical notes from this record?", style: GoogleFonts.nunito(color: theme.colorScheme.onSurfaceVariant)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: GoogleFonts.nunito(color: theme.colorScheme.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _clinicalNotesService.removeClinicalNotes(record.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Clinical notes removed")),
                  );
                }
              },
              child: Text("Remove", style: GoogleFonts.nunito(color: AppTheme.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<HealthRecordModel>>(
      stream: _statsService.watchAllHealthRecords(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];
        
        // Filter records
        final filteredRecords = records.where((r) {
          final matchesSearch = _searchQuery.isEmpty || 
                                r.vetName.toLowerCase().contains(_searchQuery) ||
                                r.type.toLowerCase().contains(_searchQuery);
          final matchesType = _typeFilter == 'All' || r.type.toLowerCase() == _typeFilter.toLowerCase();
          
          bool matchesClinical = true;
          if (_clinicalFilter == 'With Notes') matchesClinical = r.clinicalNotes != null;
          if (_clinicalFilter == 'Without Notes') matchesClinical = r.clinicalNotes == null;

          return matchesSearch && matchesType && matchesClinical;
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 768;

            return Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: FloatingActionButton(
                onPressed: () => AddHealthRecordBottomSheet.show(context),
                backgroundColor: AppTheme.primary,
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.add_rounded, color: AppTheme.background, size: 28),
              ),
              body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Health Records",
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              "View and annotate pet health records",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${records.length} records",
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    style: GoogleFonts.nunito(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "Search by vet name or type...",
                      prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        ..._types.map((type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(type, _typeFilter, (val) => setState(() => _typeFilter = val)),
                        )),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 24, color: theme.dividerTheme.color),
                        const SizedBox(width: 16),
                        ..._clinicalFilters.map((cf) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(cf, _clinicalFilter, (val) => setState(() => _clinicalFilter = val)),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Records List
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting && records.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredRecords.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text(
                                "No health records found",
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : isDesktop
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Pet')),
                                  DataColumn(label: Text('Vet Name')),
                                  DataColumn(label: Text('Type')),
                                  DataColumn(label: Text('Clinical Notes')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: filteredRecords.map((r) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(r.date != null ? DateFormat('MMM d, yyyy').format(r.date!) : '--')),
                                      DataCell(
                                        FutureBuilder<Result<PetModel, Exception>>(
                                          future: _petService.getPetById(r.petId),
                                          builder: (context, petSnap) {
                                            if (petSnap.hasData) {
                                              final res = petSnap.data!;
                                              if (res is Success<PetModel, Exception>) {
                                                return Text(res.value.name);
                                              }
                                            }
                                            return const Text('Loading...');
                                          },
                                        ),
                                      ),
                                      DataCell(Text(r.vetName)),
                                      DataCell(_buildTypeChip(r.type)),
                                      DataCell(
                                        r.clinicalNotes != null
                                          ? Row(
                                              children: [
                                                const Icon(Icons.check_circle, size: 16, color: AppTheme.accent),
                                                const SizedBox(width: 4),
                                                Text("Added", style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.accent)),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                const Icon(Icons.add_circle_outline, size: 16, color: AppTheme.primary),
                                                const SizedBox(width: 4),
                                                Text("Add Notes", style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.primary)),
                                              ],
                                            ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            if (r.clinicalNotes == null)
                                              IconButton(
                                                icon: const Icon(Icons.add, size: 18),
                                                color: AppTheme.primary,
                                                onPressed: () => ClinicalNotesBottomSheet.show(context, r, _clinicalNotesService, widget.authProvider, isEditing: false),
                                              )
                                            else ...[
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, size: 18),
                                                color: AppTheme.primary,
                                                onPressed: () => ClinicalNotesBottomSheet.show(context, r, _clinicalNotesService, widget.authProvider, isEditing: true),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, size: 18),
                                                color: AppTheme.error,
                                                onPressed: () => _showDeleteConfirmation(context, r),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredRecords.length,
                            itemBuilder: (context, index) {
                              return AdminHealthRecordCard(
                                record: filteredRecords[index],
                                clinicalNotesService: _clinicalNotesService,
                                authProvider: widget.authProvider,
                              );
                            },
                          ),
                ),
              ],
            ),
            );
          },
        );
      },
    );
  }
}
