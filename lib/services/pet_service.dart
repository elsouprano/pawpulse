// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/result.dart';
import '../models/pet_model.dart';
import 'package:uuid/uuid.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Result<void, PetException>> addPet(PetModel pet) async {
    try {
      final docRef = _firestore.collection(FirebaseConstants.petsCollection).doc(pet.id);
      await docRef.set(pet.toFirestore());
      return const Success(null);
    } catch (e) {
      return Failure(PetException('Failed to add pet: $e'));
    }
  }

  Stream<List<PetModel>> getPetsByOwner(String ownerId) {
    return _firestore
        .collection(FirebaseConstants.petsCollection)
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList());
  }

  Future<Result<PetModel, PetException>> getPetById(String petId) async {
    try {
      final doc = await _firestore.collection(FirebaseConstants.petsCollection).doc(petId).get();
      if (doc.exists) {
        return Success(PetModel.fromFirestore(doc));
      }
      return Failure(PetException('Pet not found'));
    } catch (e) {
      return Failure(PetException('Failed to fetch pet: $e'));
    }
  }

  Future<Result<void, PetException>> updatePet(PetModel pet) async {
    try {
      await _firestore
          .collection(FirebaseConstants.petsCollection)
          .doc(pet.id)
          .update(pet.toFirestore());
      return const Success(null);
    } catch (e) {
      return Failure(PetException('Failed to update pet: $e'));
    }
  }

  Future<Result<void, PetException>> deletePet(String petId) async {
    try {
      await _firestore.collection(FirebaseConstants.petsCollection).doc(petId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(PetException('Failed to delete pet: $e'));
    }
  }

  Future<Result<void, PetException>> updateHealthStatus(String petId, String status) async {
    try {
      await _firestore
          .collection(FirebaseConstants.petsCollection)
          .doc(petId)
          .update({'healthStatus': status});
      return const Success(null);
    } catch (e) {
      return Failure(PetException('Failed to update health status: $e'));
    }
  }
}
