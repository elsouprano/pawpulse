class Validators {
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your full name (first and last name)";
    }
    String stripped = value.trim();
    if (stripped.length < 2 || stripped.length > 50) {
      return "Please enter your full name (first and last name)";
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(stripped)) {
      return "Name can only contain letters and spaces";
    }
    List<String> words = stripped.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length < 2) {
      return "Please enter your full name (first and last name)";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a valid email address";
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$").hasMatch(value.trim())) {
      return "Please enter a valid email address";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password must be at least 8 characters";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Password must contain at least one uppercase letter";
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "Password must contain at least one lowercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Password must contain at least one number";
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Password must contain at least one special character (!@#\$%^&*)";
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty || value != password) {
      return "Passwords do not match";
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a valid Philippine mobile number (e.g. 09XX XXX XXXX)";
    }
    String stripped = value.replaceAll(' ', '').replaceAll('-', '');
    if (!RegExp(r'^(\+?63|0)9[0-9]{9}$').hasMatch(stripped)) {
      return "Please enter a valid Philippine mobile number (e.g. 09XX XXX XXXX)";
    }
    return null;
  }

  static String? validatePetName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a valid pet name";
    }
    String stripped = value.trim();
    if (stripped.isEmpty || stripped.length > 30) {
      return "Please enter a valid pet name";
    }
    if (!RegExp(r"^[a-zA-Z0-9\s\-]+$").hasMatch(stripped)) {
      return "Please enter a valid pet name";
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a valid age (0–30 years)";
    }
    final age = double.tryParse(value.trim());
    if (age == null || age < 0 || age > 30) {
      return "Please enter a valid age (0–30 years)";
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a valid weight (0.1–200 kg)";
    }
    final weight = double.tryParse(value.trim());
    if (weight == null || weight < 0.1 || weight > 200) {
      return "Please enter a valid weight (0.1–200 kg)";
    }
    return null;
  }

  static String? validateBreed(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a valid breed name";
    }
    String stripped = value.trim();
    if (stripped.length < 2 || stripped.length > 50) {
      return "Please enter a valid breed name";
    }
    if (!RegExp(r"^[a-zA-Z\s\-]+$").hasMatch(stripped)) {
      return "Please enter a valid breed name";
    }
    return null;
  }

  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 500) {
      return "Notes cannot exceed 500 characters";
    }
    return null;
  }
}
