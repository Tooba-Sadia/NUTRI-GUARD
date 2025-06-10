import pandas as pd
import numpy as np
from collections import defaultdict
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from fuzzywuzzy import fuzz

class IngredientAnalyzer:
    """
    A class to analyze ingredients and their associated allergens from a dataset.
    Provides methods to map ingredients to allergens and analyze ingredient lists.
    """

    def __init__(self, csv_path=r'C:\Users\PMLS\Downloads\NUTRI-GUARD\py\cleaned_allergen_dataset.csv'):
        """
        Initialize the analyzer with the allergen dataset.
        Load the dataset into a pandas DataFrame and create mappings and vectors.
        """
        self.df = pd.read_csv(csv_path)  # Load allergen dataset
        print("Columns in the dataset:", self.df.columns)
        # Create mapping between ingredients and their allergens
        self.ingredient_allergen_map = self._create_ingredient_allergen_map()
        # Initialize TF-IDF vectorizer with unigrams and bigrams
        #bigrams so that we can match ingredients like "peanut butter" and "almond milk"
        self.vectorizer = TfidfVectorizer(ngram_range=(1, 2))
        # Create vectors for ingredient matching
        self._create_ingredient_vectors()

    def _create_ingredient_vectors(self):
        
        #Create TF-IDF vectors for ingredient matching.
        
        # Get list of all known ingredients
        ingredients = list(self.ingredient_allergen_map.keys())
        # Convert ingredients to TF-IDF vectors for similarity matching
        self.ingredient_vectors = self.vectorizer.fit_transform([
            ' '.join(ing.split()) for ing in ingredients # single space between words
        ])
        self.known_ingredients = ingredients  # Store for later reference

    def _find_similar_ingredients(self, ingredient, threshold=0.6):
        """
        Find similar ingredients using TF-IDF and fuzzy matching.
        """
        # Convert input ingredient to vector
        ingredient_vector = self.vectorizer.transform([ingredient])
        # Calculate similarity with all known ingredients
        '''[0] is used to: Extract the first (and only) row of the 2D array returned by cosine_similarity'''
        similarities = cosine_similarity(ingredient_vector, self.ingredient_vectors)[0]
        
        similar_ingredients = []
        for idx, score in enumerate(similarities):
            # Add ingredients that meet vector similarity threshold
            if score > threshold:
                similar_ingredients.append(self.known_ingredients[idx])
            
            # Use fuzzy string matching as backup method
            fuzzy_score = fuzz.ratio(ingredient, self.known_ingredients[idx]) / 100
            if fuzzy_score > threshold and self.known_ingredients[idx] not in similar_ingredients:
                similar_ingredients.append(self.known_ingredients[idx])
        
        return similar_ingredients

    def _create_ingredient_allergen_map(self):
        """
        Create enhanced ingredient-allergen mapping with context.
        """
        # Create dictionary with nested structure for allergens and context
        mapping = defaultdict(lambda: {'allergens': set(), 'context': []})

        for _, row in self.df.iterrows():
            # Get the combined ingredients and label
            combined_ingredients = str(row['Combined_Ingredients']).lower().split(', ')
            label = row['Label']  # 1 indicates allergen present, 0 indicates no allergen

            # Map each ingredient to its allergens and context
            for ingredient in combined_ingredients:
                if ingredient and ingredient != 'none':  # Skip empty or invalid ingredients
                    mapping[ingredient]['allergens'].add('allergen' if label == 1 else 'no allergen')
                    mapping[ingredient]['context'].append(combined_ingredients)

        return mapping

    def analyze_ingredients(self, ingredients_text, tflite_classifier):
        """
        Enhanced ingredient analysis with context, similarity matching, and TFLite model inference.
        Args:
            ingredients_text (str): Comma-separated list of ingredients to analyze.
            tflite_classifier (AllergenClassifier): Instance of the TFLite classifier.
        Returns:
            dict: Dictionary containing:
                - 'allergens_found': List of unique allergens found
                - 'high_risk_ingredients': List of dictionaries containing high-risk ingredients
                  and their associated allergens
                - 'potential_risks': List of dictionaries containing potential risks based on
                  similar ingredients and their associated allergens
                - 'model_prediction': TFLite model's prediction for the input text
        """
        print("Ingredients text:", ingredients_text)
        # Split and clean input ingredients
        ingredients = [i.strip().lower() for i in ingredients_text.split(',')]
        found_allergens = set()  # Track unique allergens
        high_risk_ingredients = []  # Track direct matches
        potential_risks = []  # Track similar ingredient matches

        # Use the TFLite model to predict allergen status for the entire input
        model_prediction = tflite_classifier.predict(ingredients_text)

        for ingredient in ingredients:
            # Check for exact matches in the database
            if ingredient in self.ingredient_allergen_map:
                allergens = self.ingredient_allergen_map[ingredient]['allergens']
                if allergens:  # If allergens found
                    found_allergens.update(allergens)
                    high_risk_ingredients.append({
                        'ingredient': ingredient,
                        'allergens': list(allergens),
                        'confidence': 'high',  # Direct match = high confidence
                        'found_in': self.ingredient_allergen_map[ingredient]['context'][:3]
                    })

            # Check for similar ingredients that might indicate allergens
            similar_ingredients = self._find_similar_ingredients(ingredient)
            for similar_ing in similar_ingredients:
                if similar_ing != ingredient:  # Avoid duplicate matches
                    allergens = self.ingredient_allergen_map[similar_ing]['allergens']
                    if allergens:  # If allergens found in similar ingredient
                        potential_risks.append({
                            'ingredient': ingredient,
                            'similar_to': similar_ing,
                            'allergens': list(allergens),
                            'confidence': 'medium',  # Similar match = medium confidence
                            'found_in': self.ingredient_allergen_map[similar_ing]['context'][:3]
                        })

        # Combine results from fuzzy matching and TFLite model
        final_decision = "Allergen" if model_prediction == "Allergen" or found_allergens else "Non-Allergen"

        # Return comprehensive analysis results
        return {
            'allergens_found': list(found_allergens),
            'high_risk_ingredients': high_risk_ingredients,
            'potential_risks': potential_risks,
            'model_prediction': model_prediction,
            'final_decision': final_decision
        }