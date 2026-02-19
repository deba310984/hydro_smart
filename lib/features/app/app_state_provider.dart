import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// App-wide state for common features

// Connectivity status provider
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    return !results.contains(ConnectivityResult.none);
  }).distinct();
});

/// Checks if device is currently online
final isOnlineProvider = FutureProvider<bool>((ref) async {
  final results = await Connectivity().checkConnectivity();
  return !results.contains(ConnectivityResult.none);
});

/// Global theme mode provider
class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // false = light, true = dark

  void toggleTheme() {
    state = !state;
  }

  void setDarkMode(bool isDark) {
    state = isDark;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

/// Global loading indicator state
class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void show() {
    state = true;
  }

  void hide() {
    state = false;
  }
}

final globalLoadingProvider = StateNotifierProvider<LoadingNotifier, bool>((
  ref,
) {
  return LoadingNotifier();
});

/// Global error state
class ErrorNotifier extends StateNotifier<String?> {
  ErrorNotifier() : super(null);

  void setError(String error) {
    state = error;
  }

  void clearError() {
    state = null;
  }
}

final globalErrorProvider = StateNotifierProvider<ErrorNotifier, String?>(
  (ref) => ErrorNotifier(),
);

/// Combined app state for quick access
class AppState {
  final bool isOnline;
  final bool isDarkMode;
  final bool isLoading;
  final String? errorMessage;

  AppState({
    required this.isOnline,
    required this.isDarkMode,
    required this.isLoading,
    this.errorMessage,
  });
}

final appStateProvider = Provider<AppState>((ref) {
  final onlineAsync = ref.watch(isOnlineProvider);
  final isDarkMode = ref.watch(themeProvider);
  final isLoading = ref.watch(globalLoadingProvider);
  final error = ref.watch(globalErrorProvider);

  return onlineAsync.when(
    data: (isOnline) => AppState(
      isOnline: isOnline,
      isDarkMode: isDarkMode,
      isLoading: isLoading,
      errorMessage: error,
    ),
    loading: () => AppState(
      isOnline: true,
      isDarkMode: isDarkMode,
      isLoading: isLoading,
      errorMessage: error,
    ),
    error: (_, __) => AppState(
      isOnline: false,
      isDarkMode: isDarkMode,
      isLoading: isLoading,
      errorMessage: error,
    ),
  );
});
