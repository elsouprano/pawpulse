// ─────────────────────────────────────────────────────────
// PawPulse — Test UI
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'test_auth_screen.dart';
import 'test_pets_screen.dart';
import 'test_appointments_screen.dart';
import 'test_health_records_screen.dart';
import 'test_scanner_screen.dart';

class TestRunnerScreen extends StatelessWidget {
  const TestRunnerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PawPulse — Function Test Runner ⚠️ Dev Only'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TestAuthScreen())),
              child: const Text('Test Auth'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TestPetsScreen())),
              child: const Text('Test Pets'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TestAppointmentsScreen())),
              child: const Text('Test Appointments'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TestHealthRecordsScreen())),
              child: const Text('Test Health Records'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TestScannerScreen())),
              child: const Text('Test Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
