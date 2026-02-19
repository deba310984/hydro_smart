# Crop Data Pipeline: End-to-End Flow

## 🔄 Complete Data Flow

```
Admin uploads PDF → Python extracts → JSON conversion → Firestore → Flutter reads → Filter & display
```

---

## Step 1: Admin Uploads PDF

### Backend API Endpoint
```python
# backend/routes/crops_routes.py

from flask import Blueprint, request, jsonify
from werkzeug.utils import secure_filename
from services.crop_extraction import extract_crop_data
from services.firestore_service import save_to_firestore
import os

crops_bp = Blueprint('crops', __name__, url_prefix='/api/crops')

ALLOWED_EXTENSIONS = {'pdf', 'txt', 'docx'}
UPLOAD_FOLDER = 'uploaded_documents'

@crops_bp.route('/upload', methods=['POST'])
def upload_document():
    """
    Admin endpoint to upload research paper/PDF
    
    Request:
    - file: PDF document
    - source_type: "research_paper" | "guide" | "article"
    
    Response:
    - success: bool
    - document_id: str
    - crops_found: int
    """
    
    # Validate file
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if not file.filename.lower().endswith('.pdf'):
        return jsonify({'error': 'Only PDF files allowed'}), 400
    
    # Save file
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    filename = secure_filename(file.filename)
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    file.save(filepath)
    
    return jsonify({
        'success': True,
        'document_id': filename,
        'message': f'PDF uploaded: {filename}',
        'status': 'processing'
    }), 200
```

---

## Step 2: Python Script Extracts Values

### PDF Text Extraction Service
```python
# backend/services/pdf_extractor.py

import PyPDF2
import pdfplumber
import re
from typing import Dict, List

class PDFExtractor:
    
    @staticmethod
    def extract_text(pdf_path: str) -> str:
        """
        Extract raw text from PDF
        
        Example PDF content:
        ----
        HYDROPONIC TOMATO PRODUCTION GUIDE
        
        Crop: Cherry Tomato
        Temperature: 22-28°C
        pH: 6.5
        Growth Days: 60
        Yield: 25 kg/m²
        NFT Compatible: Yes
        DWC Compatible: Yes
        ----
        """
        
        try:
            # Try PyPDF2 first (faster)
            text = ""
            with open(pdf_path, 'rb') as file:
                reader = PyPDF2.PdfReader(file)
                for page in reader.pages:
                    text += page.extract_text()
            
            if text.strip():
                return text
            
            # Fallback to pdfplumber for better extraction
            with pdfplumber.open(pdf_path) as pdf:
                text = ""
                for page in pdf.pages:
                    text += page.extract_text()
                return text
        
        except Exception as e:
            print(f"Error extracting PDF: {e}")
            return ""


class CropDataExtractor:
    
    # Extraction patterns
    PATTERNS = {
        'crop_name': [
            r'(?:crop|plant)[\s:]*([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',
            r'(?:growing|cultivation of)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',
        ],
        'temperature': [
            r'temperature[\s:]*(\d+)\s*[-–]\s*(\d+)\s*°?[Cc]',
            r'(\d+)\s*[-–]\s*(\d+)\s*(?:celsius|°c)',
        ],
        'ph_range': [
            r'pH[\s:]*(\d+\.?\d*)\s*[-–]\s*(\d+\.?\d*)',
        ],
        'growth_days': [
            r'(?:days to harvest|harvest in|growth period)[s]?[\s:]*(\d+)',
            r'(\d+)\s*days?\s*(?:to harvest|growth)',
        ],
        'yield': [
            r'yield[\s:]*(\d+\.?\d*)\s*kg(?:/m²|\/m²|per\s+m²)',
        ],
        'lighting': [
            r'light[\s:]*(\d+)\s*hours?(?:\s+per day)?',
        ],
        'nft_compatible': [
            r'NFT[\s:]*(?:suitable|compatible|yes)',
        ],
        'dwc_compatible': [
            r'DWC[\s:]*(?:suitable|compatible|yes)',
        ],
        'drip_compatible': [
            r'Drip[\s:]*(?:suitable|compatible|yes)',
        ],
    }
    
    @classmethod
    def extract_all_data(cls, text: str) -> Dict:
        """
        Extract all structured data from text
        
        Returns:
        {
            'cropName': 'Cherry Tomato',
            'temperature': {'min': 22, 'max': 28},
            'ph': {'min': 6.0, 'max': 7.0},
            'growthDays': 60,
            'yield': 25.0,
            'lightingHours': 16,
            'hydroponicTechniques': ['NFT', 'DWC', 'Drip'],
            ...
        }
        """
        
        data = {}
        
        # Extract crop name
        data['cropName'] = cls._extract_field(text, 'crop_name')
        
        # Extract temperature
        temp_match = cls._find_pattern(text, 'temperature')
        if temp_match:
            data['temperature'] = {
                'min': int(temp_match[0]),
                'max': int(temp_match[1]),
                'optimal': (int(temp_match[0]) + int(temp_match[1])) // 2
            }
        
        # Extract pH
        ph_match = cls._find_pattern(text, 'ph_range')
        if ph_match:
            data['ph'] = {
                'min': float(ph_match[0]),
                'max': float(ph_match[1]),
                'optimal': (float(ph_match[0]) + float(ph_match[1])) / 2
            }
        
        # Extract growth days
        days_match = cls._find_pattern(text, 'growth_days')
        if days_match:
            data['growthDays'] = int(days_match[0])
        
        # Extract yield
        yield_match = cls._find_pattern(text, 'yield')
        if yield_match:
            data['yield'] = float(yield_match[0])
        
        # Extract lighting
        light_match = cls._find_pattern(text, 'lighting')
        if light_match:
            data['lightingHours'] = int(light_match[0])
        
        # Extract compatible techniques
        techniques = []
        if cls._find_pattern(text, 'nft_compatible'):
            techniques.append('NFT')
        if cls._find_pattern(text, 'dwc_compatible'):
            techniques.append('DWC')
        if cls._find_pattern(text, 'drip_compatible'):
            techniques.append('Drip')
        
        if techniques:
            data['hydroponicTechniques'] = techniques
        
        return data
    
    @staticmethod
    def _find_pattern(text: str, pattern_key: str):
        """Find first matching pattern"""
        patterns = CropDataExtractor.PATTERNS.get(pattern_key, [])
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return match.groups()
        
        return None
    
    @staticmethod
    def _extract_field(text: str, field_key: str) -> str:
        """Extract first matching field"""
        match = CropDataExtractor._find_pattern(text, field_key)
        return match[0] if match else None
```

