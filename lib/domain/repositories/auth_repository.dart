import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;

  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<User?> signIn({required String email, required String password});

  Future<void> signOut();

  User? getCurrentUser();

  Future<void> updateProfile({required String displayName, String? photoUrl});
}
