// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/result.dart';
import '../models/health_record_model.dart';
import 'package:uuid/uuid.dart';

class HealthRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Result<void, HealthRecordException>> addHealthRecord(HealthRecordModel record) async {
    try {
      final docRef = _firestore.collection(FirebaseConstants.healthRecordsCollection).doc(record.id);
      await docRef.set(record.toFirestore());
      return const Success(null);
    } catch (e) {
      return Failure(HealthRecordException('Failed to add health record: $e'));
    }
  }

  Stream<List<HealthRecordModel>> getHealthRecordsByPet(String petId) {
    return _firestore
        .collection(FirebaseConstants.healthRecordsCollection)
        .where('petId', isEqualTo: petId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => HealthRecordModel.fromFirestore(doc)).toList());
  }

  Stream<List<HealthRecordModel>> getHealthRecordsByType(String petId, String type) {
    return _firestore
        .collection(FirebaseConstants.healthRecordsCollection)
        .where('petId', isEqualTo: petId)
        .where('type', isEqualTo: type)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => HealthRecordModel.fromFirestore(doc)).toList());
  }

  Future<Result<void, HealthRecordException>> deleteHealthRecord(String recordId) async {
    try {
      await _firestore.collection(FirebaseConstants.healthRecordsCollection).doc(recordId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(HealthRecordException('Failed to delete health record: $e'));
    }
  }

  Future<Result<String, HealthRecordException>> uploadHealthAttachment(String petId, File file) async {
    try {
      final ref = _storage.ref().child('health_records/$petId/${const Uuid().v4()}');
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      return Success(downloadUrl);
    } catch (e) {
      return Failure(HealthRecordException('Failed to upload attachment: $e'));
    }
  }
}
