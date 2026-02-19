# AI Backend Example - Flask Implementation

Quick-start example for implementing the AI recommendation API backend using Python Flask.

## Setup

```bash
pip install flask flask-cors python-dotenv
```

## Flask API Implementation

```python
from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
from typing import Dict, List, Tuple
import os

app = Flask(__name__)
CORS(app)

# Crop database with optimal conditions
CROP_DATABASE = {
    'Tomato': {
        'optimal_temp': 25,
        'optimal_humidity': 70,
        'optimal_ph': 6.8,
        'growth_days': 60,
        'difficulty': 'medium',
        'benefits': ['High yield', 'Market demand', 'Long shelf life'],
        'challenges': ['Regular pruning needed', 'Disease monitoring']
    },
    'Lettuce': {
        'optimal_temp': 18,
        'optimal_humidity': 60,
        'optimal_ph': 6.5,
        'growth_days': 30,
        'difficulty': 'easy',
        'benefits': ['Quick growth', 'Low maintenance', 'High profit margin'],
        'challenges': ['Pest sensitive', 'Frequent harvesting needed']
    },
    'Cucumber': {
        'optimal_temp': 24,
        'optimal_humidity': 65,
        'optimal_ph': 6.8,
        'growth_days': 45,
        'difficulty': 'medium',
        'benefits': ['High water content', 'Easy to grow', 'Good yield'],
        'challenges': ['Support structure needed', 'Pollination required']
    },
    'Spinach': {
        'optimal_temp': 15,
        'optimal_humidity': 50,
        'optimal_ph': 6.8,
        'growth_days': 35,
        'difficulty': 'easy',
        'benefits': ['Nutritious', 'Cold hardy', 'Quick growth'],
        'challenges': ['Bolting in heat', 'Limited shelf life']
    },
    'Basil': {
        'optimal_temp': 22,
        'optimal_humidity': 55,
        'optimal_ph': 6.5,
        'growth_days': 40,
        'difficulty': 'easy',
        'benefits': ['Aromatic', 'High value', 'Continuous harvest'],
        'challenges': ['Sensitive to cold', 'Requires pruning']
    },
    'Peppers': {
        'optimal_temp': 26,
        'optimal_humidity': 60,
        'optimal_ph': 6.8,
        'growth_days': 90,
        'difficulty': 'hard',
        'benefits': ['Premium price', 'Multiple colors', 'Long season'],
        'challenges': ['Long growth time', 'Temperature sensitive']
    },
}

def calculate_compatibility_score(
    current_value: float,
    optimal_value: float,
    tolerance: float
) -> float:
    """Calculate compatibility score 0-1 based on difference from optimal."""
    diff = abs(current_value - optimal_value)
    if diff <= tolerance:
        return 1.0
    else:
        # Decrease score linearly outside tolerance
        return max(0.0, 1.0 - (diff - tolerance) / (tolerance * 2))

def recommend_crop(
    temperature: float,
    humidity: float,
    ph: float,
    farm_size: float
) -> Tuple[str, float]:
    """
    Recommend best crop based on current conditions.
    Returns (crop_name, compatibility_score)
    """
    scores = {}
    
    for crop_name, params in CROP_DATABASE.items():
        # Calculate compatibility for each parameter
        temp_score = calculate_compatibility_score(
            temperature, params['optimal_temp'], tolerance=3
        )
        humidity_score = calculate_compatibility_score(
            humidity, params['optimal_humidity'], tolerance=15
        )
        ph_score = calculate_compatibility_score(
            ph, params['optimal_ph'], tolerance=0.5
        )
        
        # Weighted average (temperature most important)
        overall_score = (temp_score * 0.5 + humidity_score * 0.3 + ph_score * 0.2)
        scores[crop_name] = overall_score
    
    # Get highest scoring crop
    best_crop = max(scores, key=scores.get)
    return best_crop, scores[best_crop]

def generate_reasoning(crop: str, current_cond: dict, optimal_cond: dict) -> str:
    """Generate human-readable reasoning for recommendation."""
    temp_advice = f"Temperature of {current_cond['temp']}°C is close to optimal {optimal_cond['optimal_temp']}°C"
    humidity_advice = f"Humidity of {current_cond['humidity']}% is within the ideal range"
    ph_advice = f"pH level of {current_cond['ph']} is suitable for this crop"
    
    return f"{crop} is recommended because: {temp_advice}. {humidity_advice}. {ph_advice}."

@app.route('/v1/recommendations', methods=['POST'])
def get_recommendation():
    """Get single AI crop recommendation."""
    try:
        data = request.get_json()
        
        # Validate input
        required_fields = ['currentTemperature', 'currentHumidity', 'currentPh', 'farmSize']
        if not all(field in data for field in required_fields):
            return jsonify({'message': 'Missing required fields'}), 400
        
        temp = float(data['currentTemperature'])
        humidity = float(data['currentHumidity'])
        ph = float(data['currentPh'])
        farm_size = float(data['farmSize'])
        
        # Validate ranges
        if not (-50 <= temp <= 50):
            return jsonify({'message': 'Temperature out of valid range'}), 400
        if not (0 <= humidity <= 100):
            return jsonify({'message': 'Humidity out of valid range'}), 400
        if not (0 <= ph <= 14):
            return jsonify({'message': 'pH out of valid range'}), 400
        if farm_size <= 0:
            return jsonify({'message': 'Farm size must be positive'}), 400
        
        # Get recommendation
        best_crop, score = recommend_crop(temp, humidity, ph, farm_size)
        crop_params = CROP_DATABASE[best_crop]
        
        # Build response
        response = {
            'id': f'rec_{datetime.now().timestamp()}',
            'recommendedCrop': best_crop,
            'reasoning': generate_reasoning(
                best_crop,
                {'temp': temp, 'humidity': humidity, 'ph': ph},
                crop_params
            ),
            'optimalTemperature': crop_params['optimal_temp'],
            'optimalHumidity': crop_params['optimal_humidity'],
            'optimalPh': crop_params['optimal_ph'],
            'optimalWaterLevel': 75.0,  # Default value
            'growthDaysEstimate': float(crop_params['growth_days']),
            'difficulty': crop_params['difficulty'],
            'benefits': crop_params['benefits'],
            'challenges': crop_params['challenges'],
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'compatibilityScore': score
        }
        
        return jsonify(response), 200
        
    except ValueError as e:
        return jsonify({'message': f'Invalid parameter format: {str(e)}'}), 400
    except Exception as e:
        return jsonify({'message': f'Server error: {str(e)}'}), 500

@app.route('/v1/recommendations/multiple', methods=['POST'])
def get_multiple_recommendations():
    """Get multiple crop recommendations."""
    try:
        data = request.get_json()
        
        required_fields = ['currentTemperature', 'currentHumidity', 'currentPh', 'farmSize', 'count']
        if not all(field in data for field in required_fields):
            return jsonify({'message': 'Missing required fields'}), 400
        
        temp = float(data['currentTemperature'])
        humidity = float(data['currentHumidity'])
        ph = float(data['currentPh'])
        farm_size = float(data['farmSize'])
        count = int(data['count'])
        
        if count < 1 or count > 10:
            return jsonify({'message': 'Count must be between 1 and 10'}), 400
        
        # Calculate scores for all crops
        scores = {}
        for crop_name, params in CROP_DATABASE.items():
            temp_score = calculate_compatibility_score(temp, params['optimal_temp'], 3)
            humidity_score = calculate_compatibility_score(humidity, params['optimal_humidity'], 15)
            ph_score = calculate_compatibility_score(ph, params['optimal_ph'], 0.5)
            
            overall_score = (temp_score * 0.5 + humidity_score * 0.3 + ph_score * 0.2)
            scores[crop_name] = overall_score
        
        # Get top N crops
        top_crops = sorted(scores.items(), key=lambda x: x[1], reverse=True)[:count]
        
        recommendations = []
        for crop_name, score in top_crops:
            params = CROP_DATABASE[crop_name]
            rec = {
                'id': f'rec_{datetime.now().timestamp()}_{crop_name}',
                'recommendedCrop': crop_name,
                'reasoning': f'{crop_name} is a good option for your farm conditions.',
                'optimalTemperature': params['optimal_temp'],
                'optimalHumidity': params['optimal_humidity'],
                'optimalPh': params['optimal_ph'],
                'optimalWaterLevel': 75.0,
                'growthDaysEstimate': float(params['growth_days']),
                'difficulty': params['difficulty'],
                'benefits': params['benefits'],
                'challenges': params['challenges'],
                'timestamp': datetime.utcnow().isoformat() + 'Z',
                'compatibilityScore': score
            }
            recommendations.append(rec)
        
        return jsonify(recommendations), 200
        
    except Exception as e:
        return jsonify({'message': f'Server error: {str(e)}'}), 500

@app.route('/v1/recommendations/evaluate', methods=['POST'])
def evaluate_compatibility():
    """Evaluate compatibility score for specific crop."""
    try:
        data = request.get_json()
        
        required_fields = ['cropName', 'currentTemperature', 'currentHumidity', 'currentPh']
        if not all(field in data for field in required_fields):
            return jsonify({'message': 'Missing required fields'}), 400
        
        crop_name = data['cropName']
        temp = float(data['currentTemperature'])
        humidity = float(data['currentHumidity'])
        ph = float(data['currentPh'])
        
        if crop_name not in CROP_DATABASE:
            return jsonify({'message': f'Crop {crop_name} not found'}), 404
        
        params = CROP_DATABASE[crop_name]
        
        # Calculate score
        temp_score = calculate_compatibility_score(temp, params['optimal_temp'], 3)
        humidity_score = calculate_compatibility_score(humidity, params['optimal_humidity'], 15)
        ph_score = calculate_compatibility_score(ph, params['optimal_ph'], 0.5)
        
        overall_score = (temp_score * 0.5 + humidity_score * 0.3 + ph_score * 0.2)
        
        return jsonify({'compatibilityScore': overall_score}), 200
        
    except Exception as e:
        return jsonify({'message': f'Server error: {str(e)}'}), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()}), 200

if __name__ == '__main__':
    # For development only - use production WSGI server (gunicorn) in production
    app.run(debug=True, host='0.0.0.0', port=5000)
```

