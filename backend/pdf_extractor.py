import pdfplumber
import re

class CropDataExtractor:

    def extract_from_pdf(self, pdf_path):
        crops = []

        with pdfplumber.open(pdf_path) as pdf:
            for page in pdf.pages:
                text = page.extract_text()

                if not text:
                    continue

                crop_name = re.search(r'Crop:\s*(.*)', text)
                temp = re.search(r'Temperature:\s*(\d+)-(\d+)', text)
                ph = re.search(r'pH Range:\s*(\d+\.\d+)-(\d+\.\d+)', text)
                days = re.search(r'Days to Harvest:\s*(\d+)', text)
                yield_match = re.search(r'Yield:\s*(\d+)', text)
                profit = re.search(r'Profit Margin:\s*(\d+)', text)
                difficulty = re.search(r'Difficulty:\s*(.*)', text)

                if crop_name:
                    crops.append({
                        "name": crop_name.group(1),
                        "temperature_min": int(temp.group(1)) if temp else 15,
                        "temperature_max": int(temp.group(2)) if temp else 30,
                        "ph_min": float(ph.group(1)) if ph else 6.0,
                        "ph_max": float(ph.group(2)) if ph else 6.8,
                        "days_to_harvest": int(days.group(1)) if days else 45,
                        "yield_per_sqm": int(yield_match.group(1)) if yield_match else 20,
                        "profit_margin": int(profit.group(1)) if profit else 50,
                        "difficulty_level": difficulty.group(1).lower() if difficulty else "beginner"
                    })

        return {"crops": crops}