---

## Step 3: Script Converts to JSON

### Data Conversion & Validation
```python
# backend/services/crop_extraction.py

import json
from datetime import datetime
from typing import Dict, Optional
import uuid

class CropJsonBuilder:
    
    @staticmethod
    def build_crop_document(extracted_data: Dict) -> Dict:
        """
        Convert extracted raw data to complete Firestore document
        
        Input: Raw extracted values
        Output: Complete crop JSON ready for Firestore
        """
        
        # Generate unique crop ID
        crop_id = f"crop_{extracted_data.get('cropName', 'unknown').lower().replace(' ', '_')}_{uuid.uuid4().hex[:8]}"
        
        # Build complete document
        crop_document = {
            # Identification
            "cropId": crop_id,
            "cropName": extracted_data.get('cropName', 'Unknown crop'),
            "commonNames": [],
            
            # Growing Conditions
            "growingConditions": {
                "pHRange": {
                    "min": extracted_data.get('ph', {}).get('min', 6.0),
                    "max": extracted_data.get('ph', {}).get('max', 7.0),
                    "optimal": extracted_data.get('ph', {}).get('optimal', 6.5)
                },
                "temperatureRange": {
                    "min": extracted_data.get('temperature', {}).get('min', 20),
                    "max": extracted_data.get('temperature', {}).get('max', 28),
                    "optimal": extracted_data.get('temperature', {}).get('optimal', 24),
                    "unit": "celsius"
                },
                "lightRequirement": {
                    "daily_hours": extracted_data.get('lightingHours', 14),
                    "lux_min": 300,
                    "lux_recommended": 500,
                    "spectrum": "full-spectrum or red/blue mix"
                },
                "waterRequirement": {
                    "daily_liters_per_sqm": 2.0,
                    "change_frequency": "every 2-3 weeks",
                    "notes": "Regular monitoring required"
                }
            },
            
            # Growth Metrics
            "growthMetrics": {
                "seedToHarvest_days": extracted_data.get('growthDays', 60),
                "seedToFirstHarvest_days": extracted_data.get('growthDays', 60) - 15,
                "harvestWindow_days": 30,
                "yield_per_sqm": extracted_data.get('yield', 20.0),
                "yield_unit": "kg/m²",
                "expected_plants_per_sqm": 6
            },
            
            # Hydroponic Techniques
            "hydroponicTechniques": {
                "NFT": {
                    "compatible": "NFT" in extracted_data.get('hydroponicTechniques', []),
                    "notes": "Ideal for leafy greens",
                    "yield_adjustment": 1.0
                },
                "DWC": {
                    "compatible": "DWC" in extracted_data.get('hydroponicTechniques', []),
                    "notes": "Deep water culture",
                    "yield_adjustment": 0.95
                },
                "Drip": {
                    "compatible": "Drip" in extracted_data.get('hydroponicTechniques', []),
                    "notes": "Drip irrigation system",
                    "yield_adjustment": 1.05
                }
            },
            
            # Nutrients
            "nutrients": {
                "recommendedSolution": "Hydroponic Formula",
                "ec_range": {
                    "min": 1.2,
                    "max": 1.6,
                    "optimal": 1.4
                },
                "macro_ratio": {
                    "note": "NPK ratio depends on crop type"
                },
                "micronutrients": [
                    "Calcium", "Magnesium", "Iron", "Manganese"
                ]
            },
            
            # Market Data (defaults - can be updated manually)
            "marketData": {
                "bestSeason": "summer",
                "market_demand_level": "medium",
                "typical_retail_price": 3.50,
                "wholesale_price": 1.50,
                "production_cost_per_kg": 0.80,
                "estimated_profit_margin_percent": 45,
                "market_demand_trend": "stable",
                "notes": "Extracted from source document"
            },
            
            # Difficulty
            "difficulty": {
                "level": "intermediate",
                "mainChallenges": [],
                "suitableForBeginners": True,
                "requiresSpecializedEquipment": False
            },
            
            # Metadata
            "description": f"Hydroponic cultivation of {extracted_data.get('cropName', 'crop')}.",
            "advantages": [
                "Controlled environment",
                "Year-round production",
                "Water efficient"
            ],
            "challenges": [
                "Initial setup cost",
                "Power dependency"
            ],
            
            # Tracking
            "metadata": {
                "source": "pdf_upload",
                "extracted_date": datetime.now().isoformat(),
                "extraction_method": "pattern_matching",
                "quality_score": 0.85,
                "reviewed": False,
                "version": 1
            },
            
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat(),
            "active": True,
            "tags": ["vegetable", "hydroponic"]
        }
        
        return crop_document
    
    @staticmethod
    def to_json(crop_document: Dict) -> str:
        """Convert document to JSON string"""
        return json.dumps(crop_document, indent=2, default=str)


def extract_crop_data(pdf_path: str) -> Optional[Dict]:
    """
    Main extraction pipeline
    
    PDF → Text extraction → Data extraction → JSON → Return
    """
    
    from services.pdf_extractor import PDFExtractor, CropDataExtractor
    
    # Step 1: Extract text from PDF
    pdf_extractor = PDFExtractor()
    text = pdf_extractor.extract_text(pdf_path)
    
    if not text:
        return None
    
    # Step 2: Extract structured data from text
    extracted_data = CropDataExtractor.extract_all_data(text)
    
    if not extracted_data.get('cropName'):
        return None
    
    # Step 3: Build complete JSON document
    crop_json = CropJsonBuilder.build_crop_document(extracted_data)
    
    return crop_json
```

