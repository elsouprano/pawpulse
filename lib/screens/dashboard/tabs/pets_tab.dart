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

  @override
  void initState() {
    super.initState();
    _petProvider = PetProvider(PetService());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        _petProvider.loadPets(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _petProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddPetBottomSheet.show(context, _petProvider),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Text("My Pets", style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppTheme.primary),
                        onPressed: () => AddPetBottomSheet.show(context, _petProvider),
                      ),
                    ],
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
                              Icon(Icons.pets, size: 72, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                              const SizedBox(height: 16),
                              Text("No pets yet", style: GoogleFonts.spaceGrotesk(fontSize: 20, color: Colors.white)),
                              const SizedBox(height: 8),
                              Text("Add your first pet to get started", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: 200,
                                child: GradientButton(
                                  label: "Add Pet",
                                  onPressed: () => AddPetBottomSheet.show(context, _petProvider),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: state.petList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.petList.length) {
                            return GestureDetector(
                              onTap: () => AddPetBottomSheet.show(context, _petProvider),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_circle_outline, size: 40, color: AppTheme.primary),
                                    const SizedBox(height: 12),
                                    Text("Add Pet", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.primary)),
                                  ],
                                ),
                              ),
                            );
                          }
                          return PetCard(
                            pet: state.petList[index],
                            onTap: () {
                              context.push('/pet-detail', extra: state.petList[index]);
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 20),
                      Text("AI", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
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
