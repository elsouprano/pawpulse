import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';
import '../models/health_record_model.dart';
import '../models/user_model.dart';
import '../core/utils/result.dart';
import '../core/errors/app_exceptions.dart';

class AdminPetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PetModel>> watchAllPets() {
    return _firestore
        .collection('pets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PetModel.fromFirestore(doc))
            .toList());
  }

  Future<Result<List<HealthRecordModel>, AppException>> getHealthRecordsByPet(String petId) async {
    try {
      final snapshot = await _firestore
          .collection('health_records')
          .where('petId', isEqualTo: petId)
          .get();
      final records = snapshot.docs
          .map((doc) => HealthRecordModel.fromFirestore(doc))
          .toList();
      
      records.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });
      return Success(records);
    } catch (e) {
      return Failure(GeneralException('Failed to fetch health records: $e'));
    }
  }

  Future<Result<UserModel, AppException>> getOwnerByUid(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return Success(UserModel.fromFirestore(doc));
      } else {
        return Failure(GeneralException('Owner not found'));
      }
    } catch (e) {
      return Failure(GeneralException('Failed to fetch owner: $e'));
    }
  }

  Future<Result<PetModel, AppException>> getPetById(String petId) async {
    try {
      final doc = await _firestore.collection('pets').doc(petId).get();
      if (doc.exists && doc.data() != null) {
        return Success(PetModel.fromFirestore(doc));
      } else {
        return Failure(GeneralException('Pet not found'));
      }
    } catch (e) {
      return Failure(GeneralException('Failed to fetch pet: $e'));
    }
  }

  Future<Result<void, AppException>> updatePetHealthStatus(String petId, String status) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        'healthStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } catch (e) {
      return Failure(GeneralException('Failed to update pet health status: $e'));
    }
  }
}
