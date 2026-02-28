import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// ─── User Profile Model ────────────────────────────────────────

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String accountType; // 'farmer' or 'company'
  final String? companyName;
  final String state;
  final String language; // 'EN' or 'HI'
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.accountType = 'farmer',
    this.companyName,
    this.state = 'All States',
    this.language = 'EN',
    this.phone,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      accountType: data['accountType'] ?? 'farmer',
      companyName: data['companyName'],
      state: data['state'] ?? 'All States',
      language: data['language'] ?? 'EN',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'accountType': accountType,
      'companyName': companyName,
      'state': state,
      'language': language,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? accountType,
    String? companyName,
    String? state,
    String? language,
    String? phone,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      accountType: accountType ?? this.accountType,
      companyName: companyName ?? this.companyName,
      state: state ?? this.state,
      language: language ?? this.language,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }
}

// ─── User Profile Provider ─────────────────────────────────────

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snap) {
        if (!snap.exists || snap.data() == null) return null;
        return UserProfile.fromFirestore(snap.data()!, user.uid);
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ─── Auth Controller ───────────────────────────────────────────

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

  /// Sign up with full profile stored in Firestore
  Future<void> signUpWithProfile({
    required String email,
    required String password,
    required String displayName,
    required String accountType,
    String? companyName,
    required String selectedState,
    required String language,
    String? phone,
  }) async {
    try {
      state = const AsyncLoading();

      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update Firebase Auth display name
      await credential.user?.updateDisplayName(displayName);

      // Store full profile in Firestore
      if (credential.user != null) {
        final profile = UserProfile(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
          accountType: accountType,
          companyName: companyName,
          state: selectedState,
          language: language,
          phone: phone,
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set(profile.toFirestore());
      }

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Legacy sign up (backward compat)
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

  /// Update user profile in Firestore
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? accountType,
    String? companyName,
    String? selectedState,
    String? language,
    String? phone,
  }) async {
    try {
      state = const AsyncLoading();

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (displayName != null) updates['displayName'] = displayName;
      if (accountType != null) updates['accountType'] = accountType;
      if (companyName != null) updates['companyName'] = companyName;
      if (selectedState != null) updates['state'] = selectedState;
      if (language != null) updates['language'] = language;
      if (phone != null) updates['phone'] = phone;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updates);

      // Also update Firebase Auth display name
      if (displayName != null) {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
      }

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
