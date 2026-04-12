// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../core/utils/result.dart';

class AppointmentState {
  final List<AppointmentModel> appointments;
  final List<AppointmentModel> upcoming;
  final bool isLoading;
  final String? error;

  AppointmentState({
    this.appointments = const [],
    this.upcoming = const [],
    this.isLoading = false,
    this.error,
  });

  AppointmentState copyWith({
    List<AppointmentModel>? appointments,
    List<AppointmentModel>? upcoming,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      upcoming: upcoming ?? this.upcoming,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AppointmentProvider extends ValueNotifier<AppointmentState> {
  final AppointmentService _appointmentService;
  StreamSubscription? _appointmentSub;
  StreamSubscription? _upcomingSub;

  AppointmentProvider(this._appointmentService) : super(AppointmentState());

  @override
  void dispose() {
    _appointmentSub?.cancel();
    _upcomingSub?.cancel();
    super.dispose();
  }

  void loadAppointments(String ownerId) {
    value = value.copyWith(isLoading: true, clearError: true);
    
    _appointmentSub?.cancel();
    _appointmentSub = _appointmentService.getAppointmentsByOwner(ownerId).listen(
      (data) {
        value = value.copyWith(appointments: data, isLoading: false);
      },
      onError: (e) {
        value = value.copyWith(isLoading: false, error: e.toString());
      },
    );

    _upcomingSub?.cancel();
    _upcomingSub = _appointmentService.getUpcomingAppointments(ownerId).listen(
      (data) {
        value = value.copyWith(upcoming: data);
      },
      onError: (e) {
        // If the second stream fails, we still need to catch it!
        value = value.copyWith(isLoading: false, error: e.toString());
      },
    );
  }

  Future<void> bookAppointment(AppointmentModel appointment) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _appointmentService.bookAppointment(appointment);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(isLoading: false);
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _appointmentService.cancelAppointment(appointmentId);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(isLoading: false);
    }
  }

  Future<void> updateStatus(String appointmentId, String status) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _appointmentService.updateAppointmentStatus(appointmentId, status);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(isLoading: false);
    }
  }
}
