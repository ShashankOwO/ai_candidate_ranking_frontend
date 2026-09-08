class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "This field is required";
    }

    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Username is required";
    }

    final trimmed = value.trim();

    if (trimmed.length < 3) {
      return "Username must be at least 3 characters";
    }

    if (trimmed.length > 50) {
      return "Username must not exceed 50 characters";
    }

    if (trimmed.contains('@')) {
      return "Please enter a valid username, not an email address";
    }

    if (trimmed.contains(' ')) {
      return "Username cannot contain spaces";
    }

    final validUsernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!validUsernameRegex.hasMatch(trimmed)) {
      return "Username can only contain letters, numbers, and underscores";
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Enter a valid email";
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 8) {
      return "Password must be at least 8 characters";
    }

    return null;
  }

  static String? Function(String?) confirmPassword(
    String Function() getPassword,
  ) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return "Confirm your password";
      }

      if (value != getPassword()) {
        return "Passwords do not match";
      }

      return null;
    };
  }
}