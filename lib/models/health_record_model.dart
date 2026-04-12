// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class HealthRecordModel extends Equatable {
  final String id;
  final String petId;
  final String type;
  final DateTime? date;
  final String vetName;
  final String notes;
  final String? attachmentUrl;

  const HealthRecordModel({
    required this.id,
    required this.petId,
    required this.type,
    required this.date,
    required this.vetName,
    required this.notes,
    this.attachmentUrl,
  });

  factory HealthRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HealthRecordModel(
      id: doc.id,
      petId: data['petId'] ?? '',
      type: data['type'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
      vetName: data['vetName'] ?? '',
      notes: data['notes'] ?? '',
      attachmentUrl: data['attachmentUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'type': type,
      'date': date == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(date!),
      'vetName': vetName,
      'notes': notes,
      'attachmentUrl': attachmentUrl,
    };
  }

  @override
  List<Object?> get props => [id, petId, type, date, vetName, notes, attachmentUrl];
}
