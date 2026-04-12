// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ScanResultModel extends Equatable {
  final String id;
  final String petId;
  final String breedDetected;
  final double confidence;
  final List<String> healthFlags;
  final List<String> recommendedActions;
  final DateTime? scannedAt;

  const ScanResultModel({
    required this.id,
    required this.petId,
    required this.breedDetected,
    required this.confidence,
    required this.healthFlags,
    required this.recommendedActions,
    required this.scannedAt,
  });

  factory ScanResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ScanResultModel(
      id: doc.id,
      petId: data['petId'] ?? '',
      breedDetected: data['breedDetected'] ?? '',
      confidence: (data['confidence'] ?? 0).toDouble(),
      healthFlags: List<String>.from(data['healthFlags'] ?? []),
      recommendedActions: List<String>.from(data['recommendedActions'] ?? []),
      scannedAt: (data['scannedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'breedDetected': breedDetected,
      'confidence': confidence,
      'healthFlags': healthFlags,
      'recommendedActions': recommendedActions,
      'scannedAt': scannedAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(scannedAt!),
    };
  }

  @override
  List<Object?> get props => [
        id,
        petId,
        breedDetected,
        confidence,
        healthFlags,
        recommendedActions,
        scannedAt,
      ];
}
