// ─────────────────────────────────────────────────────────
// PawPulse — Test UI
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import '../services/appointment_service.dart';

class TestAppointmentsScreen extends StatefulWidget {
  const TestAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<TestAppointmentsScreen> createState() => _TestAppointmentsScreenState();
}

class _TestAppointmentsScreenState extends State<TestAppointmentsScreen> {
  final _vetNameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _selectedDate;
  AppointmentModel? _selectedAppointment;

  late final AppointmentProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AppointmentProvider(AppointmentService());
  }

  @override
  void dispose() {
    _vetNameCtrl.dispose();
    _typeCtrl.dispose();
    _notesCtrl.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Appointments')),
      body: ValueListenableBuilder<AppointmentState>(
        valueListenable: _provider,
        builder: (context, state, child) {
          return Column(
            children: [
              if (state.isLoading) const CircularProgressIndicator(),
              if (state.error != null)
                Text(state.error!, style: const TextStyle(color: Colors.red)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _vetNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Vet Name',
                        ),
                      ),
                      TextField(
                        controller: _typeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Appointment Type',
                        ),
                      ),
                      TextField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(labelText: 'Notes'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        child: Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : _selectedDate!.toString(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (_selectedDate == null) return;
                          final appt = AppointmentModel(
                            id: const Uuid().v4(),
                            petId: 'test_pet_id',
                            ownerId: 'test_owner_id',
                            vetName: _vetNameCtrl.text,
                            type: _typeCtrl.text,
                            dateTime: _selectedDate!,
                            status: 'Scheduled',
                            notes: _notesCtrl.text,
                          );
                          _provider.bookAppointment(appt);
                        },
                        child: const Text('Book Appointment'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _provider.loadAppointments('test_owner_id'),
                        child: const Text('Load Appointments'),
                      ),
                      ElevatedButton(
                        onPressed: _selectedAppointment != null
                            ? () => _provider.cancelAppointment(
                                _selectedAppointment!.id,
                              )
                            : null,
                        child: const Text('Cancel Selected'),
                      ),
                      ElevatedButton(
                        onPressed: _selectedAppointment != null
                            ? () => _provider.updateStatus(
                                _selectedAppointment!.id,
                                'Completed',
                              )
                            : null,
                        child: const Text('Update Status to Completed'),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              const Text('Appointments List:'),
              Expanded(
                child: ListView.builder(
                  itemCount: state.appointments.length,
                  itemBuilder: (context, index) {
                    final appt = state.appointments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: appt.status == 'Completed' ? Colors.green : Colors.orange,
                          child: const Icon(Icons.calendar_month, color: Colors.white),
                        ),
                        title: Text('${appt.type} with ${appt.vetName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${appt.dateTime?.toString().substring(0, 16) ?? 'No Date'}\nStatus: ${appt.status}'
                          '${appt.notes.isNotEmpty ? ' • Notes: ${appt.notes}' : ''}',
                        ),
                        isThreeLine: true,
                        onTap: () => setState(() => _selectedAppointment = appt),
                        selected: _selectedAppointment?.id == appt.id,
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
