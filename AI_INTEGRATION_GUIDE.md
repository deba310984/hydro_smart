# AI Crop Recommendation Engine - Integration Guide

## Overview

The Hydro Smart application includes an AI-powered crop recommendation engine that analyzes current growing conditions (temperature, humidity, pH, farm size) and suggests the most suitable crops with optimal cultivation parameters.

## Architecture

### Clean Architecture Layers

#### Domain Layer
- **RecommendationRepository** (abstract interface)
  - `getRecommendation()`: Get single AI crop recommendation
  - `getMultipleRecommendations()`: Get alternative crop suggestions (3+)
  - `evaluateCropCompatibility()`: Score compatibility for specific crop

#### Data Layer
- **RecommendationRepositoryImpl** (Dio REST client)
  - Handles HTTP requests to AI backend
  - Maps API responses to RecommendationModel
  - Comprehensive error handling with user-friendly messages
  - Timeout configuration (30 seconds)
  - Dio interceptors for logging and debugging

#### Models
- **RecommendationModel** (Equatable)
  - Fields: recommendedCrop, reasoning, optimal conditions (temp/humidity/pH/waterLevel)
  - growthDaysEstimate, difficulty level, benefits, challenges
  - Full JSON serialization (toJson/fromJson)
  - Immutability with copyWith()

#### State Management
- **RecommendationController** (StateNotifier)
  - Manages primary recommendation and alternatives
  - Tracks compatibility scores for multiple crops
  - Error handling and state transitions
  - Riverpod integration with FutureProvider family patterns

## REST API Integration

### Base Configuration

```dart
Base URL: https://api.hydroai.example.com/v1
Timeout: 30 seconds
Content-Type: application/json
```

**⚠️ IMPORTANT**: Replace `https://api.hydroai.example.com/v1` with your actual AI service endpoint before deploying to production.

### API Endpoints

#### 1. Get Single Recommendation
```
POST /recommendations

Request Body:
{
  "currentTemperature": 25.5,      // °C
  "currentHumidity": 65.0,          // %
  "currentPh": 6.5,
  "farmSize": 50.0                  // m²
}

Response (200/201):
{
  "id": "rec_123abc",
  "recommendedCrop": "Tomato",
  "reasoning": "Perfect conditions for warm-season crops...",
  "optimalTemperature": 25.0,
  "optimalHumidity": 70.0,
  "optimalPh": 6.8,
  "optimalWaterLevel": 80.0,
  "growthDaysEstimate": 60.0,
  "difficulty": "medium",
  "benefits": ["High yield", "Market demand", "Long shelf life"],
  "challenges": ["Regular pruning needed", "Disease monitoring"],
  "timestamp": "2026-02-18T10:30:00Z"
}
```

#### 2. Get Multiple Recommendations
```
POST /recommendations/multiple

Request Body:
{
  "currentTemperature": 25.5,
  "currentHumidity": 65.0,
  "currentPh": 6.5,
  "farmSize": 50.0,
  "count": 3                        // Number of recommendations
}

Response (200/201):
[
  { /* RecommendationModel #1 */ },
  { /* RecommendationModel #2 */ },
  { /* RecommendationModel #3 */ }
]
```

#### 3. Evaluate Crop Compatibility
```
POST /recommendations/evaluate

Request Body:
{
  "cropName": "Lettuce",
  "currentTemperature": 25.5,
  "currentHumidity": 65.0,
  "currentPh": 6.5
}

Response (200/201):
{
  "compatibilityScore": 0.85        // 0-1 scale (85% compatible)
}
```

## Error Handling

### HTTP Status Codes
- **400**: Invalid request parameters → User-friendly message
- **401**: Authentication failed → Re-authentication required
- **403**: Access denied → Permission error
- **404**: Service not found → Contact support
- **429**: Rate limit exceeded → Retry with backoff
- **500**: Server error → Technical error message
- **503**: Service unavailable → Try again later

### Network Errors
- **Connection Timeout**: Check internet connection
- **Send Timeout**: Server not responding
- **Receive Timeout**: Server processing too slow
- **Bad Certificate**: SSL/TLS error
- **Unknown**: Generic network error

All errors are caught and converted to user-friendly messages via `_formatError()`.

## Usage Examples

### From UI Layer (RecommendationScreen)

```dart
// Fetch recommendations from current sensor data
ref.read(recommendationControllerProvider.notifier).fetchRecommendations(
  temperature: 25.5,
  humidity: 65.0,
  ph: 6.5,
  farmSize: 50.0,
  alternativeCount: 2,
);

// Watch recommendation state
final state = ref.watch(recommendationControllerProvider);

// Access results
if (state.primaryRecommendation != null) {
  print('Crop: ${state.primaryRecommendation!.recommendedCrop}');
  print('Difficulty: ${state.primaryRecommendation!.difficulty}');
}
```

### Using Riverpod Providers Directly

```dart
// Get single recommendation
final recommendation = await ref.read(
  getRecommendationProvider((25.5, 65.0, 6.5, 50.0)).future
);

// Get multiple recommendations
final recommendations = await ref.read(
  getMultipleRecommendationsProvider((25.5, 65.0, 6.5, 50.0, 3)).future
);

// Evaluate crop compatibility
final score = await ref.read(
  evaluateCropCompatibilityProvider(('Tomato', 25.5, 65.0, 6.5)).future
);
```