---

## Step 4: JSON Pushed to Firestore

### Firestore Service
```python
# backend/services/firestore_service.py

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
from typing import Dict, Optional

class FirestoreService:
    
    def __init__(self):
        """Initialize Firestore (Firebase already initialized in main.py)"""
        self.db = firestore.client()
    
    def save_crop(self, crop_data: Dict) -> bool:
        """
        Save crop JSON to Firestore 'crops' collection
        
        Returns: True if successful, False otherwise
        """
        
        try:
            crop_id = crop_data.get('cropId')
            
            # Save to Firestore
            self.db.collection('crops').document(crop_id).set(crop_data)
            
            print(f"✅ Crop saved: {crop_id}")
            return True
        
        except Exception as e:
            print(f"❌ Error saving to Firestore: {e}")
            return False
    
    def get_all_crops(self) -> list:
        """
        Retrieve all crops from Firestore
        
        Returns: List of crop documents
        """
        
        try:
            docs = self.db.collection('crops').where('active', '==', True).stream()
            
            crops = []
            for doc in docs:
                crop_data = doc.to_dict()
                crop_data['id'] = doc.id
                crops.append(crop_data)
            
            return crops
        
        except Exception as e:
            print(f"❌ Error retrieving crops: {e}")
            return []
```

### Updated Upload Route
```python
# backend/routes/crops_routes.py (updated)

from services.crop_extraction import extract_crop_data
from services.firestore_service import FirestoreService
import os

firestore_service = FirestoreService()

@crops_bp.route('/upload', methods=['POST'])
def upload_document():
    """
    Complete pipeline:
    1. Receive PDF
    2. Extract data → JSON
    3. Save to Firestore
    4. Return success/failure
    """
    
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    
    # Save file temporarily
    os.makedirs('uploaded_documents', exist_ok=True)
    filename = secure_filename(file.filename)
    filepath = os.path.join('uploaded_documents', filename)
    file.save(filepath)
    
    try:
        # Extract crop data from PDF
        crop_json = extract_crop_data(filepath)
        
        if not crop_json:
            return jsonify({
                'error': 'No crop data could be extracted from PDF'
            }), 400
        
        # Save to Firestore
        success = firestore_service.save_crop(crop_json)
        
        if success:
            return jsonify({
                'success': True,
                'cropId': crop_json['cropId'],
                'cropName': crop_json['cropName'],
                'message': f"Crop '{crop_json['cropName']}' saved to Firestore"
            }), 200
        else:
            return jsonify({
                'error': 'Failed to save to Firestore'
            }), 500
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
    finally:
        # Clean up temp file
        if os.path.exists(filepath):
            os.remove(filepath)
```

