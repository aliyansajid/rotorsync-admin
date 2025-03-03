class Validators {
  // Full Name validation
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }

    // Trim extra spaces
    value = value.trim();

    // Minimum length check
    if (value.length < 3) {
      return 'Full name must be at least 3 characters';
    }

    // Maximum length check
    if (value.length > 50) {
      return 'Full name cannot exceed 50 characters';
    }

    // Check for only valid characters (letters, spaces, and hyphens)
    final RegExp nameRegExp = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ\s-]+$");
    if (!nameRegExp.hasMatch(value)) {
      return 'Full name can only contain letters, spaces, and hyphens';
    }

    // Prevent multiple consecutive spaces or hyphens
    if (RegExp(r"\s{2,}").hasMatch(value) || RegExp(r"-{2,}").hasMatch(value)) {
      return 'Full name cannot contain consecutive spaces or hyphens';
    }

    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    value = value.trim(); // Trim spaces

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    if (value.contains('..') || value.endsWith('.') || value.contains(' ')) {
      return 'Invalid email format';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.contains(' ')) {
      return 'Password cannot contain spaces';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  // Broker URL validation
  static String? validateBrokerUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Broker URL is required';
    }

    return null;
  }

  // Port validation
  static String? validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return 'Port is required';
    }
    final port = int.tryParse(value);
    if (port == null || port < 4 || port > 65535) {
      return 'Invalid port number';
    }
    return null;
  }

  // Base Path validation
  static String? validateBasePath(String? value) {
    if (value == null || value.isEmpty) {
      return 'Base path is required';
    }
    if (value.contains(' ')) {
      return 'Base path cannot contain spaces';
    }
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    return null;
  }
}
