import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/pet_model.dart';
import '../../theme/app_theme.dart';
import '../scanner/ai_scanner_screen.dart';
import '../../providers/pet_provider.dart';
import '../../services/pet_service.dart';
import '../../services/scanner_service.dart';

class PetDetailScreen extends StatefulWidget {
  final PetModel pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  late List<String> _photos;
  late PetModel _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
    _photos = List<String>.from(_pet.photos);
  }

  Future<void> _pickAndSavePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final fileName = "${const Uuid().v4()}.png";
    final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');

    setState(() {
      _photos.add(savedImage.path);
    });

    try {
      await FirebaseFirestore.instance.collection('pets').doc(_pet.id).update({
        'photos': FieldValue.arrayUnion([savedImage.path])
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _photos.removeLast();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save photo: $e')));
    }
  }

  void _openPhotoViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenViewer(
          photos: _photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: GoogleFonts.nunito(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunito(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  void _showEditBottomSheet() {
    final nameCtrl = TextEditingController(text: _pet.name);
    final speciesCtrl = TextEditingController(text: _pet.species);
    final breedCtrl = TextEditingController(text: _pet.breed);
    final ageCtrl = TextEditingController(text: _pet.age.toString());
    final weightCtrl = TextEditingController(text: _pet.weight.toString());
    final conditionsCtrl = TextEditingController(text: _pet.conditions.join(', '));
    final allergiesCtrl = TextEditingController(text: _pet.allergies.join(', '));
    final medicationsCtrl = TextEditingController(text: _pet.medications.join(', '));

    String? newImagePath = _pet.localImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(color: AppTheme.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Edit Pet", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      IconButton(icon: const Icon(Icons.close, color: AppTheme.textSecondary), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(source: ImageSource.gallery);
                                if (picked != null) {
                                  final directory = await getApplicationDocumentsDirectory();
                                  final fileName = "${const Uuid().v4()}.png";
                                  final savedImage = await File(picked.path).copy('${directory.path}/$fileName');
                                  setModalState(() {
                                    newImagePath = savedImage.path;
                                  });
                                }
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.primary, width: 2),
                                  image: newImagePath != null && File(newImagePath!).existsSync()
                                      ? DecorationImage(image: FileImage(File(newImagePath!)), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: newImagePath == null || !File(newImagePath!).existsSync()
                                    ? const Center(child: Icon(Icons.camera_alt_rounded, color: AppTheme.primary, size: 32))
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(child: Text("Tap to change photo", style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textSecondary))),
                          const SizedBox(height: 24),
                          
                          _buildTextField(nameCtrl, "Name", Icons.pets),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(speciesCtrl, "Species", Icons.category)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField(breedCtrl, "Breed", Icons.pets_outlined)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(ageCtrl, "Age (years)", Icons.cake, isNumber: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField(weightCtrl, "Weight (kg)", Icons.monitor_weight, isNumber: true)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(conditionsCtrl, "Conditions (comma-separated)", Icons.healing),
                          const SizedBox(height: 16),
                          _buildTextField(allergiesCtrl, "Allergies (comma-separated)", Icons.warning_amber),
                          const SizedBox(height: 16),
                          _buildTextField(medicationsCtrl, "Medications (comma-separated)", Icons.medication),
                          const SizedBox(height: 32),
                          
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () async {
                              final updatedPet = PetModel(
                                id: _pet.id,
                                ownerId: _pet.ownerId,
                                name: nameCtrl.text.trim(),
                                species: speciesCtrl.text.trim(),
                                breed: breedCtrl.text.trim(),
                                age: int.tryParse(ageCtrl.text.trim()) ?? _pet.age,
                                weight: double.tryParse(weightCtrl.text.trim()) ?? _pet.weight,
                                conditions: conditionsCtrl.text.isEmpty ? [] : conditionsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                                allergies: allergiesCtrl.text.isEmpty ? [] : allergiesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                                medications: medicationsCtrl.text.isEmpty ? [] : medicationsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                                healthStatus: _pet.healthStatus,
                                createdAt: _pet.createdAt,
                                localImagePath: newImagePath,
                                photos: _pet.photos,
                              );

                              Navigator.pop(ctx);

                              final petProvider = PetProvider(PetService());
                              await petProvider.updatePet(updatedPet);
                              petProvider.dispose();

                              if (mounted) {
                                setState(() {
                                  _pet = updatedPet;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Pet details updated', style: GoogleFonts.nunito(fontWeight: FontWeight.bold))),
                                );
                              }
                            },
                            child: Text("Save Changes", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _healthStatusIcon(String status) {
    Color color;
    IconData iconData;

    final s = status.toLowerCase();
    if (s.contains('attention') || s.contains('issue')) {
      color = AppTheme.secondary;
      iconData = Icons.warning_amber_rounded;
    } else if (s.contains('critical') || s.contains('bad')) {
      color = AppTheme.error;
      iconData = Icons.report_problem_rounded;
    } else {
      color = AppTheme.success;
      iconData = Icons.health_and_safety_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 28),
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.1)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
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

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title, 
        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)
      ),
    );
  }

  Widget _baselineRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 16, color: AppTheme.textSecondary.withValues(alpha: 0.1), thickness: 1);
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('attention') || s.contains('issue')) return AppTheme.secondary;
    if (s.contains('critical') || s.contains('bad')) return AppTheme.error;
    return AppTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    final pet = _pet;
    
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
      gradientColors = [AppTheme.textSecondary, AppTheme.textSecondary.withValues(alpha: 0.7)];
      emoji = "🐾";
    }

    final hasLocalImage = pet.localImagePath != null && File(pet.localImagePath!).existsSync();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.surface,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.background.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.background.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded, color: AppTheme.textPrimary, size: 20),
                ),
                onPressed: _showEditBottomSheet,
              ),
              const SizedBox(width: 8),
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
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.background.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 80)),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppTheme.background, AppTheme.background.withValues(alpha: 0.0)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${pet.breed} · ${pet.age} yrs",
                          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary.withValues(alpha: 0.8)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Health Status Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                      border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Overall Health", style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                            const SizedBox(height: 4),
                            Text(pet.healthStatus, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: _getStatusColor(pet.healthStatus))),
                          ],
                        ),
                        const Spacer(),
                        _healthStatusIcon(pet.healthStatus),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Grid
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.0,
                    children: [
                      _infoCard("Species", pet.species, Icons.category_rounded),
                      _infoCard("Breed", pet.breed, Icons.pets_rounded),
                      _infoCard("Age", "${pet.age} years", Icons.cake_rounded),
                      _infoCard("Weight", "${pet.weight} kg", Icons.monitor_weight_rounded),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Health Baseline Section
                  _sectionHeader("Health Baseline"),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                      border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _baselineRow("Conditions", pet.conditions.isEmpty ? "None reported" : pet.conditions.join(", ")),
                        _divider(),
                        _baselineRow("Allergies", pet.allergies.isEmpty ? "None reported" : pet.allergies.join(", ")),
                        _divider(),
                        _baselineRow("Medications", pet.medications.isEmpty ? "None" : pet.medications.join(", ")),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.accent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.background.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.document_scanner_rounded, color: AppTheme.surface, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Run AI Health Scan", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.background)),
                                const SizedBox(height: 4),
                                Text("Scan ${pet.name}'s photo for insights", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.surface)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.background, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Photo Gallery Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionHeader("Photo Gallery"),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_rounded, color: AppTheme.primary, size: 24),
                        ),
                        onPressed: _pickAndSavePhoto,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_photos.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: Text("No photos yet.", style: GoogleFonts.nunito(color: AppTheme.textSecondary)),
                      ),
                    )
                  else
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _photos.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _openPhotoViewer(index),
                          child: Hero(
                            tag: 'photo_${_photos[index]}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_photos[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 32),

                  // ── Scan History Section ──
                  _sectionHeader('Scan History'),
                  const SizedBox(height: 16),
                  StreamBuilder(
                    stream: ScannerService().getScanHistory(pet.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                      }
                      final scans = snapshot.data ?? [];
                      if (scans.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.08)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.document_scanner_outlined, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              Text('No scans yet', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                              const SizedBox(height: 6),
                              Text('Run an AI scan to detect breed & health flags', style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textSecondary)),
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AiScannerScreen(overridePetId: pet.id)),
                                ),
                                icon: const Icon(Icons.document_scanner_outlined, size: 18),
                                label: Text('Run an AI Scan', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: scans.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final scan = scans[i];
                          final pct = (scan.confidence * 100).toStringAsFixed(0);
                          final date = scan.scannedAt != null
                              ? '${scan.scannedAt!.day}/${scan.scannedAt!.month}/${scan.scannedAt!.year}'
                              : 'Unknown date';
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.08)),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.document_scanner_outlined, size: 16, color: AppTheme.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(scan.breedDetected, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                                    ),
                                    Text(date, style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textSecondary)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text('Confidence: $pct%', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                                    const Spacer(),
                                    Text('$pct%', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: scan.confidence,
                                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                    valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                                    minHeight: 6,
                                  ),
                                ),
                                if (scan.healthFlags.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text('Health Flags', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                                  const SizedBox(height: 6),
                                  ...scan.healthFlags.map((f) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.secondary),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text(f, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
                                      ],
                                    ),
                                  )),
                                ],
                                if (scan.recommendedActions.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text('Recommended Actions', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                                  const SizedBox(height: 6),
                                  ...scan.recommendedActions.mapIndexed((idx, a) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 18, height: 18,
                                          decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                                          child: Center(child: Text('${idx+1}', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primary))),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text(a, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
                                      ],
                                    ),
                                  )),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenViewer extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  
  const FullScreenViewer({super.key, required this.photos, required this.initialIndex});

  @override
  State<FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Hero(
                    tag: 'photo_${widget.photos[index]}',
                    child: Image.file(File(widget.photos[index]), fit: BoxFit.contain),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                padding: const EdgeInsets.all(16),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
