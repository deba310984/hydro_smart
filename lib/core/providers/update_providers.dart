import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/update_model.dart';
import '../services/update_service.dart';

/// Update service provider
final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

/// Update state notifier
class UpdateNotifier extends StateNotifier<UpdateState> {
  UpdateNotifier(this._updateService) : super(const UpdateState()) {
    _loadCurrentVersion();
  }

  final UpdateService _updateService;

  /// Load current app version
  Future<void> _loadCurrentVersion() async {
    try {
      final currentInfo = await _updateService.getCurrentVersion();
      state = state.copyWith(
        currentVersion: currentInfo['version'],
        currentBuildNumber: currentInfo['buildNumber'],
        status: UpdateStatus.notAvailable,
      );
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Failed to get current version: $e',
      );
    }
  }

  /// Check for updates
  Future<void> checkForUpdates({bool showNoUpdateMessage = false}) async {
    state = state.copyWith(status: UpdateStatus.checking);

    try {
      final latestVersion = await _updateService.checkForUpdates();

      if (latestVersion == null) {
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage:
              'Failed to check for updates. Please check your internet connection.',
        );
        return;
      }

      if (state.currentVersion != null && state.currentBuildNumber != null) {
        if (latestVersion.isNewerThan(
            state.currentVersion!, state.currentBuildNumber!)) {
          state = state.copyWith(
            status: UpdateStatus.available,
            availableVersion: latestVersion,
          );

          // Save update check timestamp
          await _saveLastUpdateCheck();
        } else {
          state = state.copyWith(
            status: UpdateStatus.notAvailable,
            availableVersion: null,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Error checking for updates: $e',
      );
    }
  }

  /// Download update
  Future<void> downloadUpdate() async {
    final availableVersion = state.availableVersion;
    if (availableVersion == null || availableVersion.downloadUrl.isEmpty) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'No download URL available',
      );
      return;
    }

    state = state.copyWith(
      status: UpdateStatus.downloading,
      downloadProgress: 0.0,
    );

    try {
      final filePath = await _updateService.downloadApk(
        availableVersion.downloadUrl,
        (progress) {
          state = state.copyWith(downloadProgress: progress);
        },
      );

      if (filePath != null) {
        state = state.copyWith(
          status: UpdateStatus.downloaded,
          downloadProgress: 1.0,
        );

        // Auto-install if downloaded successfully
        await installUpdate(filePath);
      } else {
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: 'Failed to download update',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Download failed: $e',
      );
    }
  }

  /// Install update
  Future<void> installUpdate(String filePath) async {
    state = state.copyWith(status: UpdateStatus.installing);

    try {
      final success = await _updateService.installApk(filePath);

      if (success) {
        // Installation initiated successfully
        // The app will be closed and new version will be installed
        state = state.copyWith(status: UpdateStatus.notAvailable);
      } else {
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: 'Failed to install update. Please install manually.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Installation failed: $e',
      );
    }
  }

  /// Dismiss update (for non-forced updates)
  void dismissUpdate() {
    if (state.availableVersion?.isForced != true) {
      state = state.copyWith(
        status: UpdateStatus.notAvailable,
        availableVersion: null,
      );
    }
  }

  /// Save last update check timestamp
  Future<void> _saveLastUpdateCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'last_update_check', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving last update check: $e');
    }
  }

  /// Check if enough time has passed since last update check
  Future<bool> shouldCheckForUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt('last_update_check') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      const checkInterval = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

      return (now - lastCheck) > checkInterval;
    } catch (e) {
      return true; // Default to checking if there's an error
    }
  }

  /// Cleanup old APK files
  Future<void> cleanupOldFiles() async {
    await _updateService.cleanupOldApks();
  }
}

/// Update state provider
final updateProvider =
    StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  final updateService = ref.watch(updateServiceProvider);
  return UpdateNotifier(updateService);
});

/// Auto-update check provider (runs on app start)
final autoUpdateCheckProvider = FutureProvider<void>((ref) async {
  final updateNotifier = ref.read(updateProvider.notifier);

  // Check if we should perform automatic update check
  if (await updateNotifier.shouldCheckForUpdates()) {
    await updateNotifier.checkForUpdates();
  }

  // Cleanup old files
  await updateNotifier.cleanupOldFiles();
});
