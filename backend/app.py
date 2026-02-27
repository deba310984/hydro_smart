from flask import Flask, request, jsonify
import os
from pdf_extractor import CropDataExtractor
from database import FirestoreDB

app = Flask(__name__)
extractor = CropDataExtractor()
db = FirestoreDB()

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/health")
def health():
    return {"status": "healthy"}

@app.route("/api/v1/upload-crop-pdf", methods=["POST"])
def upload_pdf():
    file = request.files["file"]
    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    result = extractor.extract_from_pdf(filepath)

    for crop in result["crops"]:
        db.save_crop(crop)

    os.remove(filepath)

    return jsonify({
        "saved_crops": len(result["crops"])
    })

@app.route("/api/v1/crops")
def get_crops():
    crops = db.get_all_crops()
    return jsonify(crops)

if __name__ == "__main__":
    app.run(port=5000)
