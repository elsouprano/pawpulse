import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../providers/pet_provider.dart';
import '../../../services/pet_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pets/pet_card.dart';
import '../../../widgets/pets/add_pet_bottom_sheet.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../scanner/ai_scanner_screen.dart';

class MyPetsTab extends StatefulWidget {
  const MyPetsTab({super.key});

  @override
  State<MyPetsTab> createState() => _MyPetsTabState();
}

class _MyPetsTabState extends State<MyPetsTab> {
  late final PetProvider _petProvider;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _petProvider = PetProvider(PetService());
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      _petProvider.loadPets(user.uid);
    }
  }

  @override
  void dispose() {
    _petProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddPetBottomSheet.show(context, _petProvider),
        backgroundColor: AppTheme.primary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: AppTheme.background, size: 28),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Text("My Pets", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add_rounded, color: AppTheme.primary),
                          onPressed: () => AddPetBottomSheet.show(context, _petProvider),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: GoogleFonts.nunito(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: "Search pets by name or breed...",
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
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _petProvider,
                    builder: (context, state, child) {
                      if (state.isLoading && state.petList.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                      }

                      if (state.petList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets_rounded, size: 80, color: AppTheme.textSecondary.withValues(alpha: 0.2)),
                              const SizedBox(height: 24),
                              Text("No pets yet", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                              const SizedBox(height: 8),
                              Text("Add your first pet to get started", style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: 200,
                                child: GradientButton(
                                  label: "Add Pet",
                                  onPressed: () => AddPetBottomSheet.show(context, _petProvider),
                                ),
                              ),
                              const SizedBox(height: 60), // offset for visual balance
                            ],
                          ),
                        );
                      }

                      final filteredPets = state.petList.where((pet) {
                        final q = _searchQuery.toLowerCase();
                        return pet.name.toLowerCase().contains(q) || pet.breed.toLowerCase().contains(q);
                      }).toList();

                      if (filteredPets.isEmpty && _searchQuery.isNotEmpty) {
                        return Center(
                          child: Text("No pets match your search", style: GoogleFonts.nunito(fontSize: 14, color: AppTheme.textSecondary)),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(20.0), // increased padding
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.68, // adjusted for aesthetic card look natively
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredPets.length + 1,
                        itemBuilder: (context, index) {
                          if (index == filteredPets.length) {
                            return GestureDetector(
                              onTap: () => AddPetBottomSheet.show(context, _petProvider),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: AppTheme.cardRadius,
                                  border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.15), width: 1.5),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add_rounded, size: 36, color: AppTheme.primary),
                                    ),
                                    const SizedBox(height: 16),
                                    Text("Add Pet", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                                  ],
                                ),
                              ),
                            );
                          }
                          return PetCard(
                            pet: filteredPets[index],
                            onTap: () {
                              context.push('/pet-detail', extra: filteredPets[index]);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 80,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiScannerScreen()),
                  );
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.document_scanner_rounded, color: AppTheme.background, size: 24),
                      const SizedBox(height: 2),
                      Text("SCAN", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.background, letterSpacing: 1.0)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
