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
      gradientColors = const [AppTheme.primary, AppTheme.secondary];
      emoji = "🐕";
    } else if (pet.species.contains('Cat')) {
      gradientColors = const [AppTheme.accent, Color(0xFF02A676)];
      emoji = "🐈";
    } else if (pet.species.contains('Bird')) {
      gradientColors = const [AppTheme.secondary, Color(0xFFFFB347)];
      emoji = "🐦";
    } else if (pet.species.contains('Rabbit')) {
      gradientColors = const [AppTheme.error, Color(0xFFFF9494)];
      emoji = "🐇";
    } else {
      gradientColors = [AppTheme.textSecondary, AppTheme.textSecondary.withOpacity(0.7)];
      emoji = "🐾";
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: AppTheme.cardRadius,
          border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pet photo stored locally on device only (Spark plan — no cloud storage).
            Container(
              height: 120, // Taller image for better aesthetic
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: ((localImagePath ?? pet.localImagePath) != null && File(localImagePath ?? pet.localImagePath!).existsSync())
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.file(
                        File(localImagePath ?? pet.localImagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 120,
                      ),
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.background.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
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
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.breed,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cake_rounded, size: 12, color: AppTheme.textSecondary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  "${pet.age} yrs",
                                  style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: _HealthChip(status: pet.healthStatus),
                      ),
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
    IconData icon;

    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('healthy') || lowerStatus.contains('optimal')) {
      bgColor = AppTheme.success.withOpacity(0.15);
      textColor = AppTheme.success;
      icon = Icons.favorite_rounded;
    } else if (lowerStatus.contains('attention') || lowerStatus.contains('issue')) {
      bgColor = AppTheme.secondary.withOpacity(0.15);
      textColor = AppTheme.secondary;
      icon = Icons.warning_rounded;
    } else if (lowerStatus.contains('critical') || lowerStatus.contains('bad')) {
      bgColor = AppTheme.error.withOpacity(0.15);
      textColor = AppTheme.error;
      icon = Icons.emergency_rounded;
    } else {
      bgColor = AppTheme.textSecondary.withOpacity(0.15);
      textColor = AppTheme.textSecondary;
      icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              status.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
