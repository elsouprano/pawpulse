import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pet_model.dart';
import '../../theme/app_theme.dart';
import '../scanner/ai_scanner_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final PetModel pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  Widget _HealthStatusIcon(String status) {
    Color color;
    IconData iconData;

    final s = status.toLowerCase();
    if (s.contains('attention') || s.contains('issue')) {
      color = const Color(0xFFFFB347);
      iconData = Icons.warning_amber_outlined;
    } else if (s.contains('critical') || s.contains('bad')) {
      color = const Color(0xFFFF6B6B);
      iconData = Icons.report_problem_outlined;
    } else {
      color = const Color(0xFF00D4AA); // Healthy
      iconData = Icons.check_circle_outline;
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withOpacity(0.15),
      child: Icon(iconData, color: color),
    );
  }

  Widget _InfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _SectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _BaselineRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _Divider() {
    return Divider(height: 24, color: Colors.white.withOpacity(0.05), thickness: 1);
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('attention') || s.contains('issue')) return const Color(0xFFFFB347);
    if (s.contains('critical') || s.contains('bad')) return const Color(0xFFFF6B6B);
    return const Color(0xFF00D4AA);
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    
    // Determine gradient for fallback avatar
    List<Color> gradientColors;
    String emoji;
    if (pet.species.contains('Dog')) {
      gradientColors = const [Color(0xFF6C63FF), Color(0xFF8B5CF6)];
      emoji = "🐕";
    } else if (pet.species.contains('Cat')) {
      gradientColors = const [Color(0xFF00D4AA), Color(0xFF0891B2)];
      emoji = "🐈";
    } else if (pet.species.contains('Bird')) {
      gradientColors = const [Color(0xFFFFB347), Color(0xFFFF6B6B)];
      emoji = "🐦";
    } else if (pet.species.contains('Rabbit')) {
      gradientColors = const [Color(0xFFFF6B6B), Color(0xFFEC4899)];
      emoji = "🐇";
    } else {
      gradientColors = const [Color(0xFF94A3B8), Color(0xFF64748B)];
      emoji = "🐾";
    }

    final hasLocalImage = pet.localImagePath != null && File(pet.localImagePath!).existsSync();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A2E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit pet functionality coming soon')),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasLocalImage)
                    Image.file(File(pet.localImagePath!), fit: BoxFit.cover)
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        ),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 80)),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF0F0F1A), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pet.name, style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("${pet.breed} · ${pet.age} yrs", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Health Status Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Health Status", style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                            const SizedBox(height: 4),
                            Text(pet.healthStatus, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: _getStatusColor(pet.healthStatus))),
                          ],
                        ),
                        const Spacer(),
                        _HealthStatusIcon(pet.healthStatus),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info Grid
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.2,
                    children: [
                      _InfoCard("Species", pet.species, Icons.category_outlined),
                      _InfoCard("Breed", pet.breed, Icons.pets),
                      _InfoCard("Age", "${pet.age} years", Icons.cake_outlined),
                      _InfoCard("Weight", "${pet.weight} kg", Icons.monitor_weight_outlined),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Health Baseline Section
                  _SectionHeader("Health Baseline"),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _BaselineRow("Conditions", pet.conditions.isEmpty ? "None reported" : pet.conditions.join(", ")),
                        _Divider(),
                        _BaselineRow("Allergies", pet.allergies.isEmpty ? "None reported" : pet.allergies.join(", ")),
                        _Divider(),
                        _BaselineRow("Medications", pet.medications.isEmpty ? "None" : pet.medications.join(", ")),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // AI Scanner shortcut
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AiScannerScreen(overridePetId: pet.id),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Run AI Health Scan", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text("Scan ${pet.name}'s photo for health insights", style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