---

## Step 5: Flutter Reads from Firestore

### Firestore Models (Dart)
```dart
// lib/data/models/crop_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Crop {
  final String cropId;
  final String cropName;
  final Map<String, dynamic> growingConditions;
  final Map<String, dynamic> growthMetrics;
  final Map<String, dynamic> hydroponicTechniques;
  final Map<String, dynamic> marketData;
  final Map<String, dynamic> difficulty;
  final String description;
  final List<String> advantages;
  final List<String> challenges;
  final bool active;

  Crop({
    required this.cropId,
    required this.cropName,
    required this.growingConditions,
    required this.growthMetrics,
    required this.hydroponicTechniques,
    required this.marketData,
    required this.difficulty,
    required this.description,
    required this.advantages,
    required this.challenges,
    this.active = true,
  });

  /// Parse Firestore document to Crop object
  factory Crop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Crop(
      cropId: data['cropId'] ?? '',
      cropName: data['cropName'] ?? 'Unknown',
      growingConditions: data['growingConditions'] ?? {},
      growthMetrics: data['growthMetrics'] ?? {},
      hydroponicTechniques: data['hydroponicTechniques'] ?? {},
      marketData: data['marketData'] ?? {},
      difficulty: data['difficulty'] ?? {},
      description: data['description'] ?? '',
      advantages: List<String>.from(data['advantages'] ?? []),
      challenges: List<String>.from(data['challenges'] ?? []),
      active: data['active'] ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cropId': cropId,
      'cropName': cropName,
      'growingConditions': growingConditions,
      'growthMetrics': growthMetrics,
      'hydroponicTechniques': hydroponicTechniques,
      'marketData': marketData,
      'difficulty': difficulty,
      'description': description,
      'advantages': advantages,
      'challenges': challenges,
      'active': active,
    };
  }
}
```

### Firestore Repository (Dart)
```dart
// lib/data/repositories/crop_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hydro_smart/data/models/crop_model.dart';

class CropRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all active crops from Firestore
  Future<List<Crop>> getAllCrops() async {
    try {
      final snapshot = await _firestore
          .collection('crops')
          .where('active', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Crop.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching crops: $e');
      return [];
    }
  }

  /// Stream crops for real-time updates
  Stream<List<Crop>> getCropsStream() {
    return _firestore
        .collection('crops')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Crop.fromFirestore(doc))
            .toList());
  }

  /// Get single crop by ID
  Future<Crop?> getCropById(String cropId) async {
    try {
      final doc = await _firestore.collection('crops').doc(cropId).get();
      return doc.exists ? Crop.fromFirestore(doc) : null;
    } catch (e) {
      print('Error fetching crop: $e');
      return null;
    }
  }
}
```

---

## Step 6: Filter & Display

