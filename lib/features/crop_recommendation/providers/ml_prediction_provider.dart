import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ml_crop_service.dart';
import 'weather_providers.dart';

/// State for the ML prediction
class MLPredictionState {
  final MLPrediction? prediction;
  final List<MLTopPrediction>? topPredictions;
  final bool isLoading;
  final String? error;

  const MLPredictionState({
    this.prediction,
    this.topPredictions,
    this.isLoading = false,
    this.error,
  });

  MLPredictionState copyWith({
    MLPrediction? prediction,
    List<MLTopPrediction>? topPredictions,
    bool? isLoading,
    String? error,
  }) {
    return MLPredictionState(
      prediction: prediction ?? this.prediction,
      topPredictions: topPredictions ?? this.topPredictions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasPrediction => prediction != null;
}

/// Notifier that manages ML prediction state
class MLPredictionNotifier extends StateNotifier<MLPredictionState> {
  MLPredictionNotifier() : super(const MLPredictionState());

  /// Predict using current weather + user inputs
  Future<void> predictCrop({
    required double temperature,
    required double humidity,
    required String location,
    required int month,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch both single and top predictions in parallel
      final results = await Future.wait([
        MLCropService.predict(
          temperature: temperature,
          humidity: humidity,
          location: location,
          month: month,
        ),
        MLCropService.predictTop(
          temperature: temperature,
          humidity: humidity,
          location: location,
          month: month,
          n: 5,
        ),
      ]);

      state = MLPredictionState(
        prediction: results[0] as MLPrediction,
        topPredictions: results[1] as List<MLTopPrediction>,
        isLoading: false,
      );
    } catch (e) {
      print('[ML] Prediction failed: $e');
      state = MLPredictionState(
        isLoading: false,
        error: 'Failed to get AI recommendation: ${_friendlyError(e)}',
      );
    }
  }

  /// Clear prediction state
  void clear() {
    state = const MLPredictionState();
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'ML server is not reachable. Make sure the backend is running.';
    }
    if (msg.contains('TimeoutException') || msg.contains('CONNECT_TIMEOUT')) {
      return 'Request timed out. Check your network connection.';
    }
    return msg.length > 100 ? '${msg.substring(0, 100)}...' : msg;
  }
}

/// Provider for ML predictions
final mlPredictionProvider =
    StateNotifierProvider<MLPredictionNotifier, MLPredictionState>((ref) {
  return MLPredictionNotifier();
});

/// Provider to auto-predict when weather data is available
final autoMLPredictionProvider = Provider<void>((ref) {
  final weather = ref.watch(currentWeatherProvider);
  if (weather != null &&
      weather.locationName != 'Unknown Location' &&
      weather.temperature != 22.0) {
    // Only auto-predict if we have real weather data
    final notifier = ref.read(mlPredictionProvider.notifier);
    final currentState = ref.read(mlPredictionProvider);
    if (!currentState.hasPrediction && !currentState.isLoading) {
      notifier.predictCrop(
        temperature: weather.temperature,
        humidity: weather.humidity,
        location: _extractState(weather.locationName),
        month: DateTime.now().month,
      );
    }
  }
});

/// Extract Indian state from location name like "Kolkata, West Bengal, IN"
String _extractState(String locationName) {
  final parts = locationName.split(',').map((s) => s.trim()).toList();
  // Usually format: "City, State, Country" or "City, State"
  if (parts.length >= 2) {
    // Return second-to-last part (state), excluding country code
    final state = parts.length >= 3 ? parts[parts.length - 2] : parts.last;
    return state
        .replaceAll(RegExp(r'\s*(IN|India)\s*', caseSensitive: false), '')
        .trim();
  }
  return locationName;
}
