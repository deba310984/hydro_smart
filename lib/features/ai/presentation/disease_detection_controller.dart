import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hydro_smart/data/repositories/disease_detection_repository_impl.dart';
import 'package:hydro_smart/domain/repositories/disease_detection_repository.dart';

/// Provider for the repository
final diseaseDetectionRepositoryProvider = Provider<DiseaseDetectionRepository>((ref) {
  return DiseaseDetectionRepositoryImpl();
});

/// State for detection flow
class DiseaseDetectionState {
  final bool isLoading;
  final XFile? selectedImage;
  final List<Map<String, dynamic>>? results;
  final String? error;

  DiseaseDetectionState({
    this.isLoading = false,
    this.selectedImage,
    this.results,
    this.error,
  });

  DiseaseDetectionState copyWith({
    bool? isLoading,
    XFile? selectedImage,
    List<Map<String, dynamic>>? results,
    String? error,
  }) {
    return DiseaseDetectionState(
      isLoading: isLoading ?? this.isLoading,
      selectedImage: selectedImage ?? this.selectedImage,
      results: results ?? this.results,
      error: error,
    );
  }
}

/// Controller
class DiseaseDetectionController extends StateNotifier<DiseaseDetectionState> {
  final DiseaseDetectionRepository _repository;

  DiseaseDetectionController(this._repository) : super(DiseaseDetectionState());

  void selectImage(XFile image) {
    state = state.copyWith(selectedImage: image, results: null, error: null);
  }

  Future<void> analyzeImage() async {
    if (state.selectedImage == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Initialize model if needed (lazy load)
      await _repository.loadModel();
      
      final results = await _repository.detectDisease(state.selectedImage!);
      
      state = state.copyWith(isLoading: false, results: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = DiseaseDetectionState();
  }
}

final diseaseDetectionControllerProvider =
    StateNotifierProvider<DiseaseDetectionController, DiseaseDetectionState>((ref) {
  final repository = ref.watch(diseaseDetectionRepositoryProvider);
  return DiseaseDetectionController(repository);
});
