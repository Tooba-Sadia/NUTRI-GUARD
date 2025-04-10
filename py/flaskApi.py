# allergen_api.py

from flask import Flask, request, jsonify
from ingredient_analysis import IngredientAnalyzer

app = Flask(__name__)
analyzer = IngredientAnalyzer()

@app.route('/check_allergens/', methods=['POST'])
def check_allergens():
    data = request.get_json()
    ingredients = data.get('ingredients', '')
    result = analyzer.analyze_ingredients(ingredients)
    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5050)
