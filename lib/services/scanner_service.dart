// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/config/env.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/result.dart';
import '../models/scan_result_model.dart';
import 'package:uuid/uuid.dart';

class ScannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Left here if needed for later

  Future<Result<ScanResultModel, ScannerException>> analyzePetImage(
    String uid,
    String petId,
    File imageFile,
  ) async {
    try {
      if (AppEnv.geminiApiKey == 'YOUR_API_KEY_HERE') {
        throw Exception(
          'Please put your actual Gemini API Key in lib/core/config/env.dart',
        );
      }

      // Initialize the Gemini Multimodal Model
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: AppEnv.geminiApiKey,
      );

      final imageBytes = await imageFile.readAsBytes();
      final mimeType = _getMimeType(imageFile.path);

      // System Instructions requesting STRICT JSON output
      final prompt = TextPart('''
        Analyze this image of a pet. 
        You must respond with ONLY a valid, parseable JSON object matching this exact structure (no markdown formatting, no backticks, no other text):
        {
          "breedDetected": "String (e.g. Golden Retriever)",
          "confidence": 0.95,
          "healthFlags": ["List of strings of any observable health or condition flags"],
          "recommendedActions": ["List of strings for recommended actions based on the scan"]
        }
      ''');

      final imagePart = DataPart(mimeType, imageBytes);

      // Execute Vision Request
      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini AI');
      }

      // Safely clean up potential markdown formatting in Gemini's response
      String jsonText = response.text!.trim();
      if (jsonText.startsWith('```json'))
        jsonText = jsonText.substring(7);
      else if (jsonText.startsWith('```'))
        jsonText = jsonText.substring(3);
      if (jsonText.endsWith('```'))
        jsonText = jsonText.substring(0, jsonText.length - 3);

      final data = jsonDecode(jsonText.trim()) as Map<String, dynamic>;

      final scanResult = ScanResultModel(
        id: const Uuid().v4(),
        petId: petId,
        breedDetected: data['breedDetected'] ?? 'Unknown Breed',
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
        healthFlags: List<String>.from(data['healthFlags'] ?? []),
        recommendedActions: List<String>.from(data['recommendedActions'] ?? []),
        scannedAt: DateTime.now(),
      );

      return Success(scanResult);
    } catch (e) {
      return Failure(ScannerException('Failed to analyze pet image: $e'));
    }
  }

  String _getMimeType(String path) {
    if (path.toLowerCase().endsWith('.png')) return 'image/png';
    if (path.toLowerCase().endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<Result<void, ScannerException>> saveScanResult(
    ScanResultModel result,
  ) async {
    try {
      final docRef = _firestore
          .collection(FirebaseConstants.scanResultsCollection)
          .doc(result.id);
      await docRef.set(result.toFirestore());
      return const Success(null);
    } catch (e) {
      return Failure(ScannerException('Failed to save scan result: $e'));
    }
  }

  Stream<List<ScanResultModel>> getScanHistory(String petId) {
    return _firestore
        .collection(FirebaseConstants.scanResultsCollection)
        .where('petId', isEqualTo: petId)
        .orderBy('scannedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ScanResultModel.fromFirestore(doc))
              .toList(),
        );
  }
}
