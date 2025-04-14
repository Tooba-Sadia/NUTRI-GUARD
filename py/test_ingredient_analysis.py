# filepath: c:\Users\PMLS\Downloads\NUTRI-GUARD\py\test_ingredient_analysis.py
from ingredient_analysis import IngredientAnalyzer

# Initialize the analyzer with the dataset
analyzer = IngredientAnalyzer(csv_path='cleaned_allergen_dataset.csv')

# Test case: Analyze a sample ingredient list
sample_ingredients = "sugar, honey, butter, salt"
result = analyzer.analyze_ingredients(sample_ingredients)

# Print the results
#print("Allergens Found:", result['allergens_found'])
print("High-Risk Ingredients:", result['high_risk_ingredients'],"\n\n\n\n\n\n")
print("Potential Risks:", result['potential_risks'])