### Filter Model
```dart
// lib/features/crop_recommendation/domain/models/crop_filters.dart

class CropFilters {
  List<String>? hydroponicTechniques;  // NFT, DWC, Drip, etc.
  List<String>? growingSeasons;         // summer, winter, year-round
  RangeValues? growthDuration;          // min-max days
  RangeValues? profitMargin;            // min-max percentage
  String? difficultyLevel;              // beginner, intermediate, advanced
  String? marketDemand;                 // low, medium, high, very-high

  CropFilters({
    this.hydroponicTechniques,
    this.growingSeasons,
    this.growthDuration,
    this.profitMargin,
    this.difficultyLevel,
    this.marketDemand,
  });

  bool isEmpty() {
    return hydroponicTechniques == null &&
        growingSeasons == null &&
        growthDuration == null &&
        profitMargin == null &&
        difficultyLevel == null &&
        marketDemand == null;
  }

  void clear() {
    hydroponicTechniques = null;
    growingSeasons = null;
    growthDuration = null;
    profitMargin = null;
    difficultyLevel = null;
    marketDemand = null;
  }
}
```

### Filter & Search Logic
```dart
// lib/features/crop_recommendation/domain/usecases/filter_crops_usecase.dart

class FilterCropsUseCase {
  final CropRepository repository;

  FilterCropsUseCase(this.repository);

  /// Apply filters to crop list
  List<Crop> execute(List<Crop> crops, CropFilters filters) {
    var filtered = crops;

    // Filter by hydroponic technique
    if (filters.hydroponicTechniques != null &&
        filters.hydroponicTechniques!.isNotEmpty) {
      filtered = filtered.where((crop) {
        final techniques = crop.hydroponicTechniques as Map?;
        if (techniques == null) return false;
        
        return filters.hydroponicTechniques!.any(
          (technique) => techniques[technique]?['compatible'] ?? false,
        );
      }).toList();
    }

    // Filter by growing season
    if (filters.growingSeasons != null &&
        filters.growingSeasons!.isNotEmpty) {
      filtered = filtered.where((crop) {
        final season = crop.marketData?['bestSeason'] ?? '';
        return filters.growingSeasons!.contains(season) ||
            season == 'year-round';
      }).toList();
    }

    // Filter by growth duration (days)
    if (filters.growthDuration != null) {
      filtered = filtered.where((crop) {
        final days = crop.growthMetrics?['seedToHarvest_days'] ?? 0;
        return days >= filters.growthDuration!.start &&
            days <= filters.growthDuration!.end;
      }).toList();
    }

    // Filter by profit margin
    if (filters.profitMargin != null) {
      filtered = filtered.where((crop) {
        final margin = crop.marketData?['estimated_profit_margin_percent'] ?? 0;
        return margin >= filters.profitMargin!.start &&
            margin <= filters.profitMargin!.end;
      }).toList();
    }

    // Filter by difficulty level
    if (filters.difficultyLevel != null) {
      filtered = filtered.where((crop) {
        final level = crop.difficulty?['level'] ?? '';
        return level == filters.difficultyLevel;
      }).toList();
    }

    // Filter by market demand
    if (filters.marketDemand != null) {
      filtered = filtered.where((crop) {
        final demand = crop.marketData?['market_demand_level'] ?? '';
        return demand == filters.marketDemand;
      }).toList();
    }

    return filtered;
  }
}
```

### UI: Crop List Screen
```dart
// lib/features/crop_recommendation/presentation/pages/crops_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CropsListPage extends StatefulWidget {
  @override
  State<CropsListPage> createState() => _CropsListPageState();
}

class _CropsListPageState extends State<CropsListPage> {
  late CropRepository cropRepository;
  List<Crop> allCrops = [];
  List<Crop> filteredCrops = [];
  CropFilters filters = CropFilters();

  @override
  void initState() {
    super.initState();
    cropRepository = CropRepository();
    _loadCrops();
  }

  void _loadCrops() async {
    final crops = await cropRepository.getAllCrops();
    setState(() {
      allCrops = crops;
      filteredCrops = crops;
    });
  }

  void _applyFilters(CropFilters newFilters) {
    final filterUseCase = FilterCropsUseCase(cropRepository);
    final filtered = filterUseCase.execute(allCrops, newFilters);
    
    setState(() {
      filters = newFilters;
      filteredCrops = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hydroponic Crops'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: Icon(Icons.filter_list),
              label: Text('Filters'),
              onPressed: () => _showFilterPanel(context),
            ),
          ),
          
          // Crop Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Found: ${filteredCrops.length} crops',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          
          // Crops List
          Expanded(
            child: filteredCrops.isEmpty
                ? Center(
                    child: Text('No crops found matching your filters'),
                  )
                : ListView.builder(
                    itemCount: filteredCrops.length,
                    itemBuilder: (context, index) {
                      final crop = filteredCrops[index];
                      return _buildCropCard(context, crop);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, Crop crop) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(crop.cropName),
        subtitle: Text(crop.description),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showCropDetails(context, crop),
      ),
    );
  }

  void _showFilterPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CropFilterPanel(
        currentFilters: filters,
        onApply: (newFilters) {
          Navigator.pop(context);
          _applyFilters(newFilters);
        },
      ),
    );
  }

  void _showCropDetails(BuildContext context, Crop crop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropDetailPage(crop: crop),
      ),
    );
  }
}
```

