import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/weather_model.dart';

/// Service to handle location permissions and get current location
class LocationService {
  // High accuracy lets the OS use GPS; with only approximate permission the
  // result is still coarsened to city level, which is all weather needs.
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1000,
  );

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static LocationPermissionStatus _fromGeolocator(LocationPermission p) {
    switch (p) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        // Approximate-only grants also land here, which is all weather needs.
        return LocationPermissionStatus.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.permanentlyDenied;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }

  /// Check current location permission status
  static Future<LocationPermissionStatus> checkLocationPermission() async {
    return _fromGeolocator(await Geolocator.checkPermission());
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

    return _fromGeolocator(await Geolocator.requestPermission());
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
