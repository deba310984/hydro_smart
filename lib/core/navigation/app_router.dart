/// Application Router using GoRouter
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydro_smart/features/auth/login_screen.dart';
import 'package:hydro_smart/features/auth/register_screen.dart';
import 'package:hydro_smart/features/dashboard/home_screen.dart';
import 'package:hydro_smart/features/farm/farm_setup_screen.dart';
import 'package:hydro_smart/features/ai/recommendation_screen.dart';
import 'package:hydro_smart/features/ai/presentation/disease_detection_screen.dart';
import 'package:hydro_smart/features/auth/auth_controller.dart';

/// Route names
class AppRoutes {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';
  static const String farmSetup = 'farmSetup';
  static const String recommendations = 'recommendations';
  static const String diseaseDetection = 'diseaseDetection';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';

      // If loading, stay on splash
      if (authState.isLoading) {
        return '/splash';
      }

      // If not logged in and not on login/register/splash, go to login
      if (!isLoggedIn && !isLoggingIn && !isSplash) {
        return '/login';
      }

      // If logged in and on login/register/splash, go to home
      if (isLoggedIn && (isLoggingIn || isSplash)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoutes.splash,
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/farm-setup',
        name: AppRoutes.farmSetup,
        builder: (context, state) => const FarmSetupScreen(),
      ),
      GoRoute(
        path: '/recommendations',
        name: AppRoutes.recommendations,
        builder: (context, state) => const RecommendationScreen(),
      ),
      GoRoute(
        path: '/disease-detection',
        name: AppRoutes.diseaseDetection,
        builder: (context, state) => const DiseaseDetectionScreen(),
      ),
    ],
  );
});
