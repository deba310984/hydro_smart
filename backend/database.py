"""
Firestore Database Integration for Hydro Smart Backend
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
from typing import List, Dict, Optional
import os

class FirestoreDB:
    """Firestore database handler for crop management"""
    
    def __init__(self):
        """Initialize Firestore connection"""
        self.db = None
        self.collection = 'crops'
        self._init_firebase()
    
    def _init_firebase(self):
        """Initialize Firebase Admin SDK"""
        try:
            # Check if already initialized
            if not firebase_admin._apps:
                # Try to get credentials from environment or file
                cred_path = os.getenv('FIREBASE_CREDENTIALS', 'firebase-credentials.json')
                
                if os.path.exists(cred_path):
                    cred = credentials.Certificate(cred_path)
                    firebase_admin.initialize_app(cred)
                    print(f"✓ Firebase initialized with credentials from {cred_path}")
                else:
                    print(f"⚠ Warning: Firebase credentials file not found at {cred_path}")
                    print("  Using default credentials or environment variables")
                    firebase_admin.initialize_app()
            
            self.db = firestore.client()
            print("✓ Firestore database connected")
        except Exception as e:
            print(f"✗ Firebase initialization error: {e}")
            print("  Crops will be stored in memory. Use Firebase Admin SDK for persistence.")
            self.db = None
    
    def check_connection(self) -> bool:
        """Check if database connection is active"""
        try:
            if self.db:
                # Try a simple read to verify connection
                list(self.db.collection(self.collection).limit(1).stream())
                return True
            return False
        except Exception as e:
            print(f"Database connection error: {e}")
            return False
    
    def add_crop(self, crop_data: Dict) -> str:
        """
        Add a crop to Firestore
        
        Args:
            crop_data: Dictionary with crop information
            
        Returns:
            Document ID of the saved crop
        """
        try:
            if not self.db:
                print("✗ Database not connected, using mock storage")
                return f"mock_{datetime.now().timestamp()}"
            
            # Prepare crop data
            crop_doc = {
                'name': crop_data.get('crop_name', crop_data.get('name', 'Unknown')),
                'emoji': crop_data.get('emoji', '🌱'),
                'temperature_range': self._parse_range(crop_data.get('temperature_range', {})),
                'ph_range': self._parse_range(crop_data.get('ph_range', {})),
                'days_to_harvest': crop_data.get('days_to_harvest', 0),
                'yield_per_sqm': crop_data.get('yield_per_sqm', 0),
                'profit_margin': crop_data.get('profit_margin', 0),
                'difficulty_level': crop_data.get('difficulty_level', 'intermediate'),
                'confidence_score': crop_data.get('confidence_score', 0.85),
                'active': True,
                'created_at': datetime.now(),
                'source': crop_data.get('source', 'pdf_upload')
            }
            
            # Add to Firestore
            doc_ref = self.db.collection(self.collection).document()
            doc_ref.set(crop_doc)
            
            print(f"✓ Crop '{crop_doc['name']}' saved with ID: {doc_ref.id}")
            return doc_ref.id
            
        except Exception as e:
            print(f"✗ Error adding crop: {e}")
            raise
    
    def get_all_crops(self) -> List[Dict]:
        """
        Fetch all active crops from Firestore
        
        Returns:
            List of crop documents with their IDs
        """
        try:
            if not self.db:
                return []
            
            crops = []
            docs = self.db.collection(self.collection).where('active', '==', True).stream()
            
            for doc in docs:
                crop_data = doc.to_dict()
                crop_data['id'] = doc.id
                crops.append(crop_data)
            
            print(f"✓ Retrieved {len(crops)} crops from database")
            return crops
            
        except Exception as e:
            print(f"✗ Error fetching crops: {e}")
            return []
    
    def get_crop_by_id(self, crop_id: str) -> Optional[Dict]:
        """
        Fetch single crop by ID
        
        Args:
            crop_id: Document ID of the crop
            
        Returns:
            Crop document or None if not found
        """
        try:
            if not self.db:
                return None
            
            doc = self.db.collection(self.collection).document(crop_id).get()
            
            if doc.exists:
                crop_data = doc.to_dict()
                crop_data['id'] = doc.id
                return crop_data
            else:
                return None
                
        except Exception as e:
            print(f"✗ Error fetching crop {crop_id}: {e}")
            return None
    
    def search_crops(self, query: str = '', difficulty: str = '') -> List[Dict]:
        """
        Search crops by name and/or difficulty
        
        Args:
            query: Search query for crop name
            difficulty: Filter by difficulty level (beginner, intermediate, advanced)
            
        Returns:
            List of matching crops
        """
        try:
            if not self.db:
                return []
            
            results = []
            q = self.db.collection(self.collection).where('active', '==', True)
            
            # Apply difficulty filter
            if difficulty:
                q = q.where('difficulty_level', '==', difficulty.lower())
            
            docs = q.stream()
            
            for doc in docs:
                crop_data = doc.to_dict()
                
                # Apply name search (case-insensitive)
                if query:
                    crop_name = crop_data.get('name', '').lower()
                    if query.lower() not in crop_name:
                        continue
                
                crop_data['id'] = doc.id
                results.append(crop_data)
            
            print(f"✓ Found {len(results)} crops matching criteria")
            return results
            
        except Exception as e:
            print(f"✗ Error searching crops: {e}")
            return []
    
    def update_crop(self, crop_id: str, updates: Dict) -> bool:
        """
        Update crop information
        
        Args:
            crop_id: Document ID of the crop
            updates: Dictionary of fields to update
            
        Returns:
            True if successful, False otherwise
        """
        try:
            if not self.db:
                return False
            
            updates['updated_at'] = datetime.now()
            self.db.collection(self.collection).document(crop_id).update(updates)
            
            print(f"✓ Crop {crop_id} updated successfully")
            return True
            
        except Exception as e:
            print(f"✗ Error updating crop: {e}")
            return False
    
    def delete_crop(self, crop_id: str) -> bool:
        """
        Delete (soft delete) a crop by setting active=False
        
        Args:
            crop_id: Document ID of the crop
            
        Returns:
            True if successful, False otherwise
        """
        try:
            if not self.db:
                return False
            
            self.db.collection(self.collection).document(crop_id).update({
                'active': False,
                'deleted_at': datetime.now()
            })
            
            print(f"✓ Crop {crop_id} deleted successfully")
            return True
            
        except Exception as e:
            print(f"✗ Error deleting crop: {e}")
            return False
    
    def get_crops_by_difficulty(self, difficulty: str) -> List[Dict]:
        """
        Get all crops by difficulty level
        
        Args:
            difficulty: 'beginner', 'intermediate', or 'advanced'
            
        Returns:
            List of crops matching difficulty
        """
        return self.search_crops(difficulty=difficulty)
    
    def get_high_profit_crops(self, min_margin: float = 60.0) -> List[Dict]:
        """
        Get crops with profit margin above threshold
        
        Args:
            min_margin: Minimum profit margin percentage
            
        Returns:
            List of high-profit crops
        """
        try:
            if not self.db:
                return []
            
            crops = []
            docs = (self.db.collection(self.collection)
                    .where('active', '==', True)
                    .where('profit_margin', '>=', min_margin)
                    .stream())
            
            for doc in docs:
                crop_data = doc.to_dict()
                crop_data['id'] = doc.id
                crops.append(crop_data)
            
            return crops
            
        except Exception as e:
            print(f"✗ Error fetching high-profit crops: {e}")
            return []
    
    def _parse_range(self, range_data) -> Dict:
        """
        Helper to parse temperature/pH range data
        
        Args:
            range_data: Range data from PDF extraction
            
        Returns:
            Parsed range dictionary with min, max, optimal
        """
        if isinstance(range_data, dict):
            return range_data
        elif isinstance(range_data, str):
            # Try to parse string format like "20-28°C"
            try:
                parts = range_data.replace('°C', '').replace('°F', '').split('-')
                if len(parts) == 2:
                    return {
                        'min': float(parts[0].strip()),
                        'max': float(parts[1].strip()),
                        'optimal': (float(parts[0].strip()) + float(parts[1].strip())) / 2
                    }
            except:
                pass
        return {'min': 0, 'max': 0, 'optimal': 0}
