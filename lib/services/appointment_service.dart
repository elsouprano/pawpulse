// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/result.dart';
import '../models/appointment_model.dart';
import 'package:uuid/uuid.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Result<void, AppointmentException>> bookAppointment(AppointmentModel appointment) async {
    try {
      final docRef = _firestore.collection(FirebaseConstants.appointmentsCollection).doc(appointment.id);
      await docRef.set(appointment.toFirestore());
      return const Success(null);
    } catch (e) {
      return Failure(AppointmentException('Failed to book appointment: $e'));
    }
  }

  Stream<List<AppointmentModel>> getAppointmentsByOwner(String ownerId) {
    return _firestore
        .collection(FirebaseConstants.appointmentsCollection)
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList());
  }

  Stream<List<AppointmentModel>> getAppointmentsByPet(String petId) {
    return _firestore
        .collection(FirebaseConstants.appointmentsCollection)
        .where('petId', isEqualTo: petId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList());
  }

  Stream<List<AppointmentModel>> getUpcomingAppointments(String ownerId) {
    return _firestore
        .collection(FirebaseConstants.appointmentsCollection)
        .where('ownerId', isEqualTo: ownerId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList());
  }

  Future<Result<void, AppointmentException>> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestore
          .collection(FirebaseConstants.appointmentsCollection)
          .doc(appointmentId)
          .update({'status': status});
      return const Success(null);
    } catch (e) {
      return Failure(AppointmentException('Failed to update status: $e'));
    }
  }

  Future<Result<void, AppointmentException>> cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection(FirebaseConstants.appointmentsCollection).doc(appointmentId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(AppointmentException('Failed to cancel appointment: $e'));
    }
  }
}
