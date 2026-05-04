import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/pet_model.dart';
import '../../services/admin_pet_service.dart';
import '../../core/utils/result.dart';
import 'admin_pet_detail_bottom_sheet.dart';

class AdminPetCard extends StatelessWidget {
  final PetModel pet;
  final AdminPetService adminPetService;

  const AdminPetCard({
    super.key,
    required this.pet,
    required this.adminPetService,
  });

  String _getSpeciesEmoji(String species) {
    switch (species.toLowerCase()) {
      case 'dog': return '🐶';
      case 'cat': return '🐱';
      case 'bird': return '🐦';
      case 'rabbit': return '🐰';
      case 'fish': return '🐟';
      case 'reptile': return '🦎';
      default: return '🐾';
    }
  }

  LinearGradient _getSpeciesGradient(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return LinearGradient(
          colors: [AppTheme.primary.withValues(alpha: 0.8), AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'cat':
        return LinearGradient(
          colors: [AppTheme.secondary.withValues(alpha: 0.8), AppTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'bird':
        return LinearGradient(
          colors: [AppTheme.accent.withValues(alpha: 0.8), AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [AppTheme.primary.withValues(alpha: 0.5), AppTheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AdminPetDetailBottomSheet.show(context, pet, adminPetService);
      },
      child: Container(
        decoration: BoxDecoration(
          color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: _getSpeciesGradient(pet.species),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  _getSpeciesEmoji(pet.species),
                  style: TextStyle(fontSize: 44),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.breed,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "${pet.age} yrs",
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      _HealthStatusChip(status: pet.healthStatus),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder(
                    future: adminPetService.getOwnerByUid(pet.ownerId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Row(
                          children: [
                            Icon(Icons.person_outline, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                            ),
                          ],
                        );
                      }

                      String ownerName = "Unknown";
                      final data = snapshot.data;
                      if (data case Success(value: final owner)) {
                        ownerName = owner.name;
                      }

                      return Row(
                        children: [
                          Icon(Icons.person_outline, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ownerName,
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthStatusChip extends StatelessWidget {
  final String status;
  const _HealthStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'healthy':
        color = AppTheme.accent;
        break;
      case 'needs attention':
        color = AppTheme.secondary;
        break;
      case 'critical':
        color = AppTheme.error;
        break;
      default:
        color = Theme.of(context).colorScheme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
