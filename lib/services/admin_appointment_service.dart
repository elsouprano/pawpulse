import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../core/utils/result.dart';
import '../core/errors/app_exceptions.dart';

class AdminAppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppointmentModel>> watchAllAppointments() {
    return _firestore
        .collection('appointments')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  Future<Result<void, AppException>> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status,
      });
      return const Success(null);
    } catch (e) {
      return Failure(AppointmentException('Failed to update appointment status: $e'));
    }
  }

  Future<Result<void, AppException>> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(AppointmentException('Failed to delete appointment: $e'));
    }
  }

  Future<Result<List<AppointmentModel>, AppException>> getAppointmentsByPet(String petId) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('petId', isEqualTo: petId)
          .get();
      final appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
      appointments.sort((a, b) {
        if (a.dateTime == null && b.dateTime == null) return 0;
        if (a.dateTime == null) return 1;
        if (b.dateTime == null) return -1;
        return b.dateTime!.compareTo(a.dateTime!);
      });
      return Success(appointments);
    } catch (e) {
      return Failure(AppointmentException('Failed to fetch pet appointments: $e'));
    }
  }
}
