import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../providers/health_record_provider.dart';
import '../../../providers/pet_provider.dart';
import '../../../services/health_record_service.dart';
import '../../../services/pet_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/health/health_record_card.dart';
import '../../../widgets/health/add_health_record_bottom_sheet.dart';
import '../../../models/health_record_model.dart';

class HealthTab extends StatefulWidget {
  const HealthTab({super.key});

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> with SingleTickerProviderStateMixin {
  late final HealthRecordProvider _healthRecordProvider;
  late final PetProvider _petProvider;
  late final HealthRecordService _healthRecordService;
  late TabController _tabController;

  String? _selectedPetId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildRecordList(List<HealthRecordModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text("No records found", style: GoogleFonts.spaceGrotesk(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 8),
            Text("Add a record using the + button", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return HealthRecordCard(record: list[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                "Health Records",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            // ── Tab Selector ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppTheme.primary.withOpacity(0.2),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "All"),
                    Tab(text: "Vaccinations"),
                    Tab(text: "Check-ups"),
                    Tab(text: "Medications"),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // ── Tab Views ──
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _healthRecordProvider,
                builder: (context, dynamic state, child) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }

                  final List<HealthRecordModel> allRecords = state.records;

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRecordList(allRecords),
                      _buildRecordList(allRecords.where((r) => r.type.toLowerCase().contains("vaccination")).toList()),
                      _buildRecordList(allRecords.where((r) => r.type.toLowerCase().contains("check")).toList()),
                      _buildRecordList(allRecords.where((r) => r.type.toLowerCase().contains("medication")).toList()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedPetId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please add a pet first")),
            );
            return;
          }
          AddHealthRecordBottomSheet.show(context, _healthRecordService, _selectedPetId!);
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
