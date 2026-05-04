import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/result.dart';
import '../core/errors/app_exceptions.dart';

class ClinicalNotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Result<void, AppException>> addClinicalNotes({
    required String healthRecordId,
    required String clinicalNotes,
    required String prescribedMedications,
    required String recommendedActions,
    required String adminUid,
    required String adminName,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'clinicalNotes': clinicalNotes,
        'addedByAdminUid': adminUid,
        'addedByAdminName': adminName,
        'clinicalNotesAddedAt': FieldValue.serverTimestamp(),
      };
      
      if (prescribedMedications.isNotEmpty) {
        updateData['prescribedMedications'] = prescribedMedications;
      }
      if (recommendedActions.isNotEmpty) {
        updateData['recommendedActions'] = recommendedActions;
      }

      await _firestore.collection('health_records').doc(healthRecordId).update(updateData);
      return const Success(null);
    } catch (e) {
      return Failure(HealthRecordException('Failed to add clinical notes: $e'));
    }
  }

  Future<Result<void, AppException>> updateClinicalNotes({
    required String healthRecordId,
    required String clinicalNotes,
    required String prescribedMedications,
    required String recommendedActions,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'clinicalNotes': clinicalNotes,
      };
      
      // Update or nullify
      updateData['prescribedMedications'] = prescribedMedications.isNotEmpty ? prescribedMedications : null;
      updateData['recommendedActions'] = recommendedActions.isNotEmpty ? recommendedActions : null;

      await _firestore.collection('health_records').doc(healthRecordId).update(updateData);
      return const Success(null);
    } catch (e) {
      return Failure(HealthRecordException('Failed to update clinical notes: $e'));
    }
  }

  Future<Result<void, AppException>> removeClinicalNotes(String healthRecordId) async {
    try {
      await _firestore.collection('health_records').doc(healthRecordId).update({
        'clinicalNotes': null,
        'prescribedMedications': null,
        'recommendedActions': null,
        'addedByAdminUid': null,
        'addedByAdminName': null,
        'clinicalNotesAddedAt': null,
      });
      return const Success(null);
    } catch (e) {
      return Failure(HealthRecordException('Failed to remove clinical notes: $e'));
    }
  }
}
