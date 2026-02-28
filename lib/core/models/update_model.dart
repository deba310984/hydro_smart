import 'package:equatable/equatable.dart';

/// Model for app version information
class AppVersion extends Equatable {
  final String version;
  final int buildNumber;
  final String downloadUrl;
  final String releaseDate;
  final String releaseNotes;
  final bool isForced;

  const AppVersion({
    required this.version,
    required this.buildNumber,
    required this.downloadUrl,
    required this.releaseDate,
    required this.releaseNotes,
    this.isForced = false,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      version: json['tag_name'] ?? '1.0.0',
      buildNumber: int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      downloadUrl: _extractApkUrl(json['assets'] as List<dynamic>?),
      releaseDate: json['published_at'] ?? DateTime.now().toIso8601String(),
      releaseNotes: json['body'] ?? 'No release notes available',
      isForced: (json['body'] ?? '').toLowerCase().contains('[forced]'),
    );
  }

  factory AppVersion.fromBackendResponse(Map<String, dynamic> json) {
    return AppVersion(
      version: json['latestVersion'] ?? '1.0.0',
      buildNumber: json['buildNumber'] ?? 1,
      downloadUrl: json['downloadUrl'] ?? '',
      releaseDate: json['releaseDate'] ?? DateTime.now().toIso8601String(),
      releaseNotes: json['releaseNotes'] ?? 'No release notes available',
      isForced: json['isForced'] ?? false,
    );
  }

  static String _extractApkUrl(List<dynamic>? assets) {
    if (assets == null) return '';

    for (final asset in assets) {
      if (asset is Map<String, dynamic>) {
        final name = asset['name'] as String?;
        if (name != null && name.endsWith('.apk')) {
          return asset['browser_download_url'] as String? ?? '';
        }
      }
    }
    return '';
  }

  bool isNewerThan(String currentVersion, int currentBuildNumber) {
    // Compare version numbers
    final currentVersionParts =
        currentVersion.split('.').map(int.parse).toList();
    final newVersionParts = version.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final current =
          i < currentVersionParts.length ? currentVersionParts[i] : 0;
      final newVer = i < newVersionParts.length ? newVersionParts[i] : 0;

      if (newVer > current) return true;
      if (newVer < current) return false;
    }

    // If version numbers are equal, compare build numbers
    return buildNumber > currentBuildNumber;
  }

  @override
  List<Object?> get props => [
        version,
        buildNumber,
        downloadUrl,
        releaseDate,
        releaseNotes,
        isForced,
      ];
}

/// Update status enumeration
enum UpdateStatus {
  checking,
  available,
  notAvailable,
  downloading,
  downloaded,
  installing,
  error,
}

/// Update state model
class UpdateState extends Equatable {
  final UpdateStatus status;
  final AppVersion? availableVersion;
  final String? currentVersion;
  final int? currentBuildNumber;
  final double downloadProgress;
  final String? errorMessage;

  const UpdateState({
    this.status = UpdateStatus.checking,
    this.availableVersion,
    this.currentVersion,
    this.currentBuildNumber,
    this.downloadProgress = 0.0,
    this.errorMessage,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    AppVersion? availableVersion,
    String? currentVersion,
    int? currentBuildNumber,
    double? downloadProgress,
    String? errorMessage,
  }) {
    return UpdateState(
      status: status ?? this.status,
      availableVersion: availableVersion ?? this.availableVersion,
      currentVersion: currentVersion ?? this.currentVersion,
      currentBuildNumber: currentBuildNumber ?? this.currentBuildNumber,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        availableVersion,
        currentVersion,
        currentBuildNumber,
        downloadProgress,
        errorMessage,
      ];
}
