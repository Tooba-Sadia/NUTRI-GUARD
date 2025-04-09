# allergen_api.py

from flask import Flask, request, jsonify

app = Flask(__name__)

# Sample allergen list (later Kaggle dataset)
allergen_keywords = ['milk', 'wheat', 'peanut', 'egg', 'soy', 'nuts', 'fish', 'gluten']

def detect_allergens(ingredients_text):
    found = []
    for allergen in allergen_keywords:
        if allergen in ingredients_text.lower():
            found.append(allergen)
    return found

@app.route('/check_allergens/', methods=['POST'])
def check_allergens():
    data = request.get_json()
    ingredients = data.get('ingredients', '')
    result = detect_allergens(ingredients)
    return jsonify({"allergens_found": result})

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5050)
