/// Utility functions for validation
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateFarmName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Farm name is required';
    }
    if (value.length < 3) {
      return 'Farm name must be at least 3 characters';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Simple logging utility
class Logger {
  static void info(String message) {
    print('ℹ️ [INFO] $message');
  }

  static void warning(String message) {
    print('⚠️ [WARNING] $message');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('❌ [ERROR] $message');
    if (error != null) {
      print('Error: $error');
    }
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }

  static void debug(String message) {
    print('🐛 [DEBUG] $message');
  }
}

/// Extension methods for common operations
extension StringExtension on String {
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get truncate {
    return length > 30 ? '${substring(0, 30)}...' : this;
  }
}

extension DateTimeExtension on DateTime {
  String get formattedDate {
    return '$day/$month/$year';
  }

  String get formattedTime {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDateTime {
    return '$day/$month/$year $formattedTime';
  }

  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }
}
