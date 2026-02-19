# Flutter Crop Panel - Import Reference & File Structure

## 📂 Exact File Structure Created

```
lib/
└── features/
    └── crop_recommendation/
        ├── data/
        │   ├── models/
        │   │   └── crop.dart
        │   │       └── class Crop { ... }
        │   │
        │   └── repositories/
        │       └── crop_repository.dart
        │           ├── class CropRepository { ... }
        │           └── static _mockCrops = [6 crops...]
        │
        ├── domain/
        │   └── models/
        │       └── crop_filters.dart
        │           └── class CropFilters { ... }
        │
        └── presentation/
            ├── pages/
            │   └── crop_recommendation_page.dart
            │       └── class CropRecommendationPage extends StatefulWidget { ... }
            │
            └── widgets/
                ├── crop_card.dart
                │   └── class CropCard extends StatelessWidget { ... }
                │
                └── crop_filter_panel.dart
                    ├── class CropFilterPanel extends StatefulWidget { ... }
                    └── extension StringExtension { ... }
```

---

## 📥 Import Statements (Copy & Paste)

### Main Page Import
```dart
import 'package:hydro_smart/features/crop_recommendation/presentation/pages/crop_recommendation_page.dart';
```

### For Custom Navigation
```dart
import 'package:hydro_smart/features/crop_recommendation/data/models/crop.dart';
import 'package:hydro_smart/features/crop_recommendation/data/repositories/crop_repository.dart';
import 'package:hydro_smart/features/crop_recommendation/domain/models/crop_filters.dart';
import 'package:hydro_smart/features/crop_recommendation/presentation/pages/crop_recommendation_page.dart';
import 'package:hydro_smart/features/crop_recommendation/presentation/widgets/crop_card.dart';
import 'package:hydro_smart/features/crop_recommendation/presentation/widgets/crop_filter_panel.dart';
```

---

## 📊 What Each File Contains

### 1. `crop.dart` (200+ lines)

**Exports:**
```dart
class Crop {
  // Properties (20+)
  - id: String
  - cropName: String
  - imageUrl: String
  - phRange: Map
  - temperatureRange: Map
  - seedToHarvestDays: int
  - yieldPerSqm: double
  - hydroponicTechniques: Map
  - bestSeason: String
  - marketDemandLevel: String
  - profitMargin: double
  - difficultyLevel: String
  - ... and more
  
  // Methods
  - getCompatibleTechniques(): List<String>
  - getPhRangeString(): String
  - getTemperatureRangeString(): String
  - toJson(): Map
  - fromJson(Map): Crop (factory)
}
```

---

### 2. `crop_filters.dart` (60 lines)

**Exports:**
```dart
class CropFilters {
  // Properties
  - hydroponicTechniques: List<String>?
  - growingSeasons: List<String>?
  - growthDurationRange: RangeValues?
  - profitMarginRange: RangeValues?
  - difficultyLevel: String?
  - marketDemandLevel: String?
  
  // Methods
  - hasActiveFilters(): bool
  - copyWith(...): CropFilters
  - clear(): void
  - toString(): String
}
```

---

### 3. `crop_repository.dart` (300+ lines)

**Exports:**
```dart
class CropRepository {
  // Static Mock Data
  - _mockCrops: List<Crop> (6 complete crops)
  
  // Methods
  - getAllCrops(): Future<List<Crop>>
  - filterCrops(filters: CropFilters): Future<List<Crop>>
  - getCropById(id: String): Future<Crop?>
  - searchCrops(query: String): Future<List<Crop>>
  
  // Filtering Logic
  - Technique filtering (multi-select)
  - Season filtering (multi-select + year-round)
  - Duration range filtering
  - Margin range filtering
  - Difficulty filtering (single)
  - Market demand filtering (single)
}
```

**Mock Crops:**
1. Cherry Tomato
2. Butterhead Lettuce
3. Spinach
4. Cucumber
5. Sweet Basil
6. Bell Pepper

---

### 4. `crop_recommendation_page.dart` (250+ lines)

