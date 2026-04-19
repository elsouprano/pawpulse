import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
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
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _photos = List<String>.from(widget.pet.photos);
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
      await FirebaseFirestore.instance.collection('pets').doc(widget.pet.id).update({
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

  Widget _HealthStatusIcon(String status) {
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
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 28),
    );
  }

  Widget _InfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
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

  Widget _SectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title, 
        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)
      ),
    );
  }

  Widget _BaselineRow(String label, String value) {
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

  Widget _Divider() {
    return Divider(height: 16, color: AppTheme.textSecondary.withOpacity(0.1), thickness: 1);
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('attention') || s.contains('issue')) return AppTheme.secondary;
    if (s.contains('critical') || s.contains('bad')) return AppTheme.error;
    return AppTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    
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
                  color: AppTheme.background.withOpacity(0.5),
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
                    color: AppTheme.background.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded, color: AppTheme.textPrimary, size: 20),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit pet functionality coming soon', style: GoogleFonts.nunito(fontWeight: FontWeight.bold))),
                  );
                },
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
                            color: AppTheme.background.withOpacity(0.2),
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
                          colors: [AppTheme.background, AppTheme.background.withOpacity(0.0)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pet.name, style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Text("${pet.breed} · ${pet.age} yrs", style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary.withOpacity(0.8))),
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
                      border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
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
                        _HealthStatusIcon(pet.healthStatus),
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
                      _InfoCard("Species", pet.species, Icons.category_rounded),
                      _InfoCard("Breed", pet.breed, Icons.pets_rounded),
                      _InfoCard("Age", "${pet.age} years", Icons.cake_rounded),
                      _InfoCard("Weight", "${pet.weight} kg", Icons.monitor_weight_rounded),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Health Baseline Section
                  _SectionHeader("Health Baseline"),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                      border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
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
                            color: AppTheme.primary.withOpacity(0.3),
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
                              color: AppTheme.background.withOpacity(0.2),
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
                      _SectionHeader("Photo Gallery"),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
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
