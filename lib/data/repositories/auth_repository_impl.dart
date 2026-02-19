import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/error_handler.dart';
import '../../domain/repositories/auth_repository.dart' as domain;

class AuthRepositoryImpl implements domain.AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? getCurrentUser() => _firebaseAuth.currentUser;

  @override
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(displayName);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      final message = _handleAuthException(e);
      ErrorHandler.logError(e, context: 'AuthRepositoryImpl.signUp');
      throw AppException(message: message, code: e.code, originalError: e);
    } catch (e) {
      ErrorHandler.logError(e, context: 'AuthRepositoryImpl.signUp');
      throw AppException(
        message: 'Sign up failed. Please try again.',
        code: 'sign_up_error',
        originalError: e,
      );
    }
  }

  @override
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      final message = _handleAuthException(e);
      ErrorHandler.logError(e, context: 'AuthRepositoryImpl.signIn');
      throw AppException(message: message, code: e.code, originalError: e);
    } catch (e) {
      ErrorHandler.logError(e, context: 'AuthRepositoryImpl.signIn');
      throw AppException(
        message: 'Sign in failed. Please try again.',
        code: 'sign_in_error',
        originalError: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      ErrorHandler.logError(e, context: 'AuthRepositoryImpl.signOut');
      throw AppException(
        message: 'Failed to sign out. Please try again.',
        code: 'sign_out_error',
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
      if (photoUrl != null) {
        await _firebaseAuth.currentUser?.updatePhotoURL(photoUrl);
      }
      await _firebaseAuth.currentUser?.reload();
    } catch (e) {
      ErrorHandler.logError(e, context: 'AuthRepositoryImpl.updateProfile');
      throw AppException(
        message: 'Failed to update profile. Please try again.',
        code: 'update_profile_error',
        originalError: e,
      );
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
