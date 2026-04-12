// ─────────────────────────────────────────────────────────
// PawPulse — Test UI
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/health_record_model.dart';
import '../providers/health_record_provider.dart';
import '../services/health_record_service.dart';

class TestHealthRecordsScreen extends StatefulWidget {
  const TestHealthRecordsScreen({Key? key}) : super(key: key);

  @override
  State<TestHealthRecordsScreen> createState() => _TestHealthRecordsScreenState();
}

class _TestHealthRecordsScreenState extends State<TestHealthRecordsScreen> {
  final _typeCtrl = TextEditingController();
  final _vetNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late final HealthRecordProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = HealthRecordProvider(HealthRecordService());
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _vetNameCtrl.dispose();
    _notesCtrl.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Health Records')),
      body: ValueListenableBuilder<HealthRecordState>(
        valueListenable: _provider,
        builder: (context, state, child) {
          return Column(
            children: [
              if (state.isLoading) const CircularProgressIndicator(),
              if (state.error != null) Text(state.error!, style: const TextStyle(color: Colors.red)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(controller: _typeCtrl, decoration: const InputDecoration(labelText: 'Type')),
                      TextField(controller: _vetNameCtrl, decoration: const InputDecoration(labelText: 'Vet Name')),
                      TextField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Notes')),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final record = HealthRecordModel(
                            id: const Uuid().v4(),
                            petId: 'test_pet_id',
                            type: _typeCtrl.text.isEmpty ? 'General' : _typeCtrl.text,
                            date: DateTime.now(),
                            vetName: _vetNameCtrl.text,
                            notes: _notesCtrl.text,
                          );
                          _provider.addRecord(record);
                        },
                        child: const Text('Add Record'),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () => _provider.loadRecords('test_pet_id'),
                            child: const Text('Load All'),
                          ),
                          ElevatedButton(
                            onPressed: () => _provider.setFilter('Vaccination'),
                            child: const Text('Filter Vaccinations'),
                          ),
                          ElevatedButton(
                            onPressed: () => _provider.setFilter('Check-up'),
                            child: const Text('Filter Check-ups'),
                          ),
                          ElevatedButton(
                            onPressed: () => _provider.setFilter('Medication'),
                            child: const Text('Filter Medications'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Text('Records (${state.activeFilter}):'),
              Expanded(
                child: ListView.builder(
                  itemCount: state.records.length,
                  itemBuilder: (context, index) {
                    final record = state.records[index];
                    return ListTile(
                      title: Text(record.toString()),
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
