from flask import Flask, request, jsonify
import os

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'version': '1.0.0'}), 200

@app.route('/api/v1/recommendations', methods=['POST'])
def get_recommendation():
    data = request.get_json()
    
    # Extract parameters
    temp = data.get('currentTemperature')
    humidity = data.get('currentHumidity')
    ph = data.get('currentPh')
    
    # Simple logic (Mock-like but real availability)
    if temp and temp > 20:
        recommended_crop = 'Tomato'
        reasoning = 'Warm conditions suitable for fruiting crops.'
    else:
        recommended_crop = 'Lettuce'
        reasoning = 'Cooler conditions suitable for leafy greens.'
        
    return jsonify({
        'id': 'rec_123',
        'recommendedCrop': recommended_crop,
        'reasoning': reasoning,
        'optimalTemperature': 22.0,
        'optimalHumidity': 60.0,
        'optimalPh': 6.5,
        'optimalWaterLevel': 80.0,
        'growthDaysEstimate': 45.0,
        'difficulty': 'Medium',
        'benefits': ['High yield'],
        'challenges': ['Pests'],
        'timestamp': '2023-10-27T10:00:00Z'
    }), 200

@app.route('/api/v1/recommendations/multiple', methods=['POST'])
def get_multiple_recommendations():
    return jsonify([
        {
            'id': 'rec_1',
            'recommendedCrop': 'Tomato',
            'reasoning': 'Optimal for current temp.',
            'timestamp': '2023-10-27T10:00:00Z'
        },
        {
            'id': 'rec_2',
            'recommendedCrop': 'Peppers',
            'reasoning': 'Good alternative.',
            'timestamp': '2023-10-27T10:00:00Z'
        }
    ]), 200

@app.route('/api/v1/recommendations/evaluate', methods=['POST'])
def evaluate_compatibility():
    return jsonify({'compatibilityScore': 0.85}), 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
