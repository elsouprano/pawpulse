import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pet_model.dart';
import '../../theme/app_theme.dart';

class PetCard extends StatelessWidget {
  final PetModel pet;
  final VoidCallback onTap;
  final String? localImagePath;

  const PetCard({
    super.key,
    required this.pet,
    required this.onTap,
    this.localImagePath,
  });

  @override
  Widget build(BuildContext context) {
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pet photo stored locally on device only (Spark plan — no cloud storage).
            // To enable cloud sync, upgrade Firebase to Blaze and use firebase_storage upload in pet_service.dart.
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: ((localImagePath ?? pet.localImagePath) != null && File(localImagePath ?? pet.localImagePath!).existsSync())
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.file(
                        File(localImagePath ?? pet.localImagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 120,
                      ),
                    )
                  : Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.breed,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "${pet.age} yrs",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      _HealthChip(status: pet.healthStatus),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _HealthChip extends StatelessWidget {
  final String status;

  const _HealthChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('healthy') || lowerStatus.contains('optimal')) {
      bgColor = const Color(0xFF00D4AA).withOpacity(0.15);
      textColor = const Color(0xFF00D4AA);
    } else if (lowerStatus.contains('attention') || lowerStatus.contains('issue')) {
      bgColor = const Color(0xFFFFB347).withOpacity(0.15);
      textColor = const Color(0xFFFFB347);
    } else if (lowerStatus.contains('critical') || lowerStatus.contains('bad')) {
      bgColor = const Color(0xFFFF6B6B).withOpacity(0.15);
      textColor = const Color(0xFFFF6B6B);
    } else {
      bgColor = AppTheme.textSecondary.withOpacity(0.15);
      textColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
