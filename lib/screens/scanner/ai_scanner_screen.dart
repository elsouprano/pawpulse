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
          SnackBar(
            content: Text(_scannerProvider.value.error!, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.error,
          ),
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
        SnackBar(
          content: Text("Scan result saved to pet profile!", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildHealthFlagTile(String flag, int index) {
    // Generate severity based on pseudo-random string length just for UI simulation purposes
    String severity = "Low";
    Color iconColor = AppTheme.success;

    if (flag.length > 25) {
      severity = "High";
      iconColor = AppTheme.error;
    } else if (flag.length > 15) {
      severity = "Medium";
      iconColor = AppTheme.secondary;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(Icons.warning_amber_rounded, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  flag,
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              _SeverityChip(severity: severity),
            ],
          ),
        ),
        if (index != _scanResult!.healthFlags.length - 1)
          Divider(height: 1, color: AppTheme.textSecondary.withOpacity(0.1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "AI Pet Scanner",
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── How It Works Banner ──
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "How AI Scanning Works",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Upload a clear photo of your pet's face. Our AI will detect the breed, flag potential health concerns based on visual cues, and suggest recommended actions. Results are simulated for demo purposes.",
                          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
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
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 6))],
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.file(_selectedImage!, fit: BoxFit.cover, width: 300, height: 300),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(color: AppTheme.background, shape: BoxShape.circle),
                                      child: const Icon(Icons.pets_rounded, size: 64, color: AppTheme.primary),
                                    ),
                                    const SizedBox(height: 16),
                                    Text("No image selected", style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                      ),

                      // Corner bracket decorations
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: CustomPaint(painter: _CornerBracketPainter(color: AppTheme.primary)),
                      ),

                      // Animated scan line
                      if (_isScanning)
                        AnimatedBuilder(
                          animation: _scanLineAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: _scanLineAnimation.value * 280 + 10,
                              child: Container(
                                width: 280,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppTheme.primary,
                                      AppTheme.accent,
                                      AppTheme.primary,
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 0))
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      // Scanning label overlay
                      if (_isScanning)
                        Positioned(
                          bottom: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.background.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary),
                                ),
                                const SizedBox(width: 10),
                                Text("Analyzing...", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
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
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      key: const ValueKey('results'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 28),
                            const SizedBox(width: 12),
                            Text("Analysis Complete", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Breed Detection Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Breed Detection", style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(_scanResult!.breedDetected, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                                  const Spacer(),
                                  Text("${(_scanResult!.confidence * 100).toStringAsFixed(0)}%", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: _scanResult!.confidence,
                                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Health Flags Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Health Flags", style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              const SizedBox(height: 12),
                              ..._scanResult!.healthFlags.mapIndexed((i, flag) => _buildHealthFlagTile(flag, i)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Recommended Actions Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Recommended Actions", style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              const SizedBox(height: 16),
                              ..._scanResult!.recommendedActions.mapIndexed((index, action) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text("${index + 1}", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(action, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

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
                                  side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                ),
                                child: Text("Discard", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                              ),
                            ),
                            const SizedBox(width: 16),
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    GradientButton(
                      label: _isScanning ? "Scanning..." : "Scan Pet",
                      isLoading: _isScanning,
                      onPressed: _selectedImage != null && !_isScanning ? _startScan : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _pickImage,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text("Pick Photo from Gallery", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "For best results, use a well-lit, front-facing photo.",
                      style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
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
      bgColor = AppTheme.error.withOpacity(0.15);
      textColor = AppTheme.error;
    } else if (severity == "Medium") {
      bgColor = AppTheme.secondary.withOpacity(0.15);
      textColor = AppTheme.secondary;
    } else {
      bgColor = AppTheme.success.withOpacity(0.15);
      textColor = AppTheme.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        severity.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
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
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double length = 32.0;

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
