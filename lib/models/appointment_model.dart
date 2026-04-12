// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AppointmentModel extends Equatable {
  final String id;
  final String petId;
  final String ownerId;
  final String vetName;
  final String type;
  final DateTime? dateTime;
  final String status;
  final String notes;

  const AppointmentModel({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.vetName,
    required this.type,
    required this.dateTime,
    required this.status,
    required this.notes,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppointmentModel(
      id: doc.id,
      petId: data['petId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      vetName: data['vetName'] ?? '',
      type: data['type'] ?? '',
      dateTime: (data['dateTime'] as Timestamp?)?.toDate(),
      status: data['status'] ?? '',
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'ownerId': ownerId,
      'vetName': vetName,
      'type': type,
      'dateTime': dateTime == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(dateTime!),
      'status': status,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [id, petId, ownerId, vetName, type, dateTime, status, notes];
}
