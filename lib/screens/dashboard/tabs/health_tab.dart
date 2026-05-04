import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../providers/health_record_provider.dart';
import '../../../providers/pet_provider.dart';
import '../../../services/health_record_service.dart';
import '../../../services/pet_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/health/health_record_card.dart';

import '../../../models/health_record_model.dart';

class HealthTab extends StatefulWidget {
  const HealthTab({super.key});

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  late final HealthRecordProvider _healthRecordProvider;
  late final PetProvider _petProvider;
  late final HealthRecordService _healthRecordService;
  String? _selectedPetId;
  String _filter = "All";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _healthRecordService = HealthRecordService();
    _healthRecordProvider = HealthRecordProvider(_healthRecordService);
    _petProvider = PetProvider(PetService());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        _petProvider.loadPets(user.uid);
        _petProvider.addListener(_onPetsLoaded);
      }
    });
  }

  void _onPetsLoaded() {
    if (_selectedPetId == null && _petProvider.value.petList.isNotEmpty) {
      setState(() {
        _selectedPetId = _petProvider.value.petList.first.id;
      });
      _healthRecordProvider.loadRecords(_selectedPetId!);
    }
  }

  @override
  void dispose() {
    _petProvider.removeListener(_onPetsLoaded);
    _healthRecordProvider.dispose();
    _petProvider.dispose();
    super.dispose();
  }

  Widget _buildRecordList(List<HealthRecordModel> list) {
    if (list.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(
          child: Text("No records match your search", style: GoogleFonts.nunito(fontSize: 14, color: AppTheme.textSecondary)),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety_rounded, size: 80, color: AppTheme.textSecondary.withValues(alpha: 0.2)),
            const SizedBox(height: 24),
            Text("No records found", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text("Wait for an admin to add one", style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: HealthRecordCard(record: list[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                "Health Records",
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.nunito(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: "Search by type or vet name...",
                  hintStyle: GoogleFonts.nunito(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // ── Filter Chips ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ["All", "Vaccinations", "Check-ups", "Medications"].map((label) {
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
            
            // ── Tab Views ──
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _healthRecordProvider,
                builder: (context, dynamic state, child) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }

                  final List<HealthRecordModel> allRecords = state.records;
                  final filtered = _filter == "All"
                      ? allRecords
                      : allRecords.where((r) => r.type.toLowerCase().contains(_filter.toLowerCase().replaceAll('s', ''))).toList();

                  final searchFiltered = filtered.where((r) {
                    final q = _searchQuery.toLowerCase();
                    return r.type.toLowerCase().contains(q) || (r.vetName?.toLowerCase().contains(q) ?? false);
                  }).toList();

                  return _buildRecordList(searchFiltered);
                },
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
