# Flutter Crop Recommendation Panel - Integration Guide

## 📁 File Structure

Files created for the Crop Recommendation feature:

```
lib/
└── features/
    └── crop_recommendation/
        ├── data/
        │   ├── models/
        │   │   └── crop.dart                    ✅ Crop model with all fields
        │   └── repositories/
        │       └── crop_repository.dart         ✅ Mock data + filtering logic
        │
        ├── domain/
        │   └── models/
        │       └── crop_filters.dart            ✅ Filter model
        │
        └── presentation/
            ├── pages/
            │   └── crop_recommendation_page.dart ✅ Main page with list & filter button
            │
            └── widgets/
                ├── crop_card.dart               ✅ Beautiful crop card display
                └── crop_filter_panel.dart       ✅ Filter panel with all 5 filters
```

---

## 🚀 How to Integrate into Your App

### Step 1: Add to Navigation

Update your main navigation or dashboard to include the crop recommendation page:

```dart
// In your main.dart or navigation file

import 'package:hydro_smart/features/crop_recommendation/presentation/pages/crop_recommendation_page.dart';

// In your navigation/routing logic:
// Option 1: Direct navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CropRecommendationPage(),
  ),
);

// Option 2: Named route
const cropRecommendationRoute = '/crops';

// In MaterialApp:
routes: {
  cropRecommendationRoute: (context) => CropRecommendationPage(),
  // ... other routes
},

// Navigate:
Navigator.pushNamed(context, cropRecommendationRoute);
```

### Step 2: Add to Dashboard (Optional)

Add a button to your dashboard to access crop recommendations:

```dart
// In your dashboard/homepage

ListTile(
  leading: Icon(Icons.grass),
  title: Text('Crop Recommendations'),
  subtitle: Text('Find hydroponic crops with filters'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropRecommendationPage(),
      ),
    );
  },
)
```

---

## 🎯 Component Overview

### 1. Crop Model (`crop.dart`)

Complete data structure for a crop:

```dart
Crop(
  id: 'crop_tomato_001',
  cropName: 'Cherry Tomato',
  imageUrl: 'https://...',
  
  // Growing Conditions
  phRange: {'min': 6.0, 'max': 6.8, 'optimal': 6.5},
  temperatureRange: {'min': 15, 'max': 28, 'optimal': 22},
  seedToHarvestDays: 60,
  yieldPerSqm: 25.0,
  
  // Hydroponic Techniques
  hydroponicTechniques: {
    'NFT': {'compatible': true},
    'DWC': {'compatible': true},
    'Drip': {'compatible': true},
  },
  
  // Market Data
  bestSeason: 'summer',
  marketDemandLevel: 'very-high',
  profitMargin: 65.0,
  difficultyLevel: 'beginner',
  
  // ... more fields
)
```

### 2. Crop Filter Model (`crop_filters.dart`)

Filter criteria applied to crops:

```dart
CropFilters(
  hydroponicTechniques: ['NFT', 'DWC'],        // Technique filter
  growingSeasons: ['spring', 'summer'],         // Season filter
  growthDurationRange: RangeValues(30, 60),     // Duration slider
  profitMarginRange: RangeValues(50, 100),      // Profit margin slider
  difficultyLevel: 'beginner',                  // Difficulty selector
  marketDemandLevel: 'high',                    // Market demand selector
)
```

### 3. Crop Repository (`crop_repository.dart`)

Data access layer with mock data:

```dart
// Get all crops
final crops = await repository.getAllCrops();

// Filter crops
final filtered = await repository.filterCrops(filters);

// Search crops
final results = await repository.searchCrops('tomato');

// Get single crop
final crop = await repository.getCropById('crop_tomato_001');
```

**Current Mock Crops:**
- Cherry Tomato (Beginner)
- Butterhead Lettuce (Beginner)
- Spinach (Beginner)
- Cucumber (Intermediate)
- Sweet Basil (Beginner)
- Bell Pepper (Advanced)

### 4. Main Page (`crop_recommendation_page.dart`)

Display crops with filters:

**Features:**
- ✅ Load all crops from repository
- ✅ Display crops in scrollable list
- ✅ Show crop count
- ✅ Filter button opens filter panel
- ✅ Clear filters button (when filters active)
- ✅ Tap crop card to see details
- ✅ Error handling & loading states

### 5. Crop Card Widget (`crop_card.dart`)

Beautiful card displaying crop info:

**Displays:**
```
┌─────────────────────────┐
│   Crop Image (180px)    │
├─────────────────────────┤
│ Cherry Tomato           │
│ (Sweet Tomato, Tiny Tim)│
│                         │
│ Prolific producers...   │
│                         │
│ 📅 60 days | 25 kg/m²  │
│ 💰 65% margin          │
│                         │
│ Compatible Techniques:  │
│ NFT · DWC · Drip        │
│                         │
│ Season     Market  pH   │
│ Summer     Very    6.0- │
│            High    6.8  │
└─────────────────────────┘
```

### 6. Filter Panel Widget (`crop_filter_panel.dart`)

Draggable bottom sheet with 6 filter types:

**Filters Available:**
```
1. 🌱 Hydroponic Technique
   └─ Checkboxes: NFT, DWC, Drip, Aeroponics

2. 🌞 Growing Season
   └─ Checkboxes: Spring, Summer, Autumn, Winter, Year-round

3. 📅 Growth Duration (Days)
   └─ Range Slider: 0-180 days

4. 💰 Profit Margin (%)
   └─ Range Slider: 0-100%

5. ⚙️ Difficulty Level
   └─ Radio Buttons: Beginner, Intermediate, Advanced, Expert

6. 📊 Market Demand
   └─ Radio Buttons: Low, Medium, High, Very-high
```

