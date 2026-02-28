import 'package:dio/dio.dart';
import 'package:hydro_smart/core/utils/validators.dart';
import 'package:hydro_smart/data/models/recommendation_model.dart';
import 'package:hydro_smart/domain/repositories/recommendation_repository.dart';

/// Dio implementation of RecommendationRepository
/// Integrates with AI crop recommendation REST API
class RecommendationRepositoryImpl implements RecommendationRepository {
  final Dio _dio;

  // API base URL - Replace with your actual AI service endpoint
  static const String _baseUrl =
      'https://hydro-smart-backend.onrender.com/api/v1';
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
    String? state,
    int? month,
  }) async {
    try {
      Logger.info(
        'Fetching crop recommendation - Temp: $currentTemperature°C, Humidity: $currentHumidity%, pH: $currentPh, State: $state',
      );

      final data = <String, dynamic>{
        'currentTemperature': currentTemperature,
        'currentHumidity': currentHumidity,
        'currentPh': currentPh,
        'farmSize': farmSize,
      };

      if (state != null) data['state'] = state;
      if (month != null) data['month'] = month;

      final response = await _dio.post(
        '/recommendations',
        data: data,
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
    String? state,
    int? month,
    String? category,
    String? difficulty,
  }) async {
    try {
      Logger.info('Fetching $count crop recommendations for state: $state');

      final data = <String, dynamic>{
        'currentTemperature': currentTemperature,
        'currentHumidity': currentHumidity,
        'currentPh': currentPh,
        'farmSize': farmSize,
        'count': count,
      };

      if (state != null) data['state'] = state;
      if (month != null) data['month'] = month;
      if (category != null) data['category'] = category;
      if (difficulty != null) data['difficulty'] = difficulty;

      final response = await _dio.post(
        '/recommendations/multiple',
        data: data,
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

  /// Get seasonal recommendations for a specific state
  Future<SeasonalRecommendation> getSeasonalRecommendations({
    required String state,
    int? month,
  }) async {
    try {
      Logger.info('Fetching seasonal recommendations for $state');

      final data = <String, dynamic>{
        'state': state,
      };
      if (month != null) data['month'] = month;

      final response = await _dio.post(
        '/recommendations/seasonal',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final seasonalRec = SeasonalRecommendation.fromJson(
          response.data as Map<String, dynamic>,
        );
        Logger.info(
          'Received seasonal recommendations for ${seasonalRec.season} in ${seasonalRec.state}',
        );
        return seasonalRec;
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      Logger.error('Dio error fetching seasonal recommendations: $e');
      throw _handleDioError(e);
    } catch (e) {
      Logger.error('Unexpected error fetching seasonal recommendations: $e');
      rethrow;
    }
  }

  /// Get all available crops from database
  Future<List<RecommendationModel>> getAllCrops() async {
    try {
      Logger.info('Fetching all crops from database');

      final response = await _dio.get('/crops');

      if (response.statusCode == 200) {
        final cropsList = List<Map<String, dynamic>>.from(
          response.data as List<dynamic>,
        );
        return cropsList
            .map((json) => RecommendationModel.fromJson(json))
            .toList();
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      Logger.error('Dio error fetching crops: $e');
      throw _handleDioError(e);
    } catch (e) {
      Logger.error('Unexpected error fetching crops: $e');
      rethrow;
    }
  }

  /// Get crops by category
  Future<List<RecommendationModel>> getCropsByCategory(String category) async {
    try {
      Logger.info('Fetching crops for category: $category');

      final response = await _dio.get('/crops/category/$category');

      if (response.statusCode == 200) {
        final cropsList = List<Map<String, dynamic>>.from(
          response.data as List<dynamic>,
        );
        return cropsList
            .map((json) => RecommendationModel.fromJson(json))
            .toList();
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      Logger.error('Dio error fetching crops by category: $e');
      throw _handleDioError(e);
    } catch (e) {
      Logger.error('Unexpected error fetching crops by category: $e');
      rethrow;
    }
  }

  /// Get all crop categories
  Future<List<CropCategory>> getCategories() async {
    try {
      Logger.info('Fetching crop categories');

      final response = await _dio.get('/categories');

      if (response.statusCode == 200) {
        final categoriesList = List<Map<String, dynamic>>.from(
          response.data as List<dynamic>,
        );
        return categoriesList
            .map((json) => CropCategory.fromJson(json))
            .toList();
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      Logger.error('Dio error fetching categories: $e');
      throw _handleDioError(e);
    } catch (e) {
      Logger.error('Unexpected error fetching categories: $e');
      rethrow;
    }
  }

  /// Get Indian states with climate zones
  Future<Map<String, String>> getIndianStates() async {
    try {
      Logger.info('Fetching Indian states');

      final response = await _dio.get('/states');

      if (response.statusCode == 200) {
        return Map<String, String>.from(response.data as Map);
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      Logger.error('Dio error fetching states: $e');
      throw _handleDioError(e);
    } catch (e) {
      Logger.error('Unexpected error fetching states: $e');
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
