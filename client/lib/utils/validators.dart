class Validators {
  // First Name validation
  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    return null;
  }

  // Last Name validation
  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    if (value.contains('..') || value.endsWith('.')) {
      return 'Invalid email format';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return null;
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
