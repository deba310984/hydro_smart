import 'package:flutter/material.dart';

/// Global error handling and user-facing messages
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Maps exceptions to user-friendly messages
class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is Exception) {
      final message = error.toString();

      // Network errors
      if (message.contains('TimeoutException')) {
        return 'Request timeout. Please check your internet connection.';
      }
      if (message.contains('Connection refused')) {
        return 'Connection failed. Please check your internet.';
      }
      if (message.contains('SocketException')) {
        return 'Network error. Please try again.';
      }

      // Firebase errors
      if (message.contains('user-not-found')) {
        return 'No account found with this email.';
      }
      if (message.contains('wrong-password')) {
        return 'Incorrect password.';
      }
      if (message.contains('email-already-in-use')) {
        return 'Email already registered.';
      }
      if (message.contains('weak-password')) {
        return 'Password too weak. Use 6+ characters.';
      }
      if (message.contains('invalid-email')) {
        return 'Invalid email format.';
      }
      if (message.contains('too-many-requests')) {
        return 'Too many attempts. Try again later.';
      }

      // Generic error
      return 'An error occurred. Please try again.';
    }

    return 'Unknown error occurred.';
  }

  /// Log error with context
  static void logError(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
  }) {
    final ctx = context ?? 'UnknownContext';
    print('❌ [$ctx] ERROR: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }

  /// Show error snackbar (call from UI with context)
  static void showErrorSnackbar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
