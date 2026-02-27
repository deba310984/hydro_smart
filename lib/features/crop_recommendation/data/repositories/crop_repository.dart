import 'package:dio/dio.dart';
import '../models/crop.dart';
import '../../domain/models/crop_filters.dart';
import '../../../../core/config/api_config.dart';

class CropRepository {
  final Dio _dio = Dio();

  static const String _baseUrl = ApiConfig.API_BASE_URL;

  /// ===============================
  /// FETCH ALL CROPS FROM BACKEND
  /// ===============================
  Future<List<Crop>> getAllCrops() async {
    try {
      final response = await _dio.get("$_baseUrl/crops");

      if (response.statusCode == 200) {
        final List data = response.data;

        return data
            .map((e) => Crop.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        throw Exception("Failed to load crops");
      }
    } catch (e) {
      print("Error fetching crops: $e");
      rethrow;
    }
  }

  /// ===============================
  /// FILTER CROPS (CLIENT SIDE)
  /// ===============================
  Future<List<Crop>> filterCrops(CropFilters filters) async {
    final crops = await getAllCrops();

    var filtered = crops;

    // Hydroponic technique
    if (filters.hydroponicTechniques != null &&
        filters.hydroponicTechniques!.isNotEmpty) {
      filtered = filtered.where((crop) {
        final compatible = crop.getCompatibleTechniques();
        return filters.hydroponicTechniques!
            .any((tech) => compatible.contains(tech));
      }).toList();
    }

    // Season
    if (filters.growingSeasons != null && filters.growingSeasons!.isNotEmpty) {
      filtered = filtered.where((crop) {
        return filters.growingSeasons!.contains(crop.bestSeason) ||
            crop.bestSeason == 'year-round';
      }).toList();
    }

    // Growth duration
    if (filters.growthDurationRange != null) {
      filtered = filtered.where((crop) {
        return crop.seedToHarvestDays >= filters.growthDurationRange!.start &&
            crop.seedToHarvestDays <= filters.growthDurationRange!.end;
      }).toList();
    }

    // Profit margin
    if (filters.profitMarginRange != null) {
      filtered = filtered.where((crop) {
        return crop.profitMargin >= filters.profitMarginRange!.start &&
            crop.profitMargin <= filters.profitMarginRange!.end;
      }).toList();
    }

    // Difficulty
    if (filters.difficultyLevel != null) {
      filtered = filtered
          .where((crop) => crop.difficultyLevel == filters.difficultyLevel)
          .toList();
    }

    // Market demand
    if (filters.marketDemandLevel != null) {
      filtered = filtered
          .where((crop) => crop.marketDemandLevel == filters.marketDemandLevel)
          .toList();
    }

    return filtered;
  }

  /// ===============================
  /// GET CROP BY ID
  /// ===============================
  Future<Crop?> getCropById(String cropId) async {
    final crops = await getAllCrops();

    try {
      return crops.firstWhere((crop) => crop.id == cropId);
    } catch (e) {
      return null;
    }
  }

  /// ===============================
  /// SEARCH CROPS
  /// ===============================
  Future<List<Crop>> searchCrops(String query) async {
    final crops = await getAllCrops();
    final lowerQuery = query.toLowerCase();

    return crops.where((crop) {
      return crop.cropName.toLowerCase().contains(lowerQuery) ||
          crop.commonNames
              .any((name) => name.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// ===============================
  /// UPLOAD RESEARCH PDF
  /// ===============================
  Future<int> uploadCropPdf(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath),
      });

      final response =
          await _dio.post("$_baseUrl/upload-crop-pdf", data: formData);

      if (response.statusCode == 200) {
        return response.data["saved_crops"] ?? 0;
      } else {
        throw Exception("Failed to upload PDF");
      }
    } catch (e) {
      print("Error uploading PDF: $e");
      rethrow;
    }
  }
}
