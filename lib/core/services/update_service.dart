import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:install_plugin/install_plugin.dart';  // Commented out due to Android issues
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/update_model.dart';

class UpdateService {
  // Your deployed Render backend URL
  static const String _baseUrl =
      'https://hydro-smart-d6bimqbnv86c73af8ci0.onrender.com'; // Updated with your service ID
  static const String _appUpdateEndpoint = '/api/app/version';
  static const String _downloadEndpoint = '/api/app/download';
  static const String _configEndpoint = '/api/app/config';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5), // For APK downloads
    ),
  );

  /// Check for app updates from backend
  Future<AppVersion?> checkForUpdates() async {
    try {
      final currentInfo = await getCurrentVersion();
      final response = await _dio.get(
        '$_baseUrl$_appUpdateEndpoint',
        queryParameters: {
          'current_version': currentInfo['version'],
          'build_number': currentInfo['buildNumber'],
          'platform': 'android',
        },
      );

      if (response.statusCode == 200 &&
          response.data['updateAvailable'] == true) {
        return AppVersion.fromBackendResponse(response.data);
      }
      return null;
    } catch (e) {
      print('Error checking for updates: $e');
      return null;
    }
  }

  /// Get current app version
  Future<Map<String, dynamic>> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return {
      'version': packageInfo.version,
      'buildNumber': int.parse(packageInfo.buildNumber),
    };
  }

  /// Check if update is available
  Future<bool> isUpdateAvailable() async {
    final latestVersion = await checkForUpdates();
    if (latestVersion == null) return false;

    final currentInfo = await getCurrentVersion();
    return latestVersion.isNewerThan(
      currentInfo['version'],
      currentInfo['buildNumber'],
    );
  }

  /// Download APK file
  Future<String?> downloadApk(
    String downloadUrl,
    Function(double progress)? onProgress,
  ) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) throw Exception('External storage not available');

      final downloadsDir = Directory('${directory.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName =
          'hydro_smart_update_${DateTime.now().millisecondsSinceEpoch}.apk';
      final filePath = '${downloadsDir.path}/$fileName';

      await _dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      return filePath;
    } catch (e) {
      print('Error downloading APK: $e');
      return null;
    }
  }

  /// Install APK file
  Future<bool> installApk(String filePath) async {
    try {
      if (!await File(filePath).exists()) {
        throw Exception('APK file not found');
      }

      // Use system file opener to install APK
      final result = await OpenFilex.open(filePath);

      // Alternative: Open APK file directly with intent
      if (result.type == ResultType.done ||
          result.type == ResultType.noAppToOpen) {
        // Try opening with url_launcher as backup
        final uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }

      return result.type == ResultType.done;
    } catch (e) {
      print('Error installing APK: $e');
      // Try opening the Downloads folder so user can manually install
      try {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final downloadsDir = Directory('${directory.path}/Downloads');
          await OpenFilex.open(downloadsDir.path);
        }
      } catch (e) {
        print('Error opening downloads folder: $e');
      }
      return false;
    }
  }

  /// Clean up old APK files
  Future<void> cleanupOldApks() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return;

      final downloadsDir = Directory('${directory.path}/Downloads');
      if (!await downloadsDir.exists()) return;

      final files = downloadsDir.listSync();
      for (final file in files) {
        if (file is File &&
            file.path.contains('hydro_smart_update_') &&
            file.path.endsWith('.apk')) {
          final stat = await file.stat();
          final daysDiff = DateTime.now().difference(stat.modified).inDays;

          // Delete APK files older than 7 days
          if (daysDiff > 7) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Error cleaning up old APKs: $e');
    }
  }

  /// Get update configuration from backend
  Future<Map<String, dynamic>> getUpdateConfig() async {
    try {
      final response = await _dio.get('$_baseUrl$_configEndpoint');

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      print('Error fetching update config: $e');
      return {};
    }
  }

  /// Report update installation status to backend
  Future<void> reportUpdateStatus(String version, String status) async {
    try {
      await _dio.post(
        '$_baseUrl/api/app/update-status',
        data: {
          'version': version,
          'status': status, // 'downloaded', 'installed', 'failed'
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error reporting update status: $e');
    }
  }

  /// Schedule periodic update checks
  static void scheduleUpdateCheck() {
    // This would be called from main() to setup background update checks
    // You can implement using workmanager or similar package for background tasks
  }
}
