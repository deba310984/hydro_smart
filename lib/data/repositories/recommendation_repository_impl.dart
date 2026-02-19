import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:hydro_smart/core/utils/validators.dart';
import 'package:hydro_smart/data/models/recommendation_model.dart';
import 'package:hydro_smart/domain/repositories/recommendation_repository.dart';

/// Dio implementation of RecommendationRepository
/// Integrates with AI crop recommendation REST API
class RecommendationRepositoryImpl implements RecommendationRepository {
  final Dio _dio;

  static const String _androidUrl = 'http://10.0.2.2:8080/api/v1';
  static const String _localhostUrl = 'http://127.0.0.1:8080/api/v1';

  static String get _baseUrl {
    if (kIsWeb) return _localhostUrl;
    // Note: detailed Platform checks (isAndroid) would require dart:io which isn't web-safe
    // Defaulting to 10.0.2.2 for Android Emulator as primary non-web target
    return _androidUrl;
  }

  static const Duration _timeout = Duration(seconds: 30);

  RecommendationRepositoryImpl({Dio? dio}) : _dio = dio ?? _createDio();

  /// Create and configure Dio instance with defaults
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        contentType: 'application/json',
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add logging interceptors in debug mode
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }

  @override
  Future<RecommendationModel> getRecommendation({
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
    required double farmSize,
  }) async {
    try {
      Logger.info(
        'Fetching crop recommendation - Temp: $currentTemperature°C, Humidity: $currentHumidity%, pH: $currentPh',
      );

      final response = await _dio.post(
        '/recommendations',
        data: {
          'currentTemperature': currentTemperature,
          'currentHumidity': currentHumidity,
          'currentPh': currentPh,
          'farmSize': farmSize,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final recommendation = RecommendationModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        Logger.info(
          'Received recommendation: ${recommendation.recommendedCrop}',
        );
        return recommendation;
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      Logger.error('Dio error fetching recommendation: $e');
      throw _handleDioError(e);
    } catch (e) {
      Logger.error('Unexpected error fetching recommendation: $e');
      rethrow;
    }
  }

  @override
  Future<List<RecommendationModel>> getMultipleRecommendations({
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
    required double farmSize,
    required int count,
  }) async {
    try {
      Logger.info('Fetching $count crop recommendations');

      final response = await _dio.post(
        '/recommendations/multiple',
        data: {
          'currentTemperature': currentTemperature,
          'currentHumidity': currentHumidity,
          'currentPh': currentPh,
          'farmSize': farmSize,
          'count': count,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final recommendationsList = List<Map<String, dynamic>>.from(
          response.data as List<dynamic>,
        );
        final recommendations = recommendationsList
            .map((json) => RecommendationModel.fromJson(json))
            .toList();
        Logger.info('Received ${recommendations.length} recommendations');
        return recommendations;
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      Logger.error('Dio error fetching multiple recommendations: $e');
      throw _handleDioError(e);
    } catch (e) {
      Logger.error('Unexpected error fetching multiple recommendations: $e');
      rethrow;
    }
  }

  @override
  Future<double> evaluateCropCompatibility({
    required String cropName,
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
  }) async {
    try {
      Logger.info('Evaluating compatibility for crop: $cropName');

      final response = await _dio.post(
        '/recommendations/evaluate',
        data: {
          'cropName': cropName,
          'currentTemperature': currentTemperature,
          'currentHumidity': currentHumidity,
          'currentPh': currentPh,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final score =
            (response.data['compatibilityScore'] as num?)?.toDouble() ?? 0.0;
        Logger.info('Compatibility score for $cropName: $score');
        return score;
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      Logger.error('Dio error evaluating crop compatibility: $e');
      throw _handleDioError(e);
    } catch (e) {
      Logger.error('Unexpected error evaluating crop compatibility: $e');
      rethrow;
    }
  }

  /// Handle API response errors
  Exception _handleApiError(Response<dynamic> response) {
    final statusCode = response.statusCode;
    final errorData = response.data as Map<String, dynamic>?;
    final message = errorData?['message'] as String? ?? 'Unknown API error';

    return switch (statusCode) {
      400 => Exception('Invalid request: $message'),
      401 => Exception('Authentication failed: $message'),
      403 => Exception('Access denied: $message'),
      404 => Exception('Recommendation service not found'),
      429 => Exception('Rate limit exceeded. Please try again later.'),
      500 => Exception('Server error: $message'),
      503 => Exception('Service temporarily unavailable'),
      _ => Exception('API error: $message (Status: $statusCode)'),
    };
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => Exception(
          'Connection timeout. Check your internet connection.',
        ),
      DioExceptionType.sendTimeout => Exception(
          'Request timeout. Server is not responding.',
        ),
      DioExceptionType.receiveTimeout => Exception(
          'Response timeout. Server took too long to respond.',
        ),
      DioExceptionType.badResponse => Exception(
          'Bad response: ${error.response?.statusCode}',
        ),
      DioExceptionType.cancel => Exception('Request was cancelled.'),
      DioExceptionType.badCertificate => Exception('SSL certificate error.'),
      DioExceptionType.connectionError => Exception(
          'Connection error. Please check your internet.',
        ),
      DioExceptionType.unknown => Exception('Network error: ${error.message}'),
    };
  }
}
