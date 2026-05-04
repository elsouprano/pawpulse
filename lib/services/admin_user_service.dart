import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/result.dart';
import '../models/user_model.dart';
import '../models/pet_model.dart';

class AdminUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Result<List<UserModel>, AppException>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      final users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      return Success(users);
    } catch (e) {
      return Failure(GeneralException('Failed to fetch users: $e'));
    }
  }

  Stream<List<UserModel>> watchAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Future<Result<void, AppException>> promoteToAdmin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': 'admin'});
      return Success(null);
    } catch (e) {
      return Failure(GeneralException('Failed to promote user: $e'));
    }
  }

  Future<Result<void, AppException>> demoteToUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': 'user'});
      return Success(null);
    } catch (e) {
      return Failure(GeneralException('Failed to demote user: $e'));
    }
  }

  Future<Result<void, AppException>> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      return Success(null);
    } catch (e) {
      return Failure(GeneralException('Failed to delete user: $e'));
    }
  }

  Future<Result<List<PetModel>, AppException>> getPetsByUser(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: uid)
          .get();

      final pets = snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();
      return Success(pets);
    } catch (e) {
      return Failure(GeneralException('Failed to fetch user pets: $e'));
    }
  }

  Future<Result<UserModel, AppException>> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return Failure(GeneralException('User not found.'));
      }
      return Success(UserModel.fromFirestore(doc));
    } catch (e) {
      return Failure(GeneralException('Failed to fetch user: $e'));
    }
  }
}