### UI: Crop Detail Page
```dart
// lib/features/crop_recommendation/presentation/pages/crop_detail_page.dart

class CropDetailPage extends StatelessWidget {
  final Crop crop;

  const CropDetailPage({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(crop.cropName),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              crop.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 24),

            // Growing Conditions
            _buildSection(
              context,
              'Growing Conditions',
              [
                'Temperature: ${crop.growingConditions['temperatureRange']['min']}-${crop.growingConditions['temperatureRange']['max']}°C',
                'pH: ${crop.growingConditions['pHRange']['min']}-${crop.growingConditions['pHRange']['max']}',
                'Light: ${crop.growingConditions['lightRequirement']['daily_hours']} hours/day',
              ],
            ),

            // Growth Metrics
            _buildSection(
              context,
              'Growth & Yield',
              [
                'Days to Harvest: ${crop.growthMetrics['seedToHarvest_days']}',
                'Expected Yield: ${crop.growthMetrics['yield_per_sqm']} kg/m²',
                'Plants per m²: ${crop.growthMetrics['expected_plants_per_sqm']}',
              ],
            ),

            // Compatible Techniques
            _buildTechniquesList(context),

            // Market Data
            _buildSection(
              context,
              'Market Data',
              [
                'Best Season: ${crop.marketData['bestSeason']}',
                'Market Demand: ${crop.marketData['market_demand_level']}',
                'Profit Margin: ${crop.marketData['estimated_profit_margin_percent']}%',
                'Retail Price: \$${crop.marketData['typical_retail_price']}/kg',
              ],
            ),

            // Advantages
            _buildBulletList(
              context,
              'Advantages',
              crop.advantages,
            ),

            // Challenges
            _buildBulletList(
              context,
              'Challenges',
              crop.challenges,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(left: 16, bottom: 4),
          child: Text('• $item'),
        )),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBulletList(
      BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(left: 16, bottom: 4),
          child: Text('• $item'),
        )),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTechniquesList(BuildContext context) {
    final techniques = crop.hydroponicTechniques as Map? ?? {};
    final compatible = techniques.entries
        .where((e) => e.value['compatible'] == true)
        .map((e) => e.key)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compatible Techniques',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: compatible
              .map((tech) => Chip(label: Text(tech)))
              .toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
```

---

## 📊 Complete Data Flow Summary

```
┌─────────────────────────────────┐
│  Admin uploads PDF to /upload   │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Python extracts text from PDF  │ (PyPDF2/pdfplumber)
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Extract values using regex     │ (Temperature, pH, yield, days, etc.)
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Build complete JSON document   │ (CropJsonBuilder)
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Save to Firestore 'crops'      │ (firestore_service.save_crop)
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Flutter reads from Firestore   │ (CropRepository.getAllCrops)
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Apply filters in memory        │ (FilterCropsUseCase)
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Display filtered crops         │ (CropsListPage)
└─────────────────────────────────┘
```

---

## Backend Setup (requirements.txt)

```txt
Flask==2.3.0
PyPDF2==3.0.1
pdfplumber==0.9.0
firebase-admin==6.1.0
python-dotenv==1.0.0
Werkzeug==2.3.0
```

## Quick Start

1. **Install Python packages:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Set up Flask app:**
   ```python
   # backend/app.py
   from flask import Flask
   from routes.crops_routes import crops_bp
   import firebase_admin
   from firebase_admin import credentials

   app = Flask(__name__)

   # Initialize Firebase
   cred = credentials.Certificate('path/to/firebase-key.json')
   firebase_admin.initialize_app(cred)

   # Register routes
   app.register_blueprint(crops_bp)

   if __name__ == '__main__':
       app.run(debug=True, port=5000)
   ```

3. **Upload PDF:** `POST /api/crops/upload`

4. **Data automatically**: Extracted → Converted to JSON → Saved to Firestore

5. **Flutter displays**: Reads from Firestore → Filters → Shows to user

---
