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
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Result<void, AppException>> createUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(user.toFirestore());
      return const Success(null);
    } catch (e) {
      return Failure(GeneralException('Failed to create user profile: $e'));
    }
  }

  Future<Result<UserModel, AppException>> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(FirebaseConstants.usersCollection).doc(uid).get();
      if (doc.exists) {
        return Success(UserModel.fromFirestore(doc));
      }
      return Failure(GeneralException('User not found'));
    } catch (e) {
      return Failure(GeneralException('Failed to fetch user profile: $e'));
    }
  }

  Future<Result<void, AppException>> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update(user.toFirestore());
      return const Success(null);
    } catch (e) {
      return Failure(GeneralException('Failed to update user profile: $e'));
    }
  }

  Future<Result<String, AppException>> uploadProfilePhoto(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child('profiles/$uid/${const Uuid().v4()}.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return Success(downloadUrl);
    } catch (e) {
      return Failure(GeneralException('Failed to upload profile photo: $e'));
    }
  }
}