**Exports:**
```dart
class CropRecommendationPage extends StatefulWidget
class _CropRecommendationPageState extends State<CropRecommendationPage> {
  // State
  - allCrops: List<Crop>
  - filteredCrops: List<Crop>
  - currentFilters: CropFilters
  - isLoading: bool
  - errorMessage: String?
  
  // Callbacks
  - _loadCrops()
  - _applyFilters(CropFilters)
  - _clearFilters()
  - _showFilterPanel()
  - _showCropDetails(Crop)
  
  // UI Methods
  - _buildCropsList()
  - _buildCropDetailsContent(Crop)
  - _detailRow(label, value)
}
```

---

### 5. `crop_card.dart` (350+ lines)

**Exports:**
```dart
class CropCard extends StatelessWidget {
  // Constructor
  - crop: Crop (required)
  - onTap: VoidCallback (required)
  
  // Nested UI Builders
  - _buildDifficultyBadge(context)
  - _buildStatsGrid(context)
  - _buildStatBox(context, icon, label, value)
  - _buildTechniquesChips(context)
  - _buildQuickInfoRow(context)
}
```

**Displays:**
- Crop image with error handling
- Crop name with common names
- Description (2-line max)
- Difficulty badge with color coding
- Stats grid (Days, Yield, Margin)
- Compatible techniques chips
- Quick info row (Season, Demand, pH, Temp)

---

### 6. `crop_filter_panel.dart` (400+ lines)

**Exports:**
```dart
class CropFilterPanel extends StatefulWidget
class _CropFilterPanelState extends State<CropFilterPanel> {
  // State
  - selectedTechniques: List<String>
  - selectedSeasons: List<String>
  - growthDurationRange: RangeValues
  - profitMarginRange: RangeValues
  - selectedDifficulty: String?
  - selectedMarketDemand: String?
  
  // Constants
  - techniques: List<String> // NFT, DWC, Drip, Aeroponics
  - seasons: List<String> // Spring, Summer, Autumn, Winter, Year-round
  - difficulties: List<String> // Beginner, Intermediate, Advanced, Expert
  - marketDemands: List<String> // Low, Medium, High, Very-high
  
  // Callbacks
  - _applyFilters()
  - _clearAllFilters()
  
  // UI Builders
  - _buildFilterSection(title, child)
  - _buildCheckboxList(items, selected, onChange)
  - _buildRadioList(items, selected, onChange)
}

// Extension
extension StringExtension {
  - capitalize(): String // "summer" → "Summer"
}
```

---

## 🔗 Dependency Graph

```
CropRecommendationPage
├── uses CropRepository
│   └── uses Crop model
│       └── no dependencies
├── uses CropCard widget
│   └── uses Crop model
├── uses CropFilterPanel widget
│   └── uses CropFilters model
│       └── no dependencies
└── uses CropFilters model
```

---

## 📦 Required Flutter Packages

**Already in pubspec.yaml:**
```yaml
flutter:
  sdk: flutter

# Used in crop panel:
# - material: Material Design UI (included with Flutter)
# - flutter/widgets: Core widgets (included)
# - No external packages required!
```

**Completely self-contained - no external dependencies!**

---

## 🎯 Usage Examples

### Example 1: Basic Integration
```dart
// In your page
import 'package:hydro_smart/features/crop_recommendation/presentation/pages/crop_recommendation_page.dart';

// Navigate
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => CropRecommendationPage()),
);
```

### Example 2: Named Route
```dart
// In MaterialApp
routes: {
  '/crops': (context) => CropRecommendationPage(),
}

// Navigate anywhere
Navigator.pushNamed(context, '/crops');
```

### Example 3: Use Repository Directly
```dart
import 'package:hydro_smart/features/crop_recommendation/data/repositories/crop_repository.dart';
import 'package:hydro_smart/features/crop_recommendation/domain/models/crop_filters.dart';

final repo = CropRepository();

// Get all crops
final crops = await repo.getAllCrops();

// Filter crops
final filters = CropFilters(
  hydroponicTechniques: ['NFT', 'DWC'],
  difficultyLevel: 'beginner',
);
final filtered = await repo.filterCrops(filters);

// Search
final results = await repo.searchCrops('tomato');
```

