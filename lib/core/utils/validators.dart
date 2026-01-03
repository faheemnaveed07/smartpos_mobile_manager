class Validators {
  // Email validation (line 3)
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // TODO: Email regex pattern check karo
    return null;
  }

  // Password validation (line 11)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Phone validation (line 21)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone is required';
    // TODO: Check if starts with 03 and has 11 digits
    // HINT: Use regex: RegExp(r'^03[0-9]{9}$')
    return null;
  }
}