---

## 🔄 Data Flow

```
User Opens Crop Recommendation Page
    ↓
CropRecommendationPage.initState() 
    ↓
Load All Crops from Repository
    ↓
Display Crops in CropCard List
    ↓
User Taps Filter Button
    ↓
Show CropFilterPanel (bottom sheet)
    ↓
User Selects Filters & Taps "Apply Filters"
    ↓
Repository.filterCrops(filters) applies logic
    ↓
Update UI with Filtered Results
    ↓
Display Filtered Crops
```

---

## 📊 Filter Logic

The repository filters crops based on:

```dart
// 1. Hydroponic Technique (Multiple selection)
filtered = filtered.where((crop) {
  final compatible = crop.getCompatibleTechniques();
  return filters.hydroponicTechniques
      .any((technique) => compatible.contains(technique));
}).toList();

// 2. Growing Season (Multiple selection + year-round)
filtered = filtered.where((crop) {
  return filters.growingSeasons.contains(crop.bestSeason) ||
      crop.bestSeason == 'year-round';
}).toList();

// 3. Growth Duration Range
filtered = filtered.where((crop) {
  return crop.seedToHarvestDays >= min &&
      crop.seedToHarvestDays <= max;
}).toList();

// 4. Profit Margin Range
filtered = filtered.where((crop) {
  return crop.profitMargin >= min &&
      crop.profitMargin <= max;
}).toList();

// 5. Difficulty Level (Single selection)
filtered = filtered.where((crop) {
  return crop.difficultyLevel == selectedDifficulty;
}).toList();

// 6. Market Demand (Single selection)
filtered = filtered.where((crop) {
  return crop.marketDemandLevel == selectedDemand;
}).toList();
```

---

## 🎨 Theming

All components respect your app's theme:

```dart
// Colors automatically adapt
Theme.of(context).primaryColor        // Main color
Theme.of(context).brightness          // Dark/Light mode
Theme.of(context).textTheme            // Typography
```

**Difficulty Level Colors:**
- 🟢 Beginner: Green
- 🟠 Intermediate: Orange
- 🔴 Advanced: Red
- 🟣 Expert: Purple

---

## 🔌 Integration with Firebase (Later)

When ready to use real data, replace the mock repository:

```dart
// Current: Mock data
final repository = CropRepository(); // Uses mock crops

// Future: Firebase
class FirestoreCropRepository {
  Future<List<Crop>> getAllCrops() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('crops')
        .where('active', isEqualTo: true)
        .get();
    
    return snapshot.docs
        .map((doc) => Crop.fromJson(doc.data()))
        .toList();
  }
  
  // Same filtering logic as mock
  Future<List<Crop>> filterCrops(CropFilters filters) async { ... }
}
```

The UI remains **100% the same** - only swap the repository!

---

## ✨ Features Summary

| Feature | Status | Details |
|---------|--------|---------|
| Display all crops | ✅ | 6 mock crops with full data |
| Crop details | ✅ | Image, name, techniques, specs |
| Filter by technique | ✅ | NFT, DWC, Drip, Aeroponics |
| Filter by season | ✅ | Spring, Summer, Autumn, Winter, Year-round |
| Filter by growth duration | ✅ | Range slider 0-180 days |
| Filter by profit margin | ✅ | Range slider 0-100% |
| Filter by difficulty | ✅ | Radio buttons: Beginner to Expert |
| Filter by market demand | ✅ | Radio buttons: Low to Very-high |
| Search crops | ✅ | Repository ready (not UI yet) |
| Responsive design | ✅ | Works on all screen sizes |
| Dark mode support | ✅ | Adapts to system theme |
| Error handling | ✅ | Loading, errors, empty states |
| Loading states | ✅ | Circular progress indicator |

---

## 🧪 Testing the Panel

1. **Open the page:**
   ```dart
   Navigator.push(context, MaterialPageRoute(
     builder: (context) => CropRecommendationPage(),
   ));
   ```

2. **View all crops** - Should see 6 mock crops

3. **Test filters:**
   - Select "NFT" technique → Should filter crops
   - Select "Summer" season → Should show summer crops
   - Adjust duration slider → Should filter by days
   - Select "Beginner" difficulty → Should show beginner crops

4. **Tap crop card** → Should show detailed info in dialog

5. **Clear filters** → Should restore all crops

---

## 📝 Next Steps (Backend Integration)

When backend is ready:

1. Replace mock repository with Firestore repository
2. Update `crop_repository.dart`:
   - Remove mock data (`_mockCrops`)
   - Add Firebase import
   - Implement `getAllCrops()` with Firestore query
   - Implement `filterCrops()` with query logic

3. No UI changes needed!

---

## 📂 Files Quick Reference

| File | Purpose | Lines |
|------|---------|-------|
| `crop.dart` | Crop model & methods | 200+ |
| `crop_filters.dart` | Filter model | 60 |
| `crop_repository.dart` | Data access + mock data | 300+ |
| `crop_recommendation_page.dart` | Main page | 250+ |
| `crop_card.dart` | Card widget | 350+ |
| `crop_filter_panel.dart` | Filter UI | 400+ |
| **Total** | Complete feature | **1500+ lines** |

---

## 🎯 You're All Set!

Your Flutter crop recommendation panel is ready to use. Just:

1. ✅ Files are created
2. ✅ Models are defined
3. ✅ Repository has mock data
4. ✅ UI is fully functional
5. ✅ All filters work
6. ✅ Theming is applied
7. ✅ Error handling is done

**Next: Add to your Dashboard/Navigation!**