### Example 4: Use Crop Model
```dart
import 'package:hydro_smart/features/crop_recommendation/data/models/crop.dart';

// Create from JSON (e.g., from Firestore)
final cropData = {
  'id': 'crop_xyz',
  'cropName': 'Tomato',
  // ... other fields
};
final crop = Crop.fromJson(cropData);

// Access properties
print(crop.cropName); // "Tomato"
print(crop.getCompatibleTechniques()); // ['NFT', 'DWC', 'Drip']
print(crop.getPhRangeString()); // "6.0 - 6.8"
print(crop.getTemperatureRangeString()); // "15 - 28°C"

// Convert to JSON
final json = crop.toJson();
```

---

## 🧪 Testing Imports

To create a test file:

```dart
// test/crop_recommendation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hydro_smart/features/crop_recommendation/data/models/crop.dart';
import 'package:hydro_smart/features/crop_recommendation/data/repositories/crop_repository.dart';
import 'package:hydro_smart/features/crop_recommendation/domain/models/crop_filters.dart';

void main() {
  group('CropRepository', () {
    test('getAllCrops returns 6 crops', () async {
      final repo = CropRepository();
      final crops = await repo.getAllCrops();
      expect(crops.length, 6);
    });
    
    test('filterCrops with NFT technique', () async {
      final repo = CropRepository();
      final filters = CropFilters(
        hydroponicTechniques: ['NFT'],
      );
      final filtered = await repo.filterCrops(filters);
      expect(filtered.isNotEmpty, true);
      // All should support NFT
      for (var crop in filtered) {
        expect(
          crop.getCompatibleTechniques().contains('NFT'),
          true,
        );
      }
    });
  });
}
```

---

## 📚 Quick Reference

### Crop Model
```dart
// Create mock crop
Crop crop = Crop(
  id: 'crop_tomato',
  cropName: 'Cherry Tomato',
  imageUrl: 'https://...',
  // ... 16 more required parameters
);

// Access data
crop.cropName        // String
crop.seedToHarvestDays   // int
crop.yieldPerSqm    // double
crop.difficultyLevel // String
crop.profitMargin    // double

// Helper methods
crop.getCompatibleTechniques()   // ['NFT', 'DWC', 'Drip']
crop.getPhRangeString()          // "6.0 - 6.8"
crop.getTemperatureRangeString() // "15 - 28°C"
```

### Filter Model
```dart
// Create filters
CropFilters filters = CropFilters(
  hydroponicTechniques: ['NFT', 'DWC'],
  growingSeasons: ['summer'],
  growthDurationRange: RangeValues(30, 60),
  difficultyLevel: 'beginner',
);

// Check if filters active
if (filters.hasActiveFilters()) {
  // Some filters are applied
}

// Copy with modifications
CropFilters updated = filters.copyWith(
  difficultyLevel: 'intermediate',
);
```

### Repository
```dart
final repo = CropRepository();

// Get all
List<Crop> crops = await repo.getAllCrops();

// Filter
List<Crop> filtered = await repo.filterCrops(filters);

// Get one
Crop? crop = await repo.getCropById('crop_tomato_001');

// Search
List<Crop> results = await repo.searchCrops('basil');
```

---

## ✨ Summary

| Item | Details |
|------|---------|
| **Total Files** | 6 Dart files |
| **Total Lines** | ~1500 lines of code |
| **External Dependencies** | 0 (uses only Flutter SDK) |
| **Mock Data** | 6 complete crops included |
| **Filters** | 6 types (techniques, seasons, duration, margin, difficulty, demand) |
| **Components** | 2 pages + 2 widgets + 2 models + 1 repository |
| **Responsive** | Yes (works on all screen sizes) |
| **Dark Mode** | Yes (adapts to theme) |
| **Error Handling** | Yes (loading, errors, empty states) |

---

## 🚀 You're Ready!

All files are created with complete, production-ready code. Just import and use!

```dart
// That's all you need:
import 'package:hydro_smart/features/crop_recommendation/presentation/pages/crop_recommendation_page.dart';

// Then navigate:
Navigator.push(context, MaterialPageRoute(builder: (_) => CropRecommendationPage()));
```

---
