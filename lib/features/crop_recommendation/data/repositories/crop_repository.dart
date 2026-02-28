import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../models/crop.dart';
import '../../domain/models/crop_filters.dart';
import '../../../../core/config/api_config.dart';

class CropRepository {
  final Dio _dio = Dio();

  static const String _baseUrl = ApiConfig.API_BASE_URL;

  // Cache for crops data
  List<Crop>? _cachedCrops;

  /// ===============================
  /// FETCH ALL CROPS FROM BACKEND
  /// ===============================
  Future<List<Crop>> getAllCrops() async {
    // Return cached data if available
    if (_cachedCrops != null && _cachedCrops!.isNotEmpty) {
      return _cachedCrops!;
    }

    try {
      final response = await _dio.get(
        "$_baseUrl/crops",
        options: Options(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        _cachedCrops = data
            .map((e) => Crop.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return _cachedCrops!;
      } else {
        throw Exception("Failed to load crops");
      }
    } catch (e) {
      print("Error fetching crops from API: $e");
      print("Using fallback crop dataset from assets...");
      // Return asset data as fallback
      _cachedCrops = await _loadCropsFromAsset();
      return _cachedCrops!;
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

  /// ===============================
  /// LOAD CROP DATA FROM ASSET JSON
  /// ===============================
  Future<List<Crop>> _loadCropsFromAsset() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/crop_dataset.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) {
        final map = Map<String, dynamic>.from(e);
        // Add createdAt if not present
        map['createdAt'] ??= DateTime.now().toIso8601String();
        return Crop.fromJson(map);
      }).toList();
    } catch (e) {
      print("Error loading crop dataset from asset: $e");
      return [];
    }
  }
}
