// ─────────────────────────────────────────────────────────
// PawPulse — Test UI
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import '../services/pet_service.dart';

class TestPetsScreen extends StatefulWidget {
  const TestPetsScreen({Key? key}) : super(key: key);

  @override
  State<TestPetsScreen> createState() => _TestPetsScreenState();
}

class _TestPetsScreenState extends State<TestPetsScreen> {
  final _nameCtrl = TextEditingController();
  final _speciesCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  final _healthStatusCtrl = TextEditingController();

  late final PetProvider _petProvider;

  @override
  void initState() {
    super.initState();
    _petProvider = PetProvider(PetService());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _speciesCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _conditionsCtrl.dispose();
    _allergiesCtrl.dispose();
    _medicationsCtrl.dispose();
    _healthStatusCtrl.dispose();
    _petProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Pets')),
      body: ValueListenableBuilder<PetState>(
        valueListenable: _petProvider,
        builder: (context, state, child) {
          return Column(
            children: [
              if (state.isLoading) const CircularProgressIndicator(),
              if (state.error != null) Text(state.error!, style: const TextStyle(color: Colors.red)),
              Text('Selected Pet ID: ${state.selectedPet?.id ?? "None"}'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                      TextField(controller: _speciesCtrl, decoration: const InputDecoration(labelText: 'Species')),
                      TextField(controller: _breedCtrl, decoration: const InputDecoration(labelText: 'Breed')),
                      TextField(controller: _ageCtrl, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
                      TextField(controller: _weightCtrl, decoration: const InputDecoration(labelText: 'Weight'), keyboardType: TextInputType.number),
                      TextField(controller: _conditionsCtrl, decoration: const InputDecoration(labelText: 'Conditions (comma separated)')),
                      TextField(controller: _allergiesCtrl, decoration: const InputDecoration(labelText: 'Allergies (comma separated)')),
                      TextField(controller: _medicationsCtrl, decoration: const InputDecoration(labelText: 'Medications (comma separated)')),
                      TextField(controller: _healthStatusCtrl, decoration: const InputDecoration(labelText: 'Health Status (for updating)')),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final pet = PetModel(
                            id: const Uuid().v4(),
                            ownerId: 'test_owner_id', // Replace with auth user ID in production
                            name: _nameCtrl.text,
                            species: _speciesCtrl.text,
                            breed: _breedCtrl.text,
                            age: int.tryParse(_ageCtrl.text) ?? 0,
                            weight: double.tryParse(_weightCtrl.text) ?? 0.0,
                            conditions: _conditionsCtrl.text.split(',').map((e) => e.trim()).toList(),
                            allergies: _allergiesCtrl.text.split(',').map((e) => e.trim()).toList(),
                            medications: _medicationsCtrl.text.split(',').map((e) => e.trim()).toList(),
                            healthStatus: _healthStatusCtrl.text.isEmpty ? 'Healthy' : _healthStatusCtrl.text,
                          );
                          _petProvider.addPet(pet);
                        },
                        child: const Text('Add Pet'),
                      ),
                      ElevatedButton(
                        onPressed: () => _petProvider.loadPets('test_owner_id'),
                        child: const Text('Load My Pets'),
                      ),
                      ElevatedButton(
                        onPressed: state.selectedPet != null ? () => _petProvider.deletePet(state.selectedPet!.id) : null,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
                        child: const Text('Delete Selected Pet', style: TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton(
                        onPressed: state.selectedPet != null ? () {
                          final updated = PetModel(
                            id: state.selectedPet!.id,
                            ownerId: state.selectedPet!.ownerId,
                            name: state.selectedPet!.name,
                            species: state.selectedPet!.species,
                            breed: state.selectedPet!.breed,
                            age: state.selectedPet!.age,
                            weight: state.selectedPet!.weight,
                            conditions: state.selectedPet!.conditions,
                            allergies: state.selectedPet!.allergies,
                            medications: state.selectedPet!.medications,
                            healthStatus: _healthStatusCtrl.text.isEmpty ? 'Updated Health Status' : _healthStatusCtrl.text,
                            createdAt: state.selectedPet!.createdAt,
                          );
                          _petProvider.updatePet(updated);
                        } : null,
                        child: const Text('Update Health Status'),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              const Text('Pet List:'),
              Expanded(
                child: ListView.builder(
                  itemCount: state.petList.length,
                  itemBuilder: (context, index) {
                    final pet = state.petList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(pet.name.isNotEmpty ? pet.name[0].toUpperCase() : '?'),
                        ),
                        title: Text('${pet.name} (${pet.breed})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${pet.species} • Age: ${pet.age} • ${pet.weight}kg\nHealth: ${pet.healthStatus}'),
                        isThreeLine: true,
                        onTap: () => _petProvider.selectPet(pet),
                        selected: state.selectedPet?.id == pet.id,
                        selectedTileColor: Colors.blue.withOpacity(0.1),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
