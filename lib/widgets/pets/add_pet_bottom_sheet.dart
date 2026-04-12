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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
        const SnackBar(content: Text('Pet added successfully!')),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, {IconData? prefixIcon, String? helperText, String? suffixText}) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      helperStyle: const TextStyle(color: AppTheme.textSecondary),
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textSecondary) : null,
      suffixText: suffixText,
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFF94A3B8).withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFF94A3B8).withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      "Add New Pet",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image stored at local file path only. Path saved to Firestore as a local device path.
                          // This means pet photos are device-specific and will not sync across devices.
                          // Upgrade to Firebase Storage (Blaze plan) to enable cross-device photo sync.
                          GestureDetector(
                            onTap: _pickImage,
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: _localImagePath == null
                                        ? const LinearGradient(
                                            colors: [AppTheme.primary, Color(0xFF8B5CF6)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                  ),
                                  child: _localImagePath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.file(
                                            File(_localImagePath!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 28),
                                            const SizedBox(height: 6),
                                            Text("Add Photo", style: GoogleFonts.inter(fontSize: 11, color: Colors.white)),
                                          ],
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Text("Tap to add pet photo", style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _petNameCtrl,
                            decoration: _buildInputDecoration("Pet Name", prefixIcon: Icons.pets),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _speciesValue,
                            decoration: _buildInputDecoration("Species"),
                            dropdownColor: AppTheme.background,
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
                            decoration: _buildInputDecoration("Breed"),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _ageCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration("Age", suffixText: "yrs"),
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _weightCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration("Weight", suffixText: "kg"),
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Health Baseline",
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _conditionsCtrl,
                            maxLines: 3,
                            decoration: _buildInputDecoration("Known Conditions", helperText: "e.g. diabetes, hip dysplasia"),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _allergiesCtrl,
                            maxLines: 3,
                            decoration: _buildInputDecoration("Allergies", helperText: "e.g. pollen, certain foods"),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _medicationsCtrl,
                            maxLines: 3,
                            decoration: _buildInputDecoration("Current Medications", helperText: "e.g. flea treatment, supplements"),
                          ),
                          const SizedBox(height: 24),
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
                                    const SizedBox(height: 16),
                                    ErrorCard(message: state.error!),
                                  ]
                                ],
                              );
                            },
                          ),
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
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
