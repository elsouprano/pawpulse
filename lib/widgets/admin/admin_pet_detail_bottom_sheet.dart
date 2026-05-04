import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/pet_model.dart';
import '../../services/admin_pet_service.dart';
import '../../core/utils/result.dart';

class AdminPetDetailBottomSheet extends StatelessWidget {
  final PetModel pet;
  final AdminPetService adminPetService;

  const AdminPetDetailBottomSheet({
    super.key,
    required this.pet,
    required this.adminPetService,
  });

  static void show(BuildContext context, PetModel pet, AdminPetService adminPetService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminPetDetailBottomSheet(
        pet: pet,
        adminPetService: adminPetService,
      ),
    );
  }

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

  IconData _getRecordTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination': return Icons.vaccines_outlined;
      case 'checkup': return Icons.monitor_heart_outlined;
      case 'surgery': return Icons.medical_services_outlined;
      case 'medication': return Icons.medication_outlined;
      default: return Icons.health_and_safety_outlined;
    }
  }

  Color _getRecordTypeColor(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'vaccination': return AppTheme.primary;
      case 'checkup': return AppTheme.accent;
      case 'surgery': return AppTheme.error;
      case 'medication': return AppTheme.secondary;
      default: return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Pet header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: _getSpeciesGradient(pet.species),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _getSpeciesEmoji(pet.species),
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                "${pet.breed} · ${pet.species}",
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _HealthStatusChip(status: pet.healthStatus),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface)),
                    const SizedBox(height: 16),

                    // Pet info grid 2x2
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _InfoTile(label: "Age", value: "${pet.age} years", icon: Icons.cake_outlined),
                        _InfoTile(label: "Weight", value: "${pet.weight} kg", icon: Icons.monitor_weight_outlined),
                        _InfoTile(
                            label: "Conditions",
                            value: pet.conditions.isEmpty ? "None" : pet.conditions.join(', '),
                            icon: Icons.medical_information_outlined),
                        _InfoTile(
                            label: "Allergies",
                            value: pet.allergies.isEmpty ? "None" : pet.allergies.join(', '),
                            icon: Icons.warning_amber_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Owner info
                    Text(
                      "Owner",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder(
                      future: adminPetService.getOwnerByUid(pet.ownerId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(color: AppTheme.primary));
                        }
                        
                        final data = snapshot.data;
                        if (data case Success(value: final owner)) {
                          String initials = "?";
                          if (owner.name.isNotEmpty) {
                            final parts = owner.name.split(' ').where((p) => p.isNotEmpty).toList();
                            if (parts.length > 1) {
                              initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
                            } else {
                              initials = parts[0][0].toUpperCase();
                            }
                          }

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                                  child: Text(
                                    initials,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        owner.name,
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        owner.email,
                                        style: GoogleFonts.nunito(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return Text("Owner not found", style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.onSurfaceVariant));
                      },
                    ),
                    SizedBox(height: 16),

                    // Health Records
                    Text(
                      "Health Records",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder(
                      future: adminPetService.getHealthRecordsByPet(pet.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(color: AppTheme.primary));
                        }
                        
                        final data = snapshot.data;
                        if (data case Success(value: final records)) {
                          if (records.isEmpty) {
                            return Text(
                              "No health records",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            );
                          }
                          
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final record = records[index];
                              final typeColor = _getRecordTypeColor(context, record.type);
                              String formattedDate = "Unknown Date";
                              if (record.date != null) {
                                formattedDate = DateFormat("MMM d, yyyy").format(record.date!);
                              }
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: typeColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _getRecordTypeIcon(record.type),
                                        size: 18,
                                        color: typeColor,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.type,
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            record.vetName,
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        
                        return Text("Failed to load records", style: GoogleFonts.nunito(color: AppTheme.error));
                      },
                    ),
                    SizedBox(height: 16),

                    // Update Health Status
                    Text(
                      "Update Health Status",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ["Healthy", "Needs Attention", "Critical"].map((status) {
                        bool isActive = pet.healthStatus.toLowerCase() == status.toLowerCase();
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
                            color = AppTheme.primary;
                        }
                        
                        return OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isActive ? color : Colors.transparent,
                            side: BorderSide(color: color),
                            foregroundColor: isActive ? Colors.white : color,
                          ),
                          onPressed: () async {
                            final result = await adminPetService.updatePetHealthStatus(pet.id, status);
                            if (!context.mounted) return;
                            if (result is Success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Health status updated")),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Failed to update status")),
                              );
                            }
                          },
                          child: Text(status),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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
}
