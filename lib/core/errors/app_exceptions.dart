// ─────────────────────────────────────────────────────────
// PawPulse — Logic Layer
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(super.message);
}

class PetException extends AppException {
  PetException(super.message);
}

class AppointmentException extends AppException {
  AppointmentException(super.message);
}

class ScannerException extends AppException {
  ScannerException(super.message);
}

class HealthRecordException extends AppException {
  HealthRecordException(super.message);
}

class GeneralException extends AppException {
  GeneralException(super.message);
}
