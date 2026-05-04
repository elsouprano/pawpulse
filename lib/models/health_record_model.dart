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
  final String? clinicalNotes;
  final String? prescribedMedications;
  final String? recommendedActions;
  final String? addedByAdminUid;
  final String? addedByAdminName;
  final DateTime? clinicalNotesAddedAt;
  final DateTime? nextVaccinationDate;

  const HealthRecordModel({
    required this.id,
    required this.petId,
    required this.type,
    required this.date,
    required this.vetName,
    required this.notes,
    this.attachmentUrl,
    this.clinicalNotes,
    this.prescribedMedications,
    this.recommendedActions,
    this.addedByAdminUid,
    this.addedByAdminName,
    this.clinicalNotesAddedAt,
    this.nextVaccinationDate,
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
      clinicalNotes: data['clinicalNotes'],
      prescribedMedications: data['prescribedMedications'],
      recommendedActions: data['recommendedActions'],
      addedByAdminUid: data['addedByAdminUid'],
      addedByAdminName: data['addedByAdminName'],
      clinicalNotesAddedAt: (data['clinicalNotesAddedAt'] as Timestamp?)?.toDate(),
      nextVaccinationDate: (data['nextVaccinationDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'petId': petId,
      'type': type,
      'date': date == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(date!),
      'vetName': vetName,
      'notes': notes,
      'attachmentUrl': attachmentUrl,
    };
    if (clinicalNotes != null) map['clinicalNotes'] = clinicalNotes;
    if (prescribedMedications != null) map['prescribedMedications'] = prescribedMedications;
    if (recommendedActions != null) map['recommendedActions'] = recommendedActions;
    if (addedByAdminUid != null) map['addedByAdminUid'] = addedByAdminUid;
    if (addedByAdminName != null) map['addedByAdminName'] = addedByAdminName;
    if (clinicalNotesAddedAt != null) map['clinicalNotesAddedAt'] = Timestamp.fromDate(clinicalNotesAddedAt!);
    if (nextVaccinationDate != null) map['nextVaccinationDate'] = Timestamp.fromDate(nextVaccinationDate!);
    return map;
  }

  @override
  List<Object?> get props => [
        id,
        petId,
        type,
        date,
        vetName,
        notes,
        attachmentUrl,
        clinicalNotes,
        prescribedMedications,
        recommendedActions,
        addedByAdminUid,
        addedByAdminName,
        clinicalNotesAddedAt,
        nextVaccinationDate,
      ];
}
