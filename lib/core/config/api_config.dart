/// API Configuration for Hydro Smart Backend
///
/// Update the API_BASE_URL when deploying to a new backend service
/// Current deployment: Google Cloud Run

class ApiConfig {
  // ========== BACKEND CONFIGURATION ==========
  // Change this URL when you deploy to Cloud Run
  // Format: https://your-service-name-xxxxx.run.app

  static const String API_BASE_URL =
      'https://hydro-smart-d6bimqbnv86c73af8ci0.onrender.com/api/v1';

  // Fallback for local development
  static const String LOCAL_API_URL = 'http://localhost:5000/api/v1';

  // ========== API ENDPOINTS ==========
  static String get uploadCropPdf => '$API_BASE_URL/upload-crop-pdf';
  static String get getAllCrops => '$API_BASE_URL/crops';

  // ========== DEPLOYMENT CHECKLIST ==========
  /*
   * 1. Deploy Flask backend to Cloud Run:
   *    - Run: gcloud run deploy hydro-smart-backend --source . --platform managed
   *    - Copy the URL from the output
   *
   * 2. Update API_BASE_URL:
   *    - Replace 'xxxxx' with your actual Cloud Run URL
   *    - Example: https://hydro-smart-backend-abc123.run.app/api/v1
   *
   * 3. Rebuild Flutter app:
   *    - Run: flutter clean
   *    - Run: flutter pub get
   *    - Run: flutter run
   *
   * 4. Test from any device (PC can be off):
   *    - App should now work globally via Cloud Run
   *    - No localhost dependency!
   */
}