## Backend Implementation Requirements

Your AI service must implement the three endpoints with the following specifications:

### Algorithm Considerations
- Analyze temperature ranges (optimal ± 2-3°C tolerance)
- Evaluate humidity compatibility (optimal ± 10% tolerance)
- Check pH level suitability (optimal ± 0.5 tolerance)
- Consider farm size for scalability recommendations
- Generate reasoning explaining why crop suits conditions
- Include growth duration estimates
- Classify difficulty level: easy, medium, hard
- Provide at least 2-3 benefits and challenges per crop

### ML Integration Options
1. **Rule-based System**: Hard-coded compatibility rules per crop
2. **Regression Model**: ML model trained on historical crop data
3. **Ensemble Method**: Combine multiple classification models
4. **LLM-based**: Use Claude/GPT for intelligent recommendations

### Example Recommendation Logic

```python
# Pseudocode for backend algorithm
def recommend_crop(temp, humidity, ph, farm_size):
    crops = {
        'Tomato': {
            'optimal_temp': 25,
            'optimal_humidity': 70,
            'optimal_ph': 6.8,
            'growth_days': 60,
            'difficulty': 'medium'
        },
        'Lettuce': {
            'optimal_temp': 18,
            'optimal_humidity': 60,
            'optimal_ph': 6.5,
            'growth_days': 30,
            'difficulty': 'easy'
        }
        # ... more crops
    }
    
    # Calculate compatibility score for each crop
    scores = {}
    for crop, params in crops.items():
        score = calculate_compatibility(
            temp, params['optimal_temp'],
            humidity, params['optimal_humidity'],
            ph, params['optimal_ph']
        )
        scores[crop] = score
    
    # Return best match with reasoning
    best_crop = max(scores, key=scores.get)
    return build_recommendation(best_crop, scores)
```

## Security Considerations

1. **API Authentication**: Implement API key or OAuth2 for production
   ```dart
   // Add to Dio interceptors
   dio.interceptors.add(InterceptorsWrapper(
     onRequest: (options, handler) {
       options.headers['Authorization'] = 'Bearer $apiKey';
       return handler.next(options);
     },
   ));
   ```

2. **Input Validation**: All parameters validated before API call
   - Temperature: -50 to 50°C range
   - Humidity: 0-100%
   - pH: 0-14
   - Farm size: > 0 m²

3. **Rate Limiting**: Implement backoff for 429 responses
   ```dart
   // Already handled by error mapping in repository
   429 => 'Rate limit exceeded. Please try again later.'
   ```

4. **HTTPS Only**: Ensure API uses HTTPS in production
   ```dart
   // Validate certificate in production
   if (kReleaseMode) {
     // Certificate pinning can be added here
   }
   ```

## Testing

### Mock API for Development

```dart
// Override repository in tests
testWidgets('Recommendation screen shows crop', (tester) async {
  await tester.pumpWidget(
    ProviderContainer(
      overrides: [
        recommendationRepositoryProvider.overrideWithValue(
          MockRecommendationRepository(),
        ),
      ],
      child: const MyApp(),
    ).toWidget(),
  );
  
  expect(find.text('Tomato'), findsOneWidget);
});
```

### Sample Test Data

```dart
final mockRecommendation = RecommendationModel(
  id: 'test_1',
  recommendedCrop: 'Tomato',
  reasoning: 'Perfect temperature and humidity for warm-season crops',
  optimalTemperature: 25.0,
  optimalHumidity: 70.0,
  optimalPh: 6.8,
  optimalWaterLevel: 80.0,
  growthDaysEstimate: 60.0,
  difficulty: 'medium',
  benefits: ['High yield', 'Market demand'],
  challenges: ['Regular pruning', 'Disease monitoring'],
  timestamp: DateTime.now(),
);
```

## Future Enhancements

1. **Historical Recommendations**: Track recommendation history per farm
2. **Compatibility Scoring**: Show score percentage for each alternative crop
3. **Market Analysis**: Include crop price trends and demand
4. **Seasonal Recommendations**: Adjust based on current season
5. **Soil Analysis**: Integrate soil nutrient data into recommendations
6. **Weather Integration**: Factor in outdoor weather patterns
7. **Crop Rotation**: Suggest rotation strategies based on history
8. **Savings Calculator**: Estimate ROI and cost per kg of produce

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| "Service not found" | Verify API base URL is correct |
| Request timeout | Increase timeout or check server status |
| 401 Unauthorized | Verify API key/credentials |
| Invalid JSON response | Ensure API returns proper JSON format |
| No sensor data available | Use default values or prompt user |

### Debug Logging

Enable Dio logging in development:

```dart
// Automatically enabled in RecommendationRepositoryImpl
Dio _dio = Dio()..interceptors.add(
  LogInterceptor(
    request: true,
    requestBody: true,
    responseBody: true,
    error: true,
  ),
);
```

## Contact & Support

For API integration issues or to connect your custom AI backend:
- Check API response format matches RecommendationModel
- Verify all required fields are populated
- Test with empty/edge case values
- Enable debug logging to see full request/response
- Review error messages in SnackBar for guidance
