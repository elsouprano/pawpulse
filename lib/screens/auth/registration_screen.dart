import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/error_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../services/auth_service.dart';
import '../../services/pet_service.dart';
import '../../services/user_service.dart';
import '../../models/pet_model.dart';
import '../../models/user_model.dart';
import '../../core/utils/validators.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _currentStep = 0;
  
  final _formKey0 = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  
  // Step 1: Account
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(); // new field
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;

  // Step 2: Pet Profile
  final _petNameCtrl = TextEditingController();
  String? _speciesValue;
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  // Step 3: Health Baseline
  final _conditionsCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();

  late final AuthProvider _authProvider;
  late final PetProvider _petProvider;
  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(AuthService());
    _petProvider = PetProvider(PetService());
    _userService = UserService();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _petNameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _conditionsCtrl.dispose();
    _allergiesCtrl.dispose();
    _medicationsCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    FormState? form;
    switch (_currentStep) {
      case 0: form = _formKey0.currentState; break;
      case 1: form = _formKey1.currentState; break;
      case 2: form = _formKey2.currentState; break;
      case 3: form = _formKey3.currentState; break;
    }
    
    if (form?.validate() ?? false) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      }
    }
  }

  Future<void> _submitRegistration() async {
    FocusManager.instance.primaryFocus?.unfocus();

    // 1. Register User Object via AuthProvider
    await _authProvider.register(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (_authProvider.value.error != null) return;
    
    final user = _authProvider.value.currentUser;
    if (user != null) {
      // 1.5 Create UserObject
      final newUser = UserModel(
        uid: user.uid,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      await _userService.createUserProfile(newUser);
      
      if (user.displayName == null || user.displayName! != _nameCtrl.text.trim()) {
        await user.updateDisplayName(_nameCtrl.text.trim());
      }

      // 2. Add Pet Object via PetProvider
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
        healthStatus: 'Baseline Set',
        createdAt: DateTime.now(),
      );

      await _petProvider.addPet(newPet);
      if (_petProvider.value.error == null && mounted) {
        context.go('/dashboard');
      }
    }
  }

  InputDecoration _buildInputDecoration(String hint, {IconData? prefixIcon, Widget? suffixIcon, String? helperText, String? suffixText}) {
    return InputDecoration(
      hintText: hint,
      helperText: helperText,
      helperStyle: GoogleFonts.nunito(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 12),
      hintStyle: GoogleFonts.nunito(color: AppTheme.textSecondary.withOpacity(0.5)),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textSecondary) : null,
      suffixIcon: suffixIcon,
      suffixText: suffixText,
      suffixStyle: GoogleFonts.nunito(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: const Color(0xFF1A1200).withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF8C42), width: 1.5),
      ),
      errorMaxLines: 3,
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: const Color(0xFF1A1200)),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [const Color(0xFFFF8C42).withOpacity(0.08), Colors.transparent],
              center: Alignment.center,
              radius: 1.5,
            ),
          ),
        ),
        Positioned(top: -50, left: -100, child: _Circle(size: 300, color: const Color(0xFFFF8C42).withOpacity(0.06))),
        Positioned(bottom: -50, right: -100, child: _Circle(size: 350, color: const Color(0xFFFF8C42).withOpacity(0.06))),
        Positioned(top: 200, right: -50, child: _Circle(size: 200, color: const Color(0xFFFF8C42).withOpacity(0.06))),
        Positioned(bottom: 150, left: -50, child: _Circle(size: 150, color: const Color(0xFFFFD166).withOpacity(0.04))),
        Positioned(top: 100, left: 150, child: _Circle(size: 100, color: const Color(0xFFFFD166).withOpacity(0.04))),
      ],
    );
  }

  Widget _buildFloatingCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFF8C42).withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C42).withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(28),
            color: const Color(0xFF3D2C00).withOpacity(0.92),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                        onPressed: () {
                          if (_currentStep > 0) {
                            setState(() => _currentStep--);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const Spacer(),
                      Text(
                        "PawPulse",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF8C42),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: _buildStepIndicator(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildFloatingCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStepHeader(),
                          const SizedBox(height: 24),
                          [
                            _buildStep1(),
                            _buildStep2(),
                            _buildStep3(),
                            _buildStep4(),
                          ][_currentStep],
                          const SizedBox(height: 24),
                          ValueListenableBuilder(
                            valueListenable: _authProvider,
                            builder: (context, authState, _) {
                              return ValueListenableBuilder(
                                valueListenable: _petProvider,
                                builder: (context, petState, _) {
                                  bool isLoading = authState.isLoading || petState.isLoading;
                                  return Row(
                                    children: [
                                      if (_currentStep > 0)
                                        Expanded(
                                          flex: 1,
                                          child: OutlinedButton(
                                            onPressed: isLoading ? null : () => setState(() => _currentStep--),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 18.0),
                                              side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            ),
                                            child: Text("Back", style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      if (_currentStep > 0) const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: GradientButton(
                                          label: _currentStep < 3 ? "Next" : "Create Account",
                                          isLoading: isLoading,
                                          onPressed: _currentStep == 3 ? _submitRegistration : _nextStep,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(7, (index) {
        if (index % 2 == 0) {
          int stepIndex = index ~/ 2;
          bool isDone = stepIndex < _currentStep;
          bool isActive = stepIndex == _currentStep;
          
          if (isDone) {
            return Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF06D6A0),
              ),
              child: const Center(
                child: Icon(Icons.check, color: Colors.white, size: 16),
              ),
            );
          } else if (isActive) {
            return Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFFFF8C42), Color(0xFFFFD166)]),
              ),
              child: Center(
                child: Text(
                  "${stepIndex + 1}",
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          } else {
            return Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF261D15),
              ),
              child: Center(
                child: Text(
                  "${stepIndex + 1}",
                  style: GoogleFonts.nunito(color: AppTheme.textSecondary),
                ),
              ),
            );
          }
        } else {
          int lineIndex = index ~/ 2;
          bool isPassed = lineIndex < _currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isPassed ? const Color(0xFF06D6A0) : const Color(0xFF261D15),
            ),
          );
        }
      }),
    );
  }

  Widget _buildStepHeader() {
    String title = "";
    String subtitle = "";
    switch (_currentStep) {
      case 0:
        title = "Create Account";
        subtitle = "Let's get you started";
        break;
      case 1:
        title = "Your Pet's Profile";
        subtitle = "Tell us about your furry friend";
        break;
      case 2:
        title = "Health Baseline";
        subtitle = "Help us understand your pet's health";
        break;
      case 3:
        title = "All Done!";
        subtitle = "Review your details before we begin";
        break;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameCtrl,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            decoration: _buildInputDecoration("Full Name", prefixIcon: Icons.person_outline_rounded),
            validator: Validators.validateFullName,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            decoration: _buildInputDecoration("Email Address", prefixIcon: Icons.email_outlined),
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            decoration: _buildInputDecoration("09XX XXX XXXX", prefixIcon: Icons.phone_outlined),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            onChanged: (val) {
              if (val.startsWith('63') && val.length <= 12) {
                // simple trim check handle locally if needed
              }
            },
            validator: Validators.validatePhoneNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            decoration: _buildInputDecoration("Password", prefixIcon: Icons.lock_outline_rounded, suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AppTheme.textSecondary),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )),
            onChanged: (_) => setState(() {}),
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscurePassword,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            decoration: _buildInputDecoration("Confirm Password", prefixIcon: Icons.lock_outline_rounded),
            validator: (v) => Validators.validateConfirmPassword(v, _passwordCtrl.text),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _petNameCtrl,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            decoration: _buildInputDecoration("Pet Name", prefixIcon: Icons.pets_rounded),
            validator: Validators.validatePetName,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _speciesValue,
            decoration: _buildInputDecoration("Species"),
            dropdownColor: const Color(0xFF1A1200),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            items: const [
              DropdownMenuItem(value: 'Dog 🐕', child: Text('Dog 🐕')),
              DropdownMenuItem(value: 'Cat 🐈', child: Text('Cat 🐈')),
              DropdownMenuItem(value: 'Bird 🐦', child: Text('Bird 🐦')),
              DropdownMenuItem(value: 'Rabbit 🐇', child: Text('Rabbit 🐇')),
              DropdownMenuItem(value: 'Other 🐾', child: Text('Other 🐾')),
            ],
            onChanged: (v) => setState(() => _speciesValue = v),
            validator: (v) => v == null ? 'Please select a species' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _breedCtrl,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            decoration: _buildInputDecoration("Breed"),
            validator: Validators.validateBreed,
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
                  validator: Validators.validateAge,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  decoration: _buildInputDecoration("Weight", suffixText: "kg"),
                  validator: Validators.validateWeight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _conditionsCtrl,
            maxLines: 3,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            decoration: _buildInputDecoration("Known Conditions", helperText: "e.g. diabetes, hip dysplasia"),
            validator: Validators.validateNotes,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _allergiesCtrl,
            maxLines: 3,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            decoration: _buildInputDecoration("Allergies", helperText: "e.g. pollen, certain foods"),
            validator: Validators.validateNotes,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _medicationsCtrl,
            maxLines: 3,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            decoration: _buildInputDecoration("Current Medications", helperText: "e.g. flea treatment, supplements"),
            validator: Validators.validateNotes,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Form(
      key: _formKey3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1200).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                _InfoRow(label: "Name", value: _nameCtrl.text),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppTheme.textSecondary.withOpacity(0.1))),
                _InfoRow(label: "Email", value: _emailCtrl.text),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppTheme.textSecondary.withOpacity(0.1))),
                _InfoRow(label: "Phone", value: _phoneCtrl.text),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppTheme.textSecondary.withOpacity(0.1))),
                _InfoRow(label: "Pet Name", value: _petNameCtrl.text),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppTheme.textSecondary.withOpacity(0.1))),
                _InfoRow(label: "Species", value: _speciesValue ?? "-"),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppTheme.textSecondary.withOpacity(0.1))),
                _InfoRow(label: "Breed", value: _breedCtrl.text),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppTheme.textSecondary.withOpacity(0.1))),
                _InfoRow(label: "Age", value: "${_ageCtrl.text} yrs"),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppTheme.textSecondary.withOpacity(0.1))),
                _InfoRow(label: "Weight", value: "${_weightCtrl.text} kg"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: _authProvider,
            builder: (context, authState, child) {
              return ValueListenableBuilder(
                valueListenable: _petProvider,
                builder: (context, petState, child) {
                  if (authState.error != null) return ErrorCard(message: authState.error!);
                  if (petState.error != null) return ErrorCard(message: petState.error!);
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.nunito(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(value, style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;

  const _Circle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
