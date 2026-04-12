// ─────────────────────────────────────────────────────────
// PawPulse — Test UI
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/scanner_provider.dart';
import '../services/scanner_service.dart';

class TestScannerScreen extends StatefulWidget {
  const TestScannerScreen({Key? key}) : super(key: key);

  @override
  State<TestScannerScreen> createState() => _TestScannerScreenState();
}

class _TestScannerScreenState extends State<TestScannerScreen> {
  late final ScannerProvider _provider;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _provider = ScannerProvider(ScannerService());
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Scanner')),
      body: ValueListenableBuilder<ScannerState>(
        valueListenable: _provider,
        builder: (context, state, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.isScanning) const Center(child: CircularProgressIndicator()),
                if (state.error != null) Text(state.error!, style: const TextStyle(color: Colors.red)),
                
                if (_imageFile != null)
                  const Text('Image selected ready for scan.')
                else
                  const Text('No image selected.'),

                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                ElevatedButton(
                  onPressed: _imageFile != null && !state.isScanning
                      ? () => _provider.startScan('test_uid', 'test_pet_id', _imageFile!)
                      : null,
                  child: const Text('Run Scan'),
                ),
                const Divider(),
                if (state.scanResult != null) ...[
                  const Text('Scan Result:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Breed Detected: ${state.scanResult!.breedDetected}'),
                  Text('Confidence: ${state.scanResult!.confidence}'),
                  Text('Health Flags: ${state.scanResult!.healthFlags.join(", ")}'),
                  Text('Recommended Actions: ${state.scanResult!.recommendedActions.join(", ")}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _provider.saveScan(),
                    child: const Text('Save Scan Result'),
                  ),
                ] else if (!state.isScanning) ...[
                  const Text('No scan results yet.'),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
