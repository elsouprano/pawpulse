import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_theme.dart';
import '../common/gradient_button.dart';
import '../common/error_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPetBottomSheet extends StatefulWidget {
  final PetProvider petProvider;

  const AddPetBottomSheet({super.key, required this.petProvider});

  static void show(BuildContext context, PetProvider petProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => AddPetBottomSheet(petProvider: petProvider),
    );
  }

  @override
  State<AddPetBottomSheet> createState() => _AddPetBottomSheetState();
}

class _AddPetBottomSheetState extends State<AddPetBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _petNameCtrl = TextEditingController();
  String? _speciesValue;
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  final _conditionsCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  
  String? _localImagePath;

  @override
  void dispose() {
    _petNameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _conditionsCtrl.dispose();
    _allergiesCtrl.dispose();
    _medicationsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null && mounted) {
      setState(() {
        _localImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newPet = PetModel(
      id: const Uuid().v4(),
      ownerId: user.uid,
      name: _petNameCtrl.text.trim(),
      species: _speciesValue ?? 'Other 🐾',
      breed: _breedCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text) ?? 0,
      weight: double.tryParse(_weightCtrl.text) ?? 0.0,
      conditions: _conditionsCtrl.text.isNotEmpty ? _conditionsCtrl.text.split(',').map((e) => e.trim()).toList() : [],
      allergies: _allergiesCtrl.text.isNotEmpty ? _allergiesCtrl.text.split(',').map((e) => e.trim()).toList() : [],
      medications: _medicationsCtrl.text.isNotEmpty ? _medicationsCtrl.text.split(',').map((e) => e.trim()).toList() : [],
      healthStatus: 'Healthy',
      createdAt: DateTime.now(),
      localImagePath: _localImagePath,
    );

    await widget.petProvider.addPet(newPet);

    if (widget.petProvider.value.error == null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pet added successfully!', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, {IconData? prefixIcon, String? helperText, String? suffixText}) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      helperStyle: GoogleFonts.nunito(color: AppTheme.textSecondary, fontSize: 12),
      labelStyle: GoogleFonts.nunito(color: AppTheme.textSecondary),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textSecondary) : null,
      suffixText: suffixText,
      suffixStyle: GoogleFonts.nunito(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: AppTheme.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  children: [
                    Text(
                      "Add New Pet",
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40), // More organic squircle feel
                                    gradient: _localImagePath == null
                                        ? const LinearGradient(
                                            colors: [AppTheme.primary, AppTheme.secondary],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withOpacity(0.2),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: _localImagePath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(40),
                                          child: Image.file(
                                            File(_localImagePath!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.add_a_photo_rounded, color: AppTheme.background, size: 36),
                                            const SizedBox(height: 8),
                                            Text("Add Photo", style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.background)),
                                          ],
                                        ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Tap to select a pet photo (stored locally)", 
                                  style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _petNameCtrl,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            decoration: _buildInputDecoration("Pet Name", prefixIcon: Icons.pets_rounded),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _speciesValue,
                            decoration: _buildInputDecoration("Species"),
                            dropdownColor: AppTheme.card,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            items: const [
                              DropdownMenuItem(value: 'Dog 🐕', child: Text('Dog 🐕')),
                              DropdownMenuItem(value: 'Cat 🐈', child: Text('Cat 🐈')),
                              DropdownMenuItem(value: 'Bird 🐦', child: Text('Bird 🐦')),
                              DropdownMenuItem(value: 'Rabbit 🐇', child: Text('Rabbit 🐇')),
                              DropdownMenuItem(value: 'Other 🐾', child: Text('Other 🐾')),
                            ],
                            onChanged: (v) => setState(() => _speciesValue = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _breedCtrl,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            decoration: _buildInputDecoration("Breed", prefixIcon: Icons.category_rounded),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _ageCtrl,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                  decoration: _buildInputDecoration("Age", suffixText: "yrs"),
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _weightCtrl,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                  decoration: _buildInputDecoration("Weight", suffixText: "kg"),
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Health Baseline",
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _conditionsCtrl,
                            maxLines: 2,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            decoration: _buildInputDecoration("Known Conditions", helperText: "e.g. diabetes, hip dysplasia"),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _allergiesCtrl,
                            maxLines: 2,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            decoration: _buildInputDecoration("Allergies", helperText: "e.g. pollen, certain foods"),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _medicationsCtrl,
                            maxLines: 2,
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            decoration: _buildInputDecoration("Current Medications", helperText: "e.g. flea treatment, supplements"),
                          ),
                          const SizedBox(height: 32),
                          ValueListenableBuilder(
                            valueListenable: widget.petProvider,
                            builder: (context, state, child) {
                              return Column(
                                children: [
                                  GradientButton(
                                    label: "Save Pet",
                                    isLoading: state.isLoading,
                                    onPressed: _handleSave,
                                  ),
                                  if (state.error != null) ...[
                                    const SizedBox(height: 12),
                                    ErrorCard(message: state.error!),
                                  ]
                                ],
                              );
                            },
                          ),
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
                        ],
                      ),
                    ),
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
