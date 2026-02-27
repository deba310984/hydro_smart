"""
Backend API Testing Script for Hydro Smart
Run this to test all endpoints locally
"""

import requests
import json
import time

BASE_URL = "http://localhost:5000"

def test_health():
    """Test health endpoint"""
    print("\n🔍 Testing: GET /api/v1/health")
    print("-" * 50)
    try:
        response = requests.get(f"{BASE_URL}/api/v1/health")
        print(f"Status: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_get_all_crops():
    """Test fetch all crops"""
    print("\n🌱 Testing: GET /api/v1/crops")
    print("-" * 50)
    try:
        response = requests.get(f"{BASE_URL}/api/v1/crops")
        print(f"Status: {response.status_code}")
        data = response.json()
        print(f"Total crops: {data.get('total', 0)}")
        if data.get('crops'):
            print(f"First crop: {data['crops'][0]}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_search_crops():
    """Test search crops"""
    print("\n🔎 Testing: GET /api/v1/crops/search?q=tomato")
    print("-" * 50)
    try:
        response = requests.get(f"{BASE_URL}/api/v1/crops/search", params={'q': 'tomato'})
        print(f"Status: {response.status_code}")
        data = response.json()
        print(f"Found: {data.get('total', 0)} crops")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_filter_by_difficulty():
    """Test filter crops by difficulty"""
    print("\n⭐ Testing: GET /api/v1/crops/search?difficulty=beginner")
    print("-" * 50)
    try:
        response = requests.get(
            f"{BASE_URL}/api/v1/crops/search",
            params={'difficulty': 'beginner'}
        )
        print(f"Status: {response.status_code}")
        data = response.json()
        print(f"Beginner crops: {data.get('total', 0)}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_upload_pdf(pdf_path):
    """Test PDF upload"""
    print(f"\n📄 Testing: POST /api/v1/upload-crop-pdf")
    print("-" * 50)
    try:
        with open(pdf_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/api/v1/upload-crop-pdf", files=files)
        
        print(f"Status: {response.status_code}")
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
        return response.status_code == 200
    except FileNotFoundError:
        print(f"❌ PDF file not found: {pdf_path}")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def run_all_tests(pdf_path=None):
    """Run all tests"""
    print("=" * 50)
    print("HYDRO SMART BACKEND API TESTS")
    print("=" * 50)
    
    results = {}
    
    # Test 1: Health
    results['health'] = test_health()
    time.sleep(0.5)
    
    # Test 2: Get all crops
    results['get_crops'] = test_get_all_crops()
    time.sleep(0.5)
    
    # Test 3: Search crops
    results['search_crops'] = test_search_crops()
    time.sleep(0.5)
    
    # Test 4: Filter by difficulty
    results['filter_difficulty'] = test_filter_by_difficulty()
    time.sleep(0.5)
    
    # Test 5: PDF upload (optional)
    if pdf_path:
        results['upload_pdf'] = test_upload_pdf(pdf_path)
    
    # Summary
    print("\n" + "=" * 50)
    print("TEST SUMMARY")
    print("=" * 50)
    
    passed = sum(1 for v in results.values() if v)
    total = len(results)
    
    for test_name, passed_test in results.items():
        status = "✅ PASSED" if passed_test else "❌ FAILED"
        print(f"{test_name.replace('_', ' ').title()}: {status}")
    
    print(f"\nTotal: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! Backend is working correctly.")
    else:
        print("\n⚠️  Some tests failed. Check the output above.")

if __name__ == "__main__":
    import sys
    
    print("\n📌 Make sure backend is running: python app.py\n")
    
    # Check if PDF path provided
    pdf_path = sys.argv[1] if len(sys.argv) > 1 else None
    
    try:
        run_all_tests(pdf_path)
    except requests.exceptions.ConnectionError:
        print("\n❌ ERROR: Cannot connect to backend at http://localhost:5000")
        print("Make sure backend is running: python app.py")
        sys.exit(1)
