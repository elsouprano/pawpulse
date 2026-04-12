// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/health_record_model.dart';
import '../services/health_record_service.dart';
import '../core/utils/result.dart';

class HealthRecordState {
  final List<HealthRecordModel> records;
  final String activeFilter;
  final bool isLoading;
  final String? error;

  HealthRecordState({
    this.records = const [],
    this.activeFilter = 'All',
    this.isLoading = false,
    this.error,
  });

  HealthRecordState copyWith({
    List<HealthRecordModel>? records,
    String? activeFilter,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HealthRecordState(
      records: records ?? this.records,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HealthRecordProvider extends ValueNotifier<HealthRecordState> {
  final HealthRecordService _healthRecordService;
  StreamSubscription? _recordSub;
  String _currentPetId = '';

  HealthRecordProvider(this._healthRecordService) : super(HealthRecordState());

  @override
  void dispose() {
    _recordSub?.cancel();
    super.dispose();
  }

  void loadRecords(String petId) {
    _currentPetId = petId;
    value = value.copyWith(isLoading: true, clearError: true, activeFilter: 'All');
    _listenToRecords();
  }

  void setFilter(String type) {
    value = value.copyWith(activeFilter: type, isLoading: true, clearError: true);
    _listenToRecords();
  }

  void _listenToRecords() {
    if (_currentPetId.isEmpty) return;
    
    _recordSub?.cancel();
    final stream = value.activeFilter == 'All' 
        ? _healthRecordService.getHealthRecordsByPet(_currentPetId)
        : _healthRecordService.getHealthRecordsByType(_currentPetId, value.activeFilter);

    _recordSub = stream.listen(
      (data) {
        value = value.copyWith(records: data, isLoading: false);
      },
      onError: (e) {
        value = value.copyWith(isLoading: false, error: e.toString());
      },
    );
  }

  Future<void> addRecord(HealthRecordModel record) async {
    value = value.copyWith(isLoading: true, clearError: true);
    final result = await _healthRecordService.addHealthRecord(record);
    if (result is Failure) {
      value = value.copyWith(isLoading: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(isLoading: false);
    }
  }
}
