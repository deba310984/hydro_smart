from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from datetime import datetime
from pdf_extractor import CropDataExtractor
from database import FirestoreDB
from crop_database import recommendation_engine, HYDROPONIC_CROPS, INDIAN_CLIMATE_ZONES, STATE_CLIMATE_MAP

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

extractor = CropDataExtractor()
db = FirestoreDB()

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/health")
def health():
    return {"status": "healthy", "crops_in_database": len(HYDROPONIC_CROPS)}

# ==================== RECOMMENDATION ENDPOINTS ====================

@app.route("/api/v1/recommendations", methods=["POST"])
def get_recommendation():
    """
    Get single best crop recommendation based on conditions
    
    Request body:
    {
        "currentTemperature": 25.0,
        "currentHumidity": 60.0,
        "currentPh": 6.0,
        "farmSize": 100.0,
        "state": "Karnataka",  // optional
        "month": 2  // optional, defaults to current month
    }
    """
    try:
        data = request.get_json()
        
        temperature = data.get("currentTemperature", 25.0)
        humidity = data.get("currentHumidity", 60.0)
        ph = data.get("currentPh", 6.0)
        state = data.get("state")
        month = data.get("month")
        
        recommendations = recommendation_engine.get_recommendations(
            temperature=temperature,
            humidity=humidity,
            ph=ph,
            state=state,
            month=month,
            count=1
        )
        
        if recommendations:
            crop = recommendations[0]
            return jsonify({
                "recommendedCrop": crop["name"],
                "cropEmoji": crop["emoji"],
                "scientificName": crop["scientific_name"],
                "description": crop["description"],
                "compatibilityScore": crop["compatibility_score"],
                "difficultyLevel": crop["difficulty_level"],
                "daysToHarvest": crop["days_to_harvest"],
                "yieldPerSqm": crop["yield_per_sqm"],
                "profitMargin": crop["profit_margin"],
                "waterConsumption": crop["water_consumption"],
                "marketDemand": crop["market_demand"],
                "temperatureRange": crop["temperature_range"],
                "humidityRange": crop["humidity_range"],
                "phRange": crop["ph_range"],
                "ecRange": crop["ec_range"],
                "lightHours": crop["light_hours"],
                "bestHydroponicSystems": crop["best_hydroponic_systems"],
                "nutrientRequirements": crop["nutrient_requirements"],
                "growingSeasons": crop["growing_seasons"],
                "commonPests": crop["common_pests"],
                "commonDiseases": crop["common_diseases"],
                "companionCrops": crop["companion_crops"],
                "storageDays": crop["storage_days"],
                "nutritionalHighlights": crop["nutritional_highlights"],
                "tips": crop["tips"],
            })
        else:
            return jsonify({"error": "No recommendations available"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/v1/recommendations/multiple", methods=["POST"])
def get_multiple_recommendations():
    """
    Get multiple crop recommendations sorted by compatibility
    
    Request body:
    {
        "currentTemperature": 25.0,
        "currentHumidity": 60.0,
        "currentPh": 6.0,
        "farmSize": 100.0,
        "state": "Karnataka",
        "month": 2,
        "category": "leafy_greens",  // optional filter
        "difficulty": "beginner",  // optional filter
        "count": 10
    }
    """
    try:
        data = request.get_json()
        
        temperature = data.get("currentTemperature", 25.0)
        humidity = data.get("currentHumidity", 60.0)
        ph = data.get("currentPh", 6.0)
        state = data.get("state")
        month = data.get("month")
        category = data.get("category")
        difficulty = data.get("difficulty")
        count = data.get("count", 10)
        
        recommendations = recommendation_engine.get_recommendations(
            temperature=temperature,
            humidity=humidity,
            ph=ph,
            state=state,
            month=month,
            category=category,
            difficulty=difficulty,
            count=count
        )
        
        # Format for Flutter
        result = []
        for crop in recommendations:
            result.append({
                "id": crop["id"],
                "recommendedCrop": crop["name"],
                "cropEmoji": crop["emoji"],
                "category": crop["category"],
                "scientificName": crop["scientific_name"],
                "description": crop["description"],
                "compatibilityScore": crop["compatibility_score"],
                "difficultyLevel": crop["difficulty_level"],
                "daysToHarvest": crop["days_to_harvest"],
                "yieldPerSqm": crop["yield_per_sqm"],
                "profitMargin": crop["profit_margin"],
                "waterConsumption": crop["water_consumption"],
                "marketDemand": crop["market_demand"],
                "temperatureRange": crop["temperature_range"],
                "humidityRange": crop["humidity_range"],
                "phRange": crop["ph_range"],
                "ecRange": crop["ec_range"],
                "lightHours": crop["light_hours"],
                "bestHydroponicSystems": crop["best_hydroponic_systems"],
                "nutrientRequirements": crop["nutrient_requirements"],
                "growingSeasons": crop["growing_seasons"],
                "commonPests": crop["common_pests"],
                "commonDiseases": crop["common_diseases"],
                "companionCrops": crop["companion_crops"],
                "storageDays": crop["storage_days"],
                "nutritionalHighlights": crop["nutritional_highlights"],
                "tips": crop["tips"],
            })
        
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/v1/recommendations/evaluate", methods=["POST"])
def evaluate_crop():
    """
    Evaluate compatibility of a specific crop with current conditions
    
    Request body:
    {
        "cropName": "tomato_cherry",
        "currentTemperature": 25.0,
        "currentHumidity": 60.0,
        "currentPh": 6.0
    }
    """
    try:
        data = request.get_json()
        
        crop_name = data.get("cropName", "")
        temperature = data.get("currentTemperature", 25.0)
        humidity = data.get("currentHumidity", 60.0)
        ph = data.get("currentPh", 6.0)
        
        # Find crop by name or id
        crop_data = None
        crop_id = None
        
        for cid, cdata in HYDROPONIC_CROPS.items():
            if cid == crop_name or cdata.get("name", "").lower() == crop_name.lower():
                crop_data = cdata
                crop_id = cid
                break
        
        if not crop_data:
            return jsonify({"error": f"Crop '{crop_name}' not found"}), 404
        
        score = recommendation_engine.calculate_crop_score(
            crop_data,
            temperature,
            humidity,
            ph
        )
        
        return jsonify({
            "cropName": crop_data.get("name"),
            "cropId": crop_id,
            "compatibilityScore": round(score, 1),
            "isRecommended": score >= 60,
            "temperatureRange": crop_data.get("temperature_range"),
            "humidityRange": crop_data.get("humidity_range"),
            "phRange": crop_data.get("ph_range"),
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/v1/recommendations/seasonal", methods=["POST"])
def get_seasonal_recommendations():
    """
    Get seasonal recommendations for a specific state
    
    Request body:
    {
        "state": "Karnataka",
        "month": 2  // optional
    }
    """
    try:
        data = request.get_json()
        state = data.get("state", "Karnataka")
        month = data.get("month")
        
        result = recommendation_engine.get_seasonal_recommendations(state, month)
        
        # Format recommendations for Flutter
        formatted_recommendations = []
        for crop in result["recommendations"]:
            formatted_recommendations.append({
                "id": crop["id"],
                "recommendedCrop": crop["name"],
                "cropEmoji": crop["emoji"],
                "category": crop["category"],
                "compatibilityScore": crop["compatibility_score"],
                "difficultyLevel": crop["difficulty_level"],
                "daysToHarvest": crop["days_to_harvest"],
                "marketDemand": crop["market_demand"],
            })
        
        return jsonify({
            "state": result["state"],
            "season": result["season"],
            "climateZone": result["climate_zone"],
            "estimatedTemperature": result["estimated_temperature"],
            "recommendations": formatted_recommendations
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ==================== CROP DATABASE ENDPOINTS ====================

@app.route("/api/v1/crops")
def get_crops():
    """Get all crops from the database"""
    try:
        all_crops = recommendation_engine.get_all_crops()
        return jsonify(all_crops)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/v1/crops/<crop_id>")
def get_crop_details(crop_id):
    """Get details of a specific crop"""
    try:
        crop = recommendation_engine.get_crop_details(crop_id)
        if crop:
            return jsonify(crop)
        else:
            return jsonify({"error": "Crop not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/v1/crops/category/<category>")
def get_crops_by_category(category):
    """Get crops by category"""
    try:
        crops = recommendation_engine.get_crops_by_category(category)
        return jsonify(crops)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/v1/categories")
def get_categories():
    """Get all crop categories"""
    try:
        categories = recommendation_engine.get_categories()
        return jsonify(categories)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/v1/climate-zones")
def get_climate_zones():
    """Get Indian climate zones"""
    return jsonify(INDIAN_CLIMATE_ZONES)


@app.route("/api/v1/states")
def get_states():
    """Get Indian states with their climate zones"""
    return jsonify(STATE_CLIMATE_MAP)


# ==================== PDF UPLOAD (existing) ====================

@app.route("/api/v1/upload-crop-pdf", methods=["POST"])
def upload_pdf():
    file = request.files["file"]
    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    result = extractor.extract_from_pdf(filepath)

    for crop in result["crops"]:
        db.save_crop(crop)

    os.remove(filepath)

    return jsonify({
        "saved_crops": len(result["crops"])
    })


# ==================== APP UPDATE ENDPOINTS ====================

# Current app version configuration
CURRENT_APP_VERSION = {
    "version": "1.0.0",
    "buildNumber": 1,
    "downloadUrl": "https://github.com/YOUR_USERNAME/hydro_smart/releases/download/v1.0.0/app-release.apk",
    "releaseDate": "2026-02-25T00:00:00Z",
    "releaseNotes": "Initial release of HydroSmart app with AI-powered crop recommendations.",
    "isForced": False,
    "minSupportedVersion": "1.0.0"
}

@app.route("/api/app/version", methods=["GET"])
def check_app_version():
    """Check if app update is available"""
    try:
        current_version = request.args.get("current_version", "1.0.0")
        current_build = int(request.args.get("build_number", "1"))
        platform = request.args.get("platform", "android")
        
        # Compare versions
        latest_build = CURRENT_APP_VERSION["buildNumber"]
        is_update_available = latest_build > current_build
        
        response = {
            "updateAvailable": is_update_available,
            "currentVersion": current_version,
            "latestVersion": CURRENT_APP_VERSION["version"],
            "buildNumber": latest_build,
            "downloadUrl": CURRENT_APP_VERSION["downloadUrl"],
            "releaseDate": CURRENT_APP_VERSION["releaseDate"],
            "releaseNotes": CURRENT_APP_VERSION["releaseNotes"],
            "isForced": CURRENT_APP_VERSION["isForced"],
            "minSupportedVersion": CURRENT_APP_VERSION["minSupportedVersion"]
        }
        
        return jsonify(response)
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/app/config", methods=["GET"])
def get_app_config():
    """Get app configuration"""
    config = {
        "checkInterval": 24,  # hours
        "minVersionSupported": CURRENT_APP_VERSION["minSupportedVersion"],
        "updateServerUrl": request.url_root + "api/app/version",
        "forceUpdateVersion": None,
        "updateMessage": {
            "title": "Update Available",
            "description": "A new version of HydroSmart is available with improvements and bug fixes."
        },
        "maintenanceMode": {
            "enabled": False,
            "message": "HydroSmart is under maintenance. Please check back later."
        }
    }
    return jsonify(config)

@app.route("/api/app/update-status", methods=["POST"])
def report_update_status():
    """Report app update installation status"""
    try:
        data = request.get_json()
        version = data.get("version")
        status = data.get("status")
        timestamp = data.get("timestamp")
        
        # Log update status (you can save to database if needed)
        print(f"Update status: {version} - {status} at {timestamp}")
        
        return jsonify({"success": True})
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/app/download", methods=["GET"])
def download_app():
    """Redirect to latest APK download"""
    return jsonify({
        "downloadUrl": CURRENT_APP_VERSION["downloadUrl"],
        "version": CURRENT_APP_VERSION["version"],
        "fileSize": "25MB"  # Update with actual file size
    })


if __name__ == "__main__":
    print("=" * 50)
    print("🌱 Hydro Smart Crop Recommendation API")
    print(f"📊 {len(HYDROPONIC_CROPS)} crops in database")
    print(f"🗺️  {len(STATE_CLIMATE_MAP)} Indian states mapped")
    print(f"📱 App Update System: v{CURRENT_APP_VERSION['version']}")
    print("=" * 50)
    app.run(host="0.0.0.0", port=5000, debug=True)
