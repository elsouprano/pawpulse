// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/scan_result_model.dart';
import '../services/scanner_service.dart';
import '../core/utils/result.dart';

class ScannerState {
  final ScanResultModel? scanResult;
  final bool isScanning;
  final String? error;

  ScannerState({
    this.scanResult,
    this.isScanning = false,
    this.error,
  });

  ScannerState copyWith({
    ScanResultModel? scanResult,
    bool? isScanning,
    String? error,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return ScannerState(
      scanResult: clearResult ? null : (scanResult ?? this.scanResult),
      isScanning: isScanning ?? this.isScanning,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ScannerProvider extends ValueNotifier<ScannerState> {
  final ScannerService _scannerService;

  ScannerProvider(this._scannerService) : super(ScannerState());

  Future<void> startScan(String uid, String petId, File imageFile) async {
    value = value.copyWith(isScanning: true, clearError: true, clearResult: true);
    final result = await _scannerService.analyzePetImage(uid, petId, imageFile);
    if (result is Failure) {
      value = value.copyWith(isScanning: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(isScanning: false, scanResult: (result as Success).value);
    }
  }

  Future<void> saveScan() async {
    if (value.scanResult == null) return;
    
    value = value.copyWith(isScanning: true, clearError: true);
    final result = await _scannerService.saveScanResult(value.scanResult!);
    if (result is Failure) {
      value = value.copyWith(isScanning: false, error: (result as Failure).error.toString());
    } else {
      value = value.copyWith(isScanning: false, clearResult: true, error: 'Scan saved successfully!'); 
    }
  }
}
