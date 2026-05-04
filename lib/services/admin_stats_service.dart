import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/health_record_model.dart';
import '../core/constants/firebase_constants.dart';

class AdminStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalUsers() async {
    final snapshot = await _firestore.collection(FirebaseConstants.usersCollection).count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getTotalPets() async {
    final snapshot = await _firestore.collection(FirebaseConstants.petsCollection).count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getTotalAppointments() async {
    final snapshot = await _firestore.collection(FirebaseConstants.appointmentsCollection).count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getTotalHealthRecords() async {
    final snapshot = await _firestore.collection(FirebaseConstants.healthRecordsCollection).count().get();
    return snapshot.count ?? 0;
  }

  Future<List<UserModel>> getRecentUsers({int limit = 5}) async {
    final query = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
        
    return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  Future<List<AppointmentModel>> getRecentAppointments({int limit = 5}) async {
    final query = await _firestore
        .collection(FirebaseConstants.appointmentsCollection)
        .orderBy('dateTime', descending: true)
        .limit(limit)
        .get();
        
    return query.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
  }

  Stream<List<HealthRecordModel>> watchAllHealthRecords() {
    return _firestore
        .collection(FirebaseConstants.healthRecordsCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthRecordModel.fromFirestore(doc))
            .toList());
  }
}
