import 'package:image_picker/image_picker.dart';

abstract class DiseaseDetectionRepository {
  /// Initialize the TFLite model
  Future<void> loadModel();

  /// Run inference on an image file
  /// Returns a map of label -> confidence score
  Future<List<Map<String, dynamic>>> detectDisease(XFile imageFile);

  /// Dispose resources
  Future<void> dispose();
}
