import 'dart:io' show Platform;
import 'package:dio/dio.dart';

/// Service to communicate with the ML crop recommendation backend.
///
/// Sends temperature, humidity, location, and month to the FastAPI
/// backend and returns the predicted best crop with confidence score.
class MLCropService {
  // ──────────────────────────────────────────────
  // Backend URL configuration (priority order):
  //
  // 1. Compile-time override:
  //    flutter run --dart-define=ML_BACKEND_URL=https://...
  //
  // 2. Cloud (production) — Render free tier:
  //    https://hydrosmart-ml.onrender.com
  //
  // 3. Local dev fallback:
  //    Emulator  → http://10.0.2.2:8000
  //    Physical  → http://127.0.0.1:8000 (ADB reverse)
  // ──────────────────────────────────────────────

  /// ✏️  AFTER DEPLOYING TO RENDER, paste your real URL here:
  static const String _cloudUrl = 'https://hydrosmart-ml.onrender.com';

  // Compile-time override: flutter run --dart-define=ML_BACKEND_URL=https://...
  static const String _envUrl = String.fromEnvironment('ML_BACKEND_URL');

  /// Resolves the backend URL.
  /// Priority: compile-time env → cloud → local dev fallback.
  static String get _baseUrl {
    if (_envUrl.isNotEmpty) return _envUrl;

    // In release / profile mode, always use the cloud URL.
    const bool isRelease = bool.fromEnvironment('dart.vm.product');
    const bool isProfile = bool.fromEnvironment('dart.vm.profile');
    if (isRelease || isProfile) return _cloudUrl;

    // Debug mode: use local backend for fast iteration.
    final bool isEmulator = Platform.isAndroid && _isLikelyEmulator;
    return isEmulator
        ? 'http://10.0.2.2:8000'
        : 'http://127.0.0.1:8000'; // ADB reverse: phone localhost → PC
  }

  static bool get _isLikelyEmulator {
    try {
      final host = Platform.localHostname.toLowerCase();
      return host.contains('sdk') ||
          host.contains('emulator') ||
          host.contains('generic');
    } catch (_) {
      return false;
    }
  }

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Predict the single best crop.
  static Future<MLPrediction> predict({
    required double temperature,
    required double humidity,
    required String location,
    required int month,
  }) async {
    try {
      print('[ML] Requesting prediction: temp=$temperature, hum=$humidity, '
          'loc=$location, month=$month → $_baseUrl/predict');

      final response = await _dio.post(
        '$_baseUrl/predict',
        data: {
          'temperature': temperature,
          'humidity': humidity,
          'location': location,
          'month': month,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('[ML] Prediction: ${data['recommended_crop']} '
            '(${data['confidence']}%)');
        return MLPrediction.fromJson(data);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[ML] Network error: ${e.message}');
      rethrow;
    }
  }

  /// Get top-N predictions with confidence scores.
  static Future<List<MLTopPrediction>> predictTop({
    required double temperature,
    required double humidity,
    required String location,
    required int month,
    int n = 5,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/predict/top?n=$n',
        data: {
          'temperature': temperature,
          'humidity': humidity,
          'location': location,
          'month': month,
        },
      );

      if (response.statusCode == 200) {
        final List preds = response.data['predictions'];
        return preds.map((e) => MLTopPrediction.fromJson(e)).toList();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[ML] Top prediction error: ${e.message}');
      rethrow;
    }
  }

  /// Check if the ML backend is reachable and healthy.
  static Future<bool> isHealthy() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/health',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200 && response.data['status'] == 'healthy';
    } catch (_) {
      return false;
    }
  }

  /// Get the base URL being used.
  static String get baseUrl => _baseUrl;
}

// ──────────────────────────────────────────────
// Data models
// ──────────────────────────────────────────────
class MLPrediction {
  final String recommendedCrop;
  final double confidence;
  final String locationUsed;
  final Map<String, dynamic> inputSummary;

  MLPrediction({
    required this.recommendedCrop,
    required this.confidence,
    required this.locationUsed,
    required this.inputSummary,
  });

  factory MLPrediction.fromJson(Map<String, dynamic> json) {
    return MLPrediction(
      recommendedCrop: json['recommended_crop'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0).toDouble(),
      locationUsed: json['location_used'] ?? '',
      inputSummary: Map<String, dynamic>.from(json['input_summary'] ?? {}),
    );
  }
}

class MLTopPrediction {
  final String crop;
  final double confidence;

  MLTopPrediction({required this.crop, required this.confidence});

  factory MLTopPrediction.fromJson(Map<String, dynamic> json) {
    return MLTopPrediction(
      crop: json['crop'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}
