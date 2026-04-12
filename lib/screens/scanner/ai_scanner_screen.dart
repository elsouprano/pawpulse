import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';
import '../../models/scan_result_model.dart';
import '../../providers/scanner_provider.dart';
import '../../providers/pet_provider.dart';
import '../../services/scanner_service.dart';
import '../../services/pet_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/gradient_button.dart';

class AiScannerScreen extends StatefulWidget {
  final String? overridePetId;
  
  const AiScannerScreen({super.key, this.overridePetId});

  @override
  State<AiScannerScreen> createState() => _AiScannerScreenState();
}

class _AiScannerScreenState extends State<AiScannerScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnimation;
  late final ScannerProvider _scannerProvider;
  late final PetProvider _petProvider;

  bool _isScanning = false;
  bool _showResults = false;
  File? _selectedImage;
  ScanResultModel? _scanResult;
  String? _resolvedPetId;

  @override
  void initState() {
    super.initState();
    _scannerProvider = ScannerProvider(ScannerService());
    _petProvider = PetProvider(PetService());
    
    // Resolve petId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _petProvider.loadPets(user.uid);
      }
    });
    
    _petProvider.addListener(() {
      if (_resolvedPetId == null && _petProvider.value.petList.isNotEmpty) {
        setState(() {
          _resolvedPetId = widget.overridePetId ?? _petProvider.value.petList.first.id;
        });
      }
    });

    _scanLineController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    ));
    _scanLineController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _scannerProvider.dispose();
    _petProvider.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _showResults = false;
        _scanResult = null;
      });
    }
  }

  Future<void> _startScan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedImage == null) return;
    
    final targetPetId = widget.overridePetId ?? _resolvedPetId ?? 'demo-pet-id';

    setState(() => _isScanning = true);
    
    // Attempt scan through the actual service
    await _scannerProvider.startScan(user.uid, targetPetId, _selectedImage!);
    
    // Simulate extra AI processing time simply for demo
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      if (_scannerProvider.value.error != null) {
        setState(() {
          _isScanning = false;
          _showResults = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_scannerProvider.value.error!)),
        );
      } else {
        setState(() {
          _isScanning = false;
          _showResults = true;
          _scanResult = _scannerProvider.value.scanResult;
        });
      }
    }
  }

  Future<void> _saveResult() async {
    await _scannerProvider.saveScan();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scan result saved to pet profile!")),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildHealthFlagTile(String flag, int index) {
    // Generate severity based on pseudo-random string length just for UI simulation purposes
    String severity = "Low";
    Color iconColor = const Color(0xFF00D4AA); // Teal

    if (flag.length > 25) {
      severity = "High";
      iconColor = const Color(0xFFFF6B6B); // Red
    } else if (flag.length > 15) {
      severity = "Medium";
      iconColor = const Color(0xFFFFB347); // Amber
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.warning_amber_outlined, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  flag,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                ),
              ),
              _SeverityChip(severity: severity),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "AI Pet Scanner",
          style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── How It Works Banner ──
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF6C63FF), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "How AI Scanning Works",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Upload a clear photo of your pet's face. Our AI will detect the breed, flag potential health concerns based on visual cues, and suggest recommended actions. Results are simulated for demo purposes.",
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Viewfinder ──
            if (!_showResults)
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Dark viewfinder background
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(_selectedImage!, fit: BoxFit.cover, width: 280, height: 280),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.pets, size: 64, color: const Color(0xFF94A3B8).withOpacity(0.3)),
                                    const SizedBox(height: 12),
                                    Text("No image selected", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8))),
                                  ],
                                ),
                              ),
                      ),

                      // Corner bracket decorations
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CustomPaint(painter: _CornerBracketPainter(color: const Color(0xFF6C63FF))),
                      ),

                      // Animated scan line
                      if (_isScanning)
                        AnimatedBuilder(
                          animation: _scanLineAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: _scanLineAnimation.value * 260 + 10,
                              child: Container(
                                width: 260,
                                height: 2,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF6C63FF),
                                      Color(0xFF00D4AA),
                                      Color(0xFF6C63FF),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      // Scanning label overlay
                      if (_isScanning)
                        Positioned(
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00D4AA)),
                                ),
                                const SizedBox(width: 8),
                                Text("Analyzing...", style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // ── Results Panel ──
            if (_showResults && _scanResult != null)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      key: const ValueKey('results'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF00D4AA), size: 22),
                            const SizedBox(width: 8),
                            Text("Analysis Complete", style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Breed Detection Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Breed Detection", style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(_scanResult!.breedDetected, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const Spacer(),
                                  Text("${(_scanResult!.confidence * 100).toStringAsFixed(0)}%", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF00D4AA))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _scanResult!.confidence,
                                  backgroundColor: AppTheme.textSecondary.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation(Color(0xFF00D4AA)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Health Flags Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Health Flags", style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                              const SizedBox(height: 8),
                              ..._scanResult!.healthFlags.mapIndexed((i, flag) => _buildHealthFlagTile(flag, i)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Recommended Actions Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Recommended Actions", style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                              const SizedBox(height: 8),
                              ..._scanResult!.recommendedActions.mapIndexed((index, action) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text("${index + 1}", style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(action, style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Action Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _showResults = false;
                                    _selectedImage = null;
                                    _scanResult = null;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text("Scan Again", style: GoogleFonts.inter(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GradientButton(
                                label: "Save to Profile",
                                onPressed: _saveResult,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Bottom Buttons (only when not showing results) ──
            if (!_showResults)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GradientButton(
                      label: _isScanning ? "Scanning..." : "Scan Pet",
                      isLoading: _isScanning,
                      onPressed: _selectedImage != null && !_isScanning ? _startScan : null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _pickImage,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text("Upload Photo from Gallery", style: GoogleFonts.inter(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "For best results, use a clear front-facing photo of your pet",
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
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

class _SeverityChip extends StatelessWidget {
  final String severity;
  
  const _SeverityChip({required this.severity});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (severity == "High") {
      bgColor = const Color(0xFFFF6B6B).withOpacity(0.15);
      textColor = const Color(0xFFFF6B6B);
    } else if (severity == "Medium") {
      bgColor = const Color(0xFFFFB347).withOpacity(0.15);
      textColor = const Color(0xFFFFB347);
    } else {
      bgColor = const Color(0xFF00D4AA).withOpacity(0.15);
      textColor = const Color(0xFF00D4AA);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        severity,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;

  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double length = 24.0;

    // Top Left
    canvas.drawLine(const Offset(0, 0), const Offset(length, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, length), paint);

    // Top Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - length, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);

    // Bottom Left
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - length), paint);

    // Bottom Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - length, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
