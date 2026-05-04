import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/pet_model.dart';
import '../../../services/admin_pet_service.dart';
import '../../../widgets/admin/admin_pet_card.dart';

class AdminPetsTab extends StatefulWidget {
  const AdminPetsTab({super.key});

  @override
  State<AdminPetsTab> createState() => _AdminPetsTabState();
}

class _AdminPetsTabState extends State<AdminPetsTab> {
  final AdminPetService _adminPetService = AdminPetService();
  String _searchQuery = '';
  String _speciesFilter = 'All';
  String _statusFilter = 'All';

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
                        "Pet Management",
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        "All registered pets across users",
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  StreamBuilder<List<PetModel>>(
                    stream: _adminPetService.watchAllPets(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "$count pets",
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
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
                  hintText: "Search by pet name or breed...",
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

            // ── Filter Row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Species filter chips
                    ...["All", "Dog", "Cat", "Bird", "Rabbit", "Other"].map((species) {
                      return _FilterChip(
                        label: species,
                        isActive: _speciesFilter == species,
                        onTap: () {
                          setState(() {
                            _speciesFilter = species;
                          });
                        },
                      );
                    }),
                    SizedBox(width: 8),
                    SizedBox(
                      height: 24,
                      child: VerticalDivider(
                        color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
                        thickness: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Health status filter chips
                    ...["All", "Healthy", "Needs Attention", "Critical"].map((status) {
                      return _FilterChip(
                        label: status,
                        isActive: _statusFilter == status,
                        onTap: () {
                          setState(() {
                            _statusFilter = status;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Pets List ──
            Expanded(
              child: StreamBuilder<List<PetModel>>(
                stream: _adminPetService.watchAllPets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error fetching pets", style: GoogleFonts.nunito(color: AppTheme.error)));
                  }

                  var pets = snapshot.data ?? [];

                  // Apply filters
                  if (_searchQuery.isNotEmpty) {
                    pets = pets.where((p) =>
                        p.name.toLowerCase().contains(_searchQuery) ||
                        p.breed.toLowerCase().contains(_searchQuery)).toList();
                  }
                  if (_speciesFilter != 'All') {
                    pets = pets.where((p) {
                      if (_speciesFilter == 'Other') {
                        return !['dog', 'cat', 'bird', 'rabbit']
                            .any((s) => p.species.toLowerCase().contains(s));
                      }
                      return p.species.toLowerCase().contains(_speciesFilter.toLowerCase());
                    }).toList();
                  }
                  if (_statusFilter != 'All') {
                    pets = pets.where((p) => p.healthStatus.toLowerCase() == _statusFilter.toLowerCase()).toList();
                  }

                  if (pets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                          SizedBox(height: 8),
                          Text("No pets found", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      return AdminPetCard(
                        pet: pets[index],
                        adminPetService: _adminPetService,
                      );
                    },
                  );
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
