# Crop Recommendation Data Pipeline & Firestore Design

## 📋 Table of Contents
1. [System Overview](#system-overview)
2. [Data Extraction Methodology](#data-extraction-methodology)
3. [Technical Stack](#technical-stack)
4. [Firestore Database Structure](#firestore-database-structure)
5. [Data Processing Pipeline](#data-processing-pipeline)
6. [NLP & Extraction Strategy](#nlp--extraction-strategy)
7. [Quality Control & Validation](#quality-control--validation)
8. [Step-by-Step Implementation](#step-by-step-implementation)

---

## System Overview

### Architecture Flow
```
Research Papers/PDFs/Articles
           ↓
    Document Upload API
           ↓
    Text Extraction (PyPDF2 + OCR)
           ↓
    Document Processing Service
           ↓
    NLP-based Data Extraction
           ↓
    Manual Review Dashboard (Optional)
           ↓
    Structured Data Validation
           ↓
    Firestore Storage
           ↓
    Flutter App (Display & Filter)
```

---

## Data Extraction Methodology

### Overview
You need a **three-tier extraction approach**:
1. **Automated extraction** from documents
2. **Pattern-based extraction** using templates
3. **Manual review** for quality assurance (recommended for ~20% sample)

### Why This Approach?
- Research papers are unstructured but follow patterns
- Different document types require different parsing strategies
- NLP alone won't give you 100% accuracy
- Hybrid approach balances automation with quality

---

## Technical Stack

### Backend (Python)
**Why Python?**
- Excellent NLP libraries (spaCy, NLTK, LLMs)
- PDF parsing (PyPDF2, pdfplumber, fitz)
- OCR support (Tesseract, pytesseract)
- Data processing (Pandas, NumPy)
- Easy integration with Firebase

### Required Libraries
```txt
# Core
Flask==2.3.0  # or FastAPI for async
python-dotenv==1.0.0

# PDF & Document Processing
PyPDF2==3.0.1
pdfplumber==0.9.0
pytesseract==0.3.10  # OCR
Pillow==10.0.0

# NLP
spacy==3.6.0
transformers==4.30.0  # For advanced NLP
sentence-transformers==2.2.2

# Data Processing
pandas==2.0.0
numpy==1.24.0
python-dateutil==2.8.2

# Database
firebase-admin==6.1.0

# Validation
pydantic==2.0.0
jsonschema==4.18.0

# Utilities
requests==2.31.0
python-dotenv==1.0.0
```

---

## Firestore Database Structure

### Collection: `crops`

#### Document Structure
```javascript
{
  // Identification
  cropId: "crop_tomato_001",  // Unique ID format: crop_[name]_[variant]
  cropName: "Tomato (Cherry)",
  commonNames: ["Cherry Tomato", "Sweet Tomato"],
  
  // Hydroponic Techniques
  hydroponicTechniques: {
    NFT: {
      compatible: true,
      notes: "Ideal for NFT systems, widely adopted",
      yield_adjustment: 1.0  // Multiplier for expected yield
    },
    DWC: {
      compatible: true,
      notes: "Requires careful pH management",
      yield_adjustment: 0.95
    },
    Drip: {
      compatible: true,
      notes: "Standard approach, easy maintenance",
      yield_adjustment: 1.05
    },
    Aeroponics: {
      compatible: true,
      notes: "Excellent water efficiency",
      yield_adjustment: 1.1
    },
    Kratky: {
      compatible: false,
      notes: "Not recommended - requires frequent watering"
    }
  },
  
  // Optimal Growing Conditions
  growingConditions: {
    pHRange: {
      min: 6.0,
      max: 6.8,
      optimal: 6.5
    },
    temperatureRange: {
      min: 15,  // Celsius
      max: 28,
      optimal: 22,
      unit: "celsius"
    },
    lightRequirement: {
      daily_hours: 16,
      lux_min: 300,
      lux_recommended: 500,
      spectrum: "full-spectrum or red/blue mix"
    },
    waterRequirement: {
      daily_liters_per_sqm: 2.5,
      change_frequency: "every 2-3 weeks",
      notes: "Regular monitoring required"
    }
  },
  
  // Growth & Yield
  growthMetrics: {
    seedToHarvest_days: 60,
    seedToFirstHarvest_days: 45,
    harvestWindow_days: 30,
    yield_per_sqm: 25,  // kg per square meter
    yield_unit: "kg/m²",
    expected_plants_per_sqm: 6
  },
  
  // Nutrient Profile
  nutrients: {
    recommendedSolution: "Hydroponic Vegetable Formula",
    ec_range: {
      min: 1.2,
      max: 1.6,
      optimal: 1.4
    },
    macro_ratio: {
      nitrogen: "N",
      phosphorus: "P",
      potassium: "K",
      note: "NPK ratio 15-10-15 recommended"
    },
    micronutrients: [
      "Calcium",
      "Magnesium",
      "Iron",
      "Manganese",
      "Boron",
      "Zinc",
      "Copper",
      "Molybdenum"
    ],
    specialized_additives: [
      "Beneficial bacteria (optional)",
      "Kelp extract (optional)"
    ]
  },
  
  // Seeds & Propagation
  seeds: {
    germination_days: 5,
    germination_temperature: 20,
    seedling_growth_days: 20,
    notes: "Direct hydroponic sowing possible after germination"
  },
  
  // Market & Profitability
  marketData: {
    bestSeason: "summer",  // spring, summer, autumn, winter, year-round
    seasonalAvailability: {
      spring: 0.8,  // Yield multiplier (80% of expected)
      summer: 1.0,
      autumn: 0.9,
      winter: 0.5
    },
    market_demand_level: "high",  // low, medium, high, very-high
    typical_retail_price: 5.5,  // USD per kg
    wholesale_price: 2.0,
    production_cost_per_kg: 0.8,
    estimated_profit_margin_percent: 60,
    market_demand_trend: "increasing",
    notes: "Year-round demand, peak in summer"
  },
  
  // Difficulty & Requirements
  difficulty: {
    level: "beginner",  // beginner, intermediate, advanced, expert
    mainChallenges: [
      "Pest management (whiteflies, mites)",
      "Flower drop in high temperatures",
      "Nutrient burn susceptibility"
    ],
    suitableForBeginners: true,
    requiresSpecializedEquipment: false
  },
  
  // Companion Planting & Rotation
  companionPlanting: {
    good_companions: [
      "Basil",
      "Carrot",
      "Parsley"
    ],
    avoid_with: [
      "Brassicas"
    ],
    notes: "NFT systems allow multi-crop setups"
  },
  
  // Description & Resources
  description: "Cherry tomatoes are prolific producers perfect for hydroponic systems...",
  advantages: [
    "High yield in compact spaces",
    "Multiple harvests per season",
    "Disease resistance in controlled environment",
    "Year-round production possible"
  ],
  challenges: [
    "Pest management required",
    "Pollination needed for fruit set",
    "Power outage vulnerability"
  ],
  
  // Data Source & Quality
  metadata: {
    source: "research_paper_tomato_hydro_2023",
    source_url: "https://...",
    source_type: "research_paper",  // research_paper, guide, article, handbook
    extracted_date: "2026-02-19T10:30:00Z",
    extraction_method: "nlp_template_based",
    quality_score: 0.92,  // Confidence 0-1
    reviewed: true,
    reviewed_by: "admin@hydroponics.com",
    review_date: "2026-02-20T10:30:00Z",
    review_notes: "Verified with 2 additional sources",
    version: 1,
    last_updated: "2026-02-20T10:30:00Z"
  },
  
  // Timestamp & Organization
  created_at: "2026-02-19T10:30:00Z",
  updated_at: "2026-02-20T10:30:00Z",
  active: true,  // For soft-delete
  tags: [
    "vegetable",
    "fruiting",
    "summer-crop",
    "high-yield",
    "beginner-friendly"
  ]
}
```

### Collection: `crop_variants`
Special document for different varieties (optional but recommended):
```javascript
{
  variantId: "var_tomato_cherry_sweet_100",
  parent_cropId: "crop_tomato_001",
  varietyName: "Sweet 100",
  
  // Variant-specific overrides
  yield_adjustment: 1.15,  // This variety is 15% more productive
  days_to_harvest: 55,  // Faster than standard
  
  // ... other overrides
}
```

### Collection: `extraction_sources`
Track all uploaded documents:
```javascript
{
  sourceId: "source_pdf_2026_02",
  document_name: "Hydroponic Tomato Production Guide 2023.pdf",
  document_url: "gs://bucket/documents/...",
  
  upload_date: "2026-02-19T10:30:00Z",
  uploader: "admin@hydroponics.com",
  
  source_type: "research_paper",
  topic: "Tomato cultivation",
  
  extracted_crops: [
    "crop_tomato_001",
    "crop_tomato_basil_companion"
  ],
  
  processing_status: "completed",  // pending, processing, completed, failed
  extraction_log: "...",
  
  quality_metrics: {
    total_extractions: 2,
    verified_extractions: 2,
    confidence_avg: 0.94
  }
}
```

### Collection: `pending_crops`
For manual review before final storage:
```javascript
{
  pending_id: "pending_crop_2026_02_01",
  
  raw_extracted_data: { /* ... */ },
  
  extraction_confidence: 0.78,
  extraction_method: "nlp_named_entity",
  
  status: "pending_review",  // pending_review, approved, rejected, needs_revision
  
  reviewer_notes: "...",
  reviewer: "admin@hydroponics.com",
  review_date: "2026-02-20",
  
  source_document: "source_pdf_2026_02",
  creation_date: "2026-02-19"
}
```

---

## Data Processing Pipeline

### Phase 1: Document Upload & Storage
```python
# Backend API Endpoint
POST /api/crops/upload-source
{
  "file": <PDF/DOCX>,
  "source_type": "research_paper",
  "metadata": {
    "title": "Hydroponic Crop Guide",
    "publish_date": "2023-01-01",
    "authors": ["Dr. Smith"]
  }
}

Response:
{
  "sourceId": "source_pdf_2026_02",
  "status": "processing",
  "message": "Document uploaded and queued for processing"
}
```

### Phase 2: Text Extraction
```python
# Process PDF → Extract text
def extract_text_from_pdf(pdf_path):
    """
    Extract text from PDF:
    1. First try PyPDF2 (searches for OCR already done)
    2. If needed, use pdfplumber for better accuracy
    3. For images-only PDFs, use Tesseract OCR
    """
    pass
```

### Phase 3: Document Segmentation
```python
# Identify crop-related sections
def segment_document(text):
    """
    Split text into logical sections:
    - Crop name patterns: "Cultivation of X" or "Growing X hydroponically"
    - Conditions section: "Growing conditions", "optimal parameters"
    - Yield section
    - Market data section
    """
    pass
```

### Phase 4: Information Extraction
Use hybrid approach:
1. **Template-based extraction** (regex + pattern matching)
2. **NLP-based extraction** (spaCy entity recognition)
3. **LLM-based extraction** (Optional: OpenAI/Llama for complex data)

### Phase 5: Data Validation & Quality Check
```python
def validate_crop_data(extracted_data):
    """
    Validate using Pydantic model:
    - pH range is 0-14
    - Temperature values are realistic
    - Growth days > 0
    - Yield values make sense
    - Required fields are present
    """
    pass
```

### Phase 6: Storage Decision
- If confidence > 85%: Store directly or send to pending review
- If confidence 65-85%: Require manual review
- If confidence < 65%: Flag for expert review or rejection

---

## NLP & Extraction Strategy

### Do You NEED NLP?
**Short answer:** Not exclusively, but it helps significantly.

**Hybrid Approach (Recommended):**
```
├─ Regex + Pattern Matching (60% of extraction)
│  └─ Extract known patterns: "pH: 6.5", "Temperature: 22°C"
│
├─ spaCy NLP (30% of extraction)
│  └─ Named entity recognition for crop names, locations
│  └─ Dependency parsing for relationships
│
└─ Optional LLM (10% for complex cases)
   └─ GPT-3.5/Claude for ambiguous text
   └─ Only when confidence is low
```

### Key Extraction Patterns

#### 1. **Temperature Extraction**
```python
import re

patterns = [
    r'temperature[s]?\s*:?\s*(\d+)\s*[-–]\s*(\d+)\s*°?[Cc]',
    r'(\d+)\s*[-–]\s*(\d+)\s*degree[s]?\s*[Cc]elsius',
    r'optimal\s+[^:]*?temperature[s]?.*?(\d+).*?([°Cc])',
]

# Example: "Ideal temperature: 22-28°C" → {"min": 22, "max": 28}
```

#### 2. **pH Range Extraction**
```python
patterns = [
    r'pH\s*:?\s*(\d+\.?\d*)\s*[-–]\s*(\d+\.?\d*)',
    r'pH\s+range\s+of\s+(\d+\.?\d*)\s*to\s*(\d+\.?\d*)',
]
```

#### 3. **Crop Name Recognition**
```python
# Use spaCy with custom training data
nlp = spacy.load("en_core_web_sm")
# Add pattern matcher for crop names
```

#### 4. **Duration/Time Extraction**
```python
patterns = [
    r'(\d+)\s*(?:to|–|-)\s*(\d+)\s*days',
    r'(\d+)\s*days?\s*(?:to|from)\s*harvest',
]
```

#### 5. **Yield Extraction**
```python
patterns = [
    r'yield[s]?\s*:?\s*(\d+\.?\d*)\s*(?:kg|kg\/m²|t\/ha)',
    r'(\d+\.?\d*)\s*(?:kg|ton)\s*per\s*(?:m²|hectare|sqm)',
]
```

### Optional LLM Integration (Advanced)

Only use when pattern matching fails:
```python
from langchain import OpenAI
from langchain.prompts import PromptTemplate

def extract_with_llm(section_text, crop_field):
    """
    Use LLM to extract when confidence is low
    Cost: ~$0.01 per extraction
    """
    prompt = PromptTemplate(
        input_variables=["text", "field"],
        template="""Extract the {field} from this agricultural text:
        {text}
        Return only the extracted value."""
    )
    pass
```

### spaCy Custom Model Training (Optional)

For high-volume extraction, train custom models:
```python
# Create training data from manually reviewed documents
training_data = [
    ("Growing tomatoes in NFT systems", 
     {"entities": [
        (0, 7, "CROP"),
        (11, 24, "TECHNIQUE")
     ]}),
]

# Train and save model
nlp.train(training_data)
```

---

## Quality Control & Validation

### Confidence Scoring System
```python
def calculate_confidence_score(extracted_data, source_data):
    """
    100% confidence factors:
    - All required fields present: +40%
    - Data passes validation rules: +30%
    - Multiple consistent sources: +20%
    - Matches known boundaries: +10%
    
    Example:
    - All fields present: 40
    - Passes validation: 30
    - Cross-referenced: 20
    - Total: 90% confidence
    """
    score = 0
    
    # Check completeness
    required_fields = [
        'cropName', 'growthMetrics', 'growingConditions',
        'hydroponicTechniques', 'marketData'
    ]
    present_fields = sum(1 for f in required_fields if f in extracted_data)
    score += (present_fields / len(required_fields)) * 40
    
    # Check validity
    if validate_data(extracted_data):
        score += 30
    
    # Check cross-references
    if check_against_known_data(extracted_data):
        score += 20
    
    return score
```

### Manual Review Process

**When to trigger manual review:**
- Confidence < 85%
- First extraction of a new crop type
- Unusual values or edge cases
- Different data from same crop from multiple sources

**Review Dashboard:**
```javascript
// Simple review interface
{
  pending_crop_id: "pending_crop_2026_02_01",
  extracted_data: { /* ... */ },
  
  review_checklist: [
    "Crop name is correct",
    "All temperatures in realistic range",
    "pH values 0-14",
    "Growth days > 0",
    "Yield > 0",
    "At least one hydroponic technique selected"
  ],
  
  reviewer_actions: [
    "approve",
    "approve_with_corrections",
    "reject",
    "needs_more_info"
  ]
}
```

### Data Deduplication
```python
def check_duplicate_crop(new_crop):
    """
    Before storage, check:
    1. Exact name match
    2. Fuzzy name match (similarity > 0.9)
    3. Similar characteristics
    
    If duplicate found: Merge or mark variant
    """
    from fuzzywuzzy import fuzz
    
    existing_crops = db.collection('crops').stream()
    for crop in existing_crops:
        ratio = fuzz.token_sort_ratio(
            new_crop['cropName'],
            crop['cropName']
        )
        if ratio > 90:
            return crop.id
    
    return None
```

---

## Step-by-Step Implementation

### Step 1: Set up Backend Project Structure
```
backend/
├── app.py
├── requirements.txt
├── config.py
├── .env
│
├── services/
│   ├── extraction_service.py    # NLP extraction logic
│   ├── validation_service.py    # Data validation
│   ├── firestore_service.py     # DB operations
│   └── pdf_processor.py         # PDF/document handling
│
├── models/
│   ├── crop_model.py            # Pydantic validation models
│   └── extraction_model.py
│
├── routes/
│   ├── crops_routes.py          # Upload, extract, review endpoints
│   └── admin_routes.py          # Admin review interface
│
├── ml/
│   ├── extractors.py            # Pattern matching & NLP
│   └── patterns.py              # Regex patterns
│
└── templates/
    └── review_dashboard.html    # Manual review UI (simple)
```

### Step 2: Install Dependencies
```bash
pip install -r requirements.txt

# Core
pip install Flask==2.3.0
pip install python-dotenv==1.0.0

# PDF Processing
pip install PyPDF2==3.0.1
pip install pdfplumber==0.9.0
pip install pytesseract==0.3.10
pip install Pillow==10.0.0

# NLP
pip install spacy==3.6.0
pip install python-Levenshtein==0.21.1
pip install fuzzywuzzy==0.18.0

# Database
pip install firebase-admin==6.1.0

# Validation
pip install pydantic==2.0.0
pip install jsonschema==4.18.0

# Optional: LLM (only if using OpenAI)
# pip install openai==0.27.0
# pip install langchain==0.0.200
```

### Step 3: Create Pydantic Models for Validation
```python
# models/crop_model.py

from pydantic import BaseModel, validator
from typing import Optional, List, Dict

class PHRange(BaseModel):
    min: float
    max: float
    optimal: float
    
    @validator('min', 'max', 'optimal')
    def valid_ph(cls, v):
        if not (0 <= v <= 14):
            raise ValueError('pH must be between 0 and 14')
        return v

class TemperatureRange(BaseModel):
    min: int
    max: int
    optimal: int
    unit: str = "celsius"
    
    @validator('min', 'max', 'optimal')
    def valid_temp(cls, v):
        if not (-50 <= v <= 60):
            raise ValueError('Unrealistic temperature')
        return v

class GrowthMetrics(BaseModel):
    seedToHarvest_days: int
    yield_per_sqm: float
    expected_plants_per_sqm: float
    
    @validator('seedToHarvest_days')
    def positive_days(cls, v):
        if v <= 0:
            raise ValueError('Days must be positive')
        return v

class CropData(BaseModel):
    cropName: str
    cropId: str
    growingConditions: dict
    growthMetrics: GrowthMetrics
    hydroponicTechniques: dict
    marketData: dict
    
    class Config:
        # Pydantic config
        pass
```

### Step 4: Create Extraction Service
```python
# services/extraction_service.py

import re
import spacy
from fuzzywuzzy import fuzz

class CropExtractionService:
    
    def __init__(self):
        self.nlp = spacy.load("en_core_web_sm")
        self.patterns = self._load_patterns()
    
    def extract_from_text(self, text: str) -> dict:
        """Main extraction method"""
        extracted = {}
        
        # Extract each field
        extracted['cropName'] = self._extract_crop_name(text)
        extracted['temperature'] = self._extract_temperature(text)
        extracted['ph'] = self._extract_ph(text)
        extracted['growth_days'] = self._extract_growth_days(text)
        extracted['yield'] = self._extract_yield(text)
        extracted['lighting'] = self._extract_lighting(text)
        
        return extracted
    
    def _extract_crop_name(self, text: str) -> str:
        """Extract crop name from text"""
        # Most common pattern: "Growing X", "Cultivation of X", "X production"
        patterns = [
            r'(?:Growing|Cultivating|Production of|Hydroponic)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',
            r'([A-Z][a-z]+)\s+(?:production|cultivation|growing|hydroponics)',
        ]
        
        for pattern in patterns:
            matches = re.finditer(pattern, text, re.IGNORECASE)
            for match in matches:
                crop_name = match.group(1)
                if len(crop_name) > 2:  # Filter out noise
                    return crop_name
        
        return None
    
    def _extract_temperature(self, text: str) -> dict:
        """Extract temperature range"""
        patterns = [
            r'temperature[s]?\s*:?\s*(\d+)\s*[-–]\s*(\d+)\s*°?[Cc]',
            r'(\d+)\s*[-–]\s*(\d+)\s*°?C',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return {
                    'min': int(match.group(1)),
                    'max': int(match.group(2))
                }
        
        return None
    
    def _extract_ph(self, text: str) -> dict:
        """Extract pH range"""
        patterns = [
            r'pH\s*:?\s*(\d+\.?\d*)\s*[-–]\s*(\d+\.?\d*)',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return {
                    'min': float(match.group(1)),
                    'max': float(match.group(2))
                }
        
        return None
    
    def _extract_growth_days(self, text: str) -> int:
        """Extract days to harvest"""
        patterns = [
            r'(\d+)\s*(?:to|–|-|and)\s*(\d+)\s*days?\s*to\s*harvest',
            r'harvest\s*in\s*(\d+)\s*(?:to|–|-)\s*(\d+)\s*days',
            r'(\d+)\s*days?\s*(?:to|until)\s*(?:harvest|maturity)',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                if len(match.groups()) == 2:
                    # Average of range
                    return (int(match.group(1)) + int(match.group(2))) // 2
                else:
                    return int(match.group(1))
        
        return None
    
    def _extract_yield(self, text: str) -> float:
        """Extract expected yield"""
        patterns = [
            r'yield[s]?\s*:?\s*(\d+\.?\d*)\s*kg(?:/m²|\/m²|per\s+m²)',
            r'(\d+\.?\d*)\s*kg(?:/m²|\/m²|per\s+m²)',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return float(match.group(1))
        
        return None
    
    def _extract_lighting(self, text: str) -> dict:
        """Extract lighting requirements"""
        patterns = [
            r'(\d+)\s*hours?\s*of\s*light',
            r'light\s*requirement[s]?\s*:?\s*(\d+)\s*hours?',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return {'daily_hours': int(match.group(1))}
        
        return None
    
    def _load_patterns(self):
        """Load all extraction patterns"""
        return {
            'temperature': [...],
            'ph': [...],
            # ... more patterns
        }
```

### Step 5: Create Flask API Routes
```python
# routes/crops_routes.py

from flask import Blueprint, request, jsonify
from werkzeug.utils import secure_filename
from services.extraction_service import CropExtractionService
from services.validation_service import validate_crop_data
from services.firestore_service import save_crop, save_pending_crop

crops_bp = Blueprint('crops', __name__, url_prefix='/api/crops')
extraction_service = CropExtractionService()

@crops_bp.route('/upload-source', methods=['POST'])
def upload_source():
    """
    Upload a research paper or article
    
    POST /api/crops/upload-source
    {
        "file": <PDF/DOCX>,
        "source_type": "research_paper",
        "metadata": {...}
    }
    """
    
    # Check if file exists
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    # Save file temporarily
    filename = secure_filename(file.filename)
    filepath = f'temp/{filename}'
    file.save(filepath)
    
    try:
        # Extract text from PDF
        text = extract_text_from_pdf(filepath)
        
        # Extract crop data
        extracted_data = extraction_service.extract_from_text(text)
        
        # Validate data
        validation_result = validate_crop_data(extracted_data)
        
        if validation_result['valid']:
            # Save to pending crops collection
            pending_id = save_pending_crop(
                extracted_data,
                confidence=validation_result['confidence'],
                source_file=filename
            )
            
            return jsonify({
                'success': True,
                'pending_id': pending_id,
                'confidence': validation_result['confidence'],
                'requires_review': validation_result['confidence'] < 85
            }), 200
        else:
            return jsonify({
                'error': 'Validation failed',
                'issues': validation_result['errors']
            }), 400
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
    finally:
        # Clean up temp file
        import os
        os.remove(filepath)

@crops_bp.route('/pending', methods=['GET'])
def get_pending_crops():
    """Get all pending crops awaiting review"""
    from services.firestore_service import get_pending_crops
    
    pending = get_pending_crops()
    return jsonify(pending), 200

@crops_bp.route('/pending/<pending_id>/review', methods=['POST'])
def review_pending_crop(pending_id):
    """
    Approve or reject pending crop
    
    POST /api/crops/pending/{id}/review
    {
        "action": "approve" | "reject" | "approve_with_corrections",
        "corrections": {...},
        "reviewer_notes": "..."
    }
    """
    
    data = request.get_json()
    action = data.get('action')
    
    from services.firestore_service import update_pending_crop_status
    
    if action == 'approve':
        # Move from pending to approved crops collection
        result = update_pending_crop_status(
            pending_id,
            'approved',
            reviewer_notes=data.get('reviewer_notes')
        )
        return jsonify({'success': True, 'message': 'Crop approved'}), 200
    
    elif action == 'approve_with_corrections':
        # Update pending crop with corrections and approve
        corrections = data.get('corrections', {})
        result = update_pending_crop_status(
            pending_id,
            'approved',
            corrections=corrections,
            reviewer_notes=data.get('reviewer_notes')
        )
        return jsonify({'success': True, 'message': 'Crop approved with corrections'}), 200
    
    elif action == 'reject':
        result = update_pending_crop_status(
            pending_id,
            'rejected',
            reviewer_notes=data.get('reviewer_notes')
        )
        return jsonify({'success': True, 'message': 'Crop rejected'}), 200
    
    return jsonify({'error': 'Invalid action'}), 400

@crops_bp.route('/all', methods=['GET'])
def get_all_crops():
    """Get all approved crops (for Flutter display)"""
    from services.firestore_service import get_all_crops
    
    crops = get_all_crops()
    return jsonify(crops), 200
```

### Step 6: Firestore Integration
```python
# services/firestore_service.py

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

# Initialize Firebase (if not already done in main app)
db = firestore.client()

def save_pending_crop(extracted_data: dict, confidence: float, source_file: str) -> str:
    """Save to pending collection for review"""
    
    pending_crop = {
        'raw_extracted_data': extracted_data,
        'extraction_confidence': confidence,
        'status': 'pending_review',
        'source_document': source_file,
        'creation_date': datetime.now().isoformat(),
        'reviewer_notes': None
    }
    
    # Add to collection
    doc_ref = db.collection('pending_crops').add(pending_crop)
    return doc_ref[1].id  # Return document ID

def save_crop(crop_data: dict, reviewed: bool = False) -> str:
    """Save approved crop to main collection"""
    
    # Generate crop ID
    crop_id = f"crop_{crop_data['cropName'].lower().replace(' ', '_')}"
    
    crop_document = {
        **crop_data,
        'cropId': crop_id,
        'created_at': datetime.now().isoformat(),
        'updated_at': datetime.now().isoformat(),
        'active': True,
        'metadata': {
            'reviewed': reviewed,
            'extraction_method': 'nlp_template_based',
            'version': 1
        }
    }
    
    # Set with custom ID
    db.collection('crops').document(crop_id).set(crop_document)
    return crop_id

def update_pending_crop_status(pending_id: str, status: str, 
                               corrections: dict = None, 
                               reviewer_notes: str = None) -> bool:
    """Update pending crop status"""
    
    pending_ref = db.collection('pending_crops').document(pending_id)
    
    if status == 'approved':
        # Get pending crop data
        pending_doc = pending_ref.get()
        extracted_data = pending_doc.get('raw_extracted_data')
        
        # Apply corrections if provided
        if corrections:
            extracted_data.update(corrections)
        
        # Save to approved crops
        save_crop(extracted_data, reviewed=True)
    
    # Update pending document
    pending_ref.update({
        'status': status,
        'review_date': datetime.now().isoformat(),
        'reviewer_notes': reviewer_notes
    })
    
    return True

def get_pending_crops():
    """Get all pending crops"""
    docs = db.collection('pending_crops')\
             .where('status', '==', 'pending_review')\
             .stream()
    
    crops = []
    for doc in docs:
        crop_data = doc.to_dict()
        crop_data['id'] = doc.id
        crops.append(crop_data)
    
    return crops

def get_all_crops():
    """Get all approved crops"""
    docs = db.collection('crops').where('active', '==', True).stream()
    
    crops = []
    for doc in docs:
        crop_data = doc.to_dict()
        crop_data['id'] = doc.id
        crops.append(crop_data)
    
    return crops
```

### Step 7: Create Flutter UI Components

#### Firestore Models (Dart)
```dart
// lib/data/models/crop_model.dart

class Crop {
  final String cropId;
  final String cropName;
  final List<String> commonNames;
  
  final Map<String, HydroponicTechnique> hydroponicTechniques;
  
  final GrowingConditions growingConditions;
  final GrowthMetrics growthMetrics;
  final NutrientProfile nutrients;
  
  final MarketData marketData;
  final DifficultyLevel difficulty;
  
  final String description;
  final List<String> advantages;
  final List<String> challenges;
  
  final DateTime createdAt;
  final bool active;

  Crop({
    required this.cropId,
    required this.cropName,
    required this.commonNames,
    required this.hydroponicTechniques,
    required this.growingConditions,
    required this.growthMetrics,
    required this.nutrients,
    required this.marketData,
    required this.difficulty,
    required this.description,
    required this.advantages,
    required this.challenges,
    required this.createdAt,
    this.active = true,
  });

  factory Crop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Crop(
      cropId: data['cropId'],
      cropName: data['cropName'],
      commonNames: List<String>.from(data['commonNames'] ?? []),
      // ... map other fields
    );
  }
}

class GrowingConditions {
  final PHRange phRange;
  final TemperatureRange temperatureRange;
  final LightRequirement lightRequirement;
  final WaterRequirement waterRequirement;

  GrowingConditions({
    required this.phRange,
    required this.temperatureRange,
    required this.lightRequirement,
    required this.waterRequirement,
  });
}

class PHRange {
  final double min;
  final double max;
  final double optimal;

  PHRange({required this.min, required this.max, required this.optimal});
}

// ... other model classes
```

#### Crop Display Widget
```dart
// lib/features/crop_recommendation/presentation/widgets/crop_card.dart

class CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback onTap;

  const CropCard({
    required this.crop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(crop.cropName),
        subtitle: Text(crop.description),
        trailing: Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
```

#### Crop Filter Widget
```dart
// lib/features/crop_recommendation/presentation/widgets/crop_filter.dart

class CropFilters {
  List<String>? hydroponicTechniques;
  List<String>? growingSeasons;
  RangeValues? growthDuration;
  RangeValues? profitMargin;
  String? marketDemand;
  String? difficultyLevel;
}

class CropFilterPanel extends StatefulWidget {
  final Function(CropFilters) onFilterApplied;

  const CropFilterPanel({required this.onFilterApplied});

  @override
  State<CropFilterPanel> createState() => _CropFilterPanelState();
}

class _CropFilterPanelState extends State<CropFilterPanel> {
  final filters = CropFilters();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hydroponic Technique Checkboxes
          Text('Hydroponic Technique'),
          ..._buildTechniqueCheckboxes(),
          
          // Season Selector
          Text('Growing Season'),
          ..._buildSeasonCheckboxes(),
          
          // Growth Duration Slider
          Text('Growth Duration (days)'),
          RangeSlider(
            values: filters.growthDuration ?? RangeValues(0, 180),
            onChanged: (RangeValues values) {
              setState(() => filters.growthDuration = values);
            },
          ),
          
          // Profit Margin Slider
          Text('Profit Margin (%)'),
          RangeSlider(
            values: filters.profitMargin ?? RangeValues(0, 100),
            onChanged: (RangeValues values) {
              setState(() => filters.profitMargin = values);
            },
          ),
          
          // Apply Button
          ElevatedButton(
            onPressed: () => widget.onFilterApplied(filters),
            child: Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTechniqueCheckboxes() {
    final techniques = ['NFT', 'DWC', 'Drip', 'Aeroponics', 'Kratky'];
    return techniques.map((technique) {
      return CheckboxListTile(
        title: Text(technique),
        value: filters.hydroponicTechniques?.contains(technique) ?? false,
        onChanged: (bool? value) {
          setState(() {
            filters.hydroponicTechniques ??= [];
            if (value ?? false) {
              filters.hydroponicTechniques!.add(technique);
            } else {
              filters.hydroponicTechniques!.remove(technique);
            }
          });
        },
      );
    }).toList();
  }

  // ... similar for other filters
}
```

#### Crop Repository (Firestore Query)
```dart
// lib/data/repositories/crop_repository.dart

class CropRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Crop>> getAllCrops() async {
    final snapshot = await _firestore
        .collection('crops')
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Crop.fromFirestore(doc))
        .toList();
  }

  Future<List<Crop>> filterCrops(CropFilters filters) async {
    Query query = _firestore.collection('crops').where('active', isEqualTo: true);

    // Filter by hydroponic technique
    if (filters.hydroponicTechniques?.isNotEmpty ?? false) {
      query = query.where(
        'hydroponicTechniques',
        arrayContainsAny: filters.hydroponicTechniques,
      );
    }

    // Filter by season
    if (filters.growingSeasons?.isNotEmpty ?? false) {
      query = query.where(
        'marketData.bestSeason',
        whereIn: filters.growingSeasons,
      );
    }

    // Filter by difficulty
    if (filters.difficultyLevel != null) {
      query = query.where(
        'difficulty.level',
        isEqualTo: filters.difficultyLevel,
      );
    }

    // Note: Range filters (growth duration, profit margin) 
    // need to be performed in-memory due to Firestore limitations

    final snapshot = await query.get();
    var crops = snapshot.docs
        .map((doc) => Crop.fromFirestore(doc))
        .toList();

    // Apply range filters in-memory
    if (filters.growthDuration != null) {
      crops = crops.where((crop) {
        final days = crop.growthMetrics.seedToHarvest_days;
        return days >= filters.growthDuration!.start &&
            days <= filters.growthDuration!.end;
      }).toList();
    }

    if (filters.profitMargin != null) {
      crops = crops.where((crop) {
        final margin = crop.marketData.estimated_profit_margin_percent;
        return margin >= filters.profitMargin!.start &&
            margin <= filters.profitMargin!.end;
      }).toList();
    }

    return crops;
  }
}
```

---

## Summary & Recommendations

### Methodology Recap
1. **NOT manual entry** ✅ — Use automated extraction
2. **Hybrid extraction** ✅ — Combine regex + NLP + optional LLM
3. **Quality gates** ✅ — Automatic validation + optional manual review
4. **Structured Firestore** ✅ — Well-defined schema for filtering
5. **Python backend** ✅ — Best for document processing & NLP

### Technology Stack
| Component | Technology | Why |
|-----------|-----------|-----|
| Document Processing | PyPDF2 + pdfplumber | Reliable PDF text extraction |
| NLP | spaCy + Regex | 80% extraction without overcomplexity |
| Optional LLM | OpenAI/Claude API | Only for <15% edge cases |
| Backend | Flask/FastAPI | Simple, integrates with Firebase |
| Database | Firestore | Real-time updates for Flutter |
| Frontend | Flutter + Firestore SDK | Native mobile, real-time filtering |

### Implementation Timeline
- **Week 1:** Backend setup + PDF extraction
- **Week 2:** Pattern matching + spaCy extraction
- **Week 3:** Firestore integration + validation
- **Week 4:** Manual review dashboard + Flutter integration
- **Week 5:** Testing + optimization

### Cost Estimates (Optional)
- **No LLM needed:** FREE
- **With LLM (OpenAI):** ~$0.01-0.05 per document
- **Tesseract OCR:** FREE
- **Firebase (100 crops):** ~$1-2/month

### Next Steps
1. Create backend project structure
2. Implement PDF extraction service
3. Build pattern matching library
4. Set up Firestore collections
5. Create Flutter UI for filtering
6. Test with sample research papers

---
