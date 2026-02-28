import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/weather_model.dart';

/// Service to handle location permissions and get current location
class LocationService {
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100, // Update only when moved 100m
  );

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status
  static Future<LocationPermissionStatus> checkLocationPermission() async {
    final permission = await Permission.location.status;

    switch (permission) {
      case PermissionStatus.granted:
        return LocationPermissionStatus.granted;
      case PermissionStatus.denied:
        return LocationPermissionStatus.denied;
      case PermissionStatus.permanentlyDenied:
        return LocationPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        return LocationPermissionStatus.denied;
    }
  }

  /// Request location permission
  static Future<LocationPermissionStatus> requestLocationPermission() async {
    // Check if location service is enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw AppLocationServiceDisabledException();
    }

    // Check current permission
    final currentStatus = await checkLocationPermission();
    if (currentStatus == LocationPermissionStatus.granted) {
      return currentStatus;
    }

    if (currentStatus == LocationPermissionStatus.permanentlyDenied) {
      return LocationPermissionStatus.permanentlyDenied;
    }

    // Request permission if denied
    final permission = await Permission.location.request();

    switch (permission) {
      case PermissionStatus.granted:
        return LocationPermissionStatus.granted;
      case PermissionStatus.denied:
        return LocationPermissionStatus.denied;
      case PermissionStatus.permanentlyDenied:
        return LocationPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        return LocationPermissionStatus.denied;
    }
  }

  /// Get current position with permission handling
  static Future<Position> getCurrentLocation() async {
    final permissionStatus = await requestLocationPermission();

    if (permissionStatus != LocationPermissionStatus.granted) {
      throw LocationPermissionException('Location permission denied');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      throw LocationException('Failed to get location: $e');
    }
  }

  /// Get location stream for continuous updates
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    );
  }

  /// Calculate distance between two points in meters
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Open app settings for location permission
  static Future<bool> openLocationSettings() async {
    return await openAppSettings();
  }
}

/// Custom exceptions for location service
class AppLocationServiceDisabledException implements Exception {
  final String message = 'Location services are disabled on this device.';
  @override
  String toString() => message;
}

class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);
  @override
  String toString() => message;
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  @override
  String toString() => message;
}
