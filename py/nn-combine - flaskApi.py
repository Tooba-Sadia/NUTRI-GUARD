# allergen_api.py

from flask import Flask, request, jsonify
from ingredient_analysis import IngredientAnalyzer
from AllergenClassifier import AllergenClassifier  # Import the classifier

app = Flask(__name__)

# Initialize the IngredientAnalyzer and AllergenClassifier
analyzer = IngredientAnalyzer()
classifier = AllergenClassifier(model_path='C:/Users/PMLS/Downloads/NUTRI-GUARD/myapp/assets/model.tflite')
classifier.interpreter.allocate_tensors()  # Ensure the TFLite model is loaded

@app.route('/check_allergens/', methods=['POST'])
def check_allergens():
    # Get JSON data from the request
    data = request.get_json()
    ingredients = data.get('ingredients', '')

    # Analyze the ingredients using both fuzzy matching and TFLite model
    result = analyzer.analyze_ingredients(ingredients, classifier)  # Pass classifier as positional argument

    # Return the result as JSON
    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5050)
