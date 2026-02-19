import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  debugPrint("authStateProvider started");

  return FirebaseAuth.instance.authStateChanges().map((user) {
    debugPrint("Auth state changed: ${user?.uid}");
    return user;
  });
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
        (ref) => AuthController());

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncData(null));

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncLoading();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = const AsyncLoading();

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
