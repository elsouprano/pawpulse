import 'package:flutter/material.dart';
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
import '../../models/pet_model.dart';

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

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(AuthService());
    _petProvider = PetProvider(PetService());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _petNameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _conditionsCtrl.dispose();
    _allergiesCtrl.dispose();
    _medicationsCtrl.dispose();
    _authProvider.dispose();
    _petProvider.dispose();
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
    if (!(_formKey3.currentState?.validate() ?? false)) return;

    // 1. Register User Object via AuthProvider
    await _authProvider.register(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (_authProvider.value.error != null) return;
    
    final user = _authProvider.value.currentUser;
    if (user != null) {
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

  InputDecoration _buildInputDecoration(String label, {IconData? prefixIcon, Widget? suffixIcon, String? helperText, String? suffixText}) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      helperStyle: const TextStyle(color: AppTheme.textSecondary),
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textSecondary) : null,
      suffixIcon: suffixIcon,
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: _StepIndicator(currentStep: _currentStep),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ][_currentStep],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    int pwdLen = _passwordCtrl.text.length;
    String strLabel = pwdLen == 0 ? "" : (pwdLen < 6 ? "Weak" : (pwdLen < 10 ? "Medium" : "Strong"));

    return Form(
      key: _formKey0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text("Account Setup", style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameCtrl,
            decoration: _buildInputDecoration("Full Name", prefixIcon: Icons.person_outline),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration("Email", prefixIcon: Icons.email_outlined),
            validator: (v) => !v!.contains('@') ? 'Valid email required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: _buildInputDecoration("Password", prefixIcon: Icons.lock_outlined, suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: AppTheme.textSecondary),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )),
            onChanged: (_) => setState(() {}),
            validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStrengthBar(pwdLen >= 1, pwdLen)),
              const SizedBox(width: 4),
              Expanded(child: _buildStrengthBar(pwdLen >= 6, pwdLen)),
              const SizedBox(width: 4),
              Expanded(child: _buildStrengthBar(pwdLen >= 10, pwdLen)),
              const SizedBox(width: 12),
              Text(strLabel, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.right),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscurePassword,
            decoration: _buildInputDecoration("Confirm Password", prefixIcon: Icons.lock_outlined),
            validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthBar(bool isActive, int pwdLen) {
    Color c = AppTheme.textSecondary;
    if (isActive) {
      if (pwdLen < 6) c = AppTheme.error;
      else if (pwdLen < 10) c = const Color(0xFFFFB347);
      else c = AppTheme.accent;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text("Pet Profile", style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
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
            dropdownColor: AppTheme.surface,
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
          const SizedBox(height: 12),
          Text("Health Baseline", style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text("Optional but recommended for accurate scanning.", style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
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
          const SizedBox(height: 12),
          Text("Confirmation", style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _InfoRow(label: "Name", value: _nameCtrl.text),
                  const Divider(),
                  _InfoRow(label: "Email", value: _emailCtrl.text),
                  const Divider(),
                  _InfoRow(label: "Pet Name", value: _petNameCtrl.text),
                  const Divider(),
                  _InfoRow(label: "Species", value: _speciesValue ?? "-"),
                  const Divider(),
                  _InfoRow(label: "Breed", value: _breedCtrl.text),
                  const Divider(),
                  _InfoRow(label: "Age", value: "${_ageCtrl.text} yrs"),
                  const Divider(),
                  _InfoRow(label: "Weight", value: "${_weightCtrl.text} kg"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
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

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ValueListenableBuilder(
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
                         child: const Padding(
                           padding: EdgeInsets.symmetric(vertical: 16.0),
                           child: Text("Back"),
                         ),
                       ),
                     ),
                   if (_currentStep > 0) const SizedBox(width: 16),
                   Expanded(
                     flex: 2,
                     child: GradientButton(
                       label: _currentStep == 3 ? "Create Account" : "Next",
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (index) {
        if (index % 2 == 0) {
          int stepIndex = index ~/ 2;
          bool isDone = stepIndex < currentStep;
          bool isActive = stepIndex == currentStep;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? AppTheme.accent : (isActive ? AppTheme.primary : AppTheme.surface),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text("${stepIndex + 1}", style: TextStyle(color: isActive ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.bold)),
            ),
          );
        } else {
          int lineIndex = index ~/ 2;
          bool isPassed = lineIndex < currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              color: isPassed ? AppTheme.accent : AppTheme.surface,
            ),
          );
        }
      }),
    );
  }
}