## Deployment

### Using Gunicorn (Production)

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### Using Docker

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
```

### Using Docker Compose

```yaml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=production
```

## Configuration

Update `lib/data/repositories/recommendation_repository_impl.dart`:

```dart
// Change base URL to your deployed API
static const String _baseUrl = 'https://your-api-domain.com/v1';

// Or use environment variables
static const String _baseUrl = String.fromEnvironment(
  'AI_API_URL',
  defaultValue: 'https://api.hydroai.example.com/v1',
);
```

## Testing the API

```bash
# Test single recommendation
curl -X POST http://localhost:5000/v1/recommendations \
  -H "Content-Type: application/json" \
  -d '{
    "currentTemperature": 25.5,
    "currentHumidity": 65.0,
    "currentPh": 6.5,
    "farmSize": 50.0
  }'

# Test multiple recommendations
curl -X POST http://localhost:5000/v1/recommendations/multiple \
  -H "Content-Type: application/json" \
  -d '{
    "currentTemperature": 25.5,
    "currentHumidity": 65.0,
    "currentPh": 6.5,
    "farmSize": 50.0,
    "count": 3
  }'

# Test compatibility evaluation
curl -X POST http://localhost:5000/v1/recommendations/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "cropName": "Tomato",
    "currentTemperature": 25.5,
    "currentHumidity": 65.0,
    "currentPh": 6.5
  }'
```

## Next Steps

1. Add authentication (API key or JWT)
2. Implement database to store recommendations
3. Add machine learning model for smarter recommendations
4. Implement caching for frequent queries
5. Add rate limiting and request throttling
6. Deploy to cloud (AWS Lambda, Google Cloud, Azure, etc.)
