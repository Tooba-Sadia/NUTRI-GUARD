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

    def __init__(self, csv_path='allergen.csv'):
        """
        Initialize the analyzer with the allergen dataset.
        Load the dataset into a pandas DataFrame and create mappings and vectors.
        """
        self.df = pd.read_csv(csv_path)  # Load allergen dataset
        # Create mapping between ingredients and their allergens
        self.ingredient_allergen_map = self._create_ingredient_allergen_map()
        # Initialize TF-IDF vectorizer with unigrams and bigrams
        #bigrams so that we can match ingredients like "peanut butter" and "almond milk"
        self.vectorizer = TfidfVectorizer(ngram_range=(1, 2))
        # Create vectors for ingredient matching
        self._create_ingredient_vectors()

    def _create_ingredient_vectors(self):
        """
        Create TF-IDF vectors for ingredient matching.
        """
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
            # Extract all ingredient columns from dataset
            ingredients = [
                str(row['Main Ingredient']),
                str(row['Sweetener']),
                str(row['Fat/Oil']),
                str(row['Seasoning'])
            ]
            
            # Process allergens, handling missing values
            allergens = str(row['Allergens']).split(',') if pd.notna(row['Allergens']) else []
            allergens = [a.strip().lower() for a in allergens]  # Clean allergen names
            
            # Get food product name for context
            food_product = str(row['Food Product']).lower()
            
            # Map each ingredient to its allergens and context
            for ingredient in ingredients:
                if ingredient.lower() != 'none':  # Skip empty ingredients
                    ing_key = ingredient.lower()
                    mapping[ing_key]['allergens'].update(allergens)  # Add allergens
                    mapping[ing_key]['context'].append(food_product)  # Add context
        
        return mapping

    def analyze_ingredients(self, ingredients_text):
        """
        Enhanced ingredient analysis with context and similarity matching.
        Returns:
            dict: Dictionary containing:
                - 'allergens_found': List of unique allergens found
                - 'high_risk_ingredients': List of dictionaries containing high-risk ingredients
                  and their associated allergens
                - 'potential_risks': List of dictionaries containing potential risks based on
                  similar ingredients and their associated allergens
        """
        # Split and clean input ingredients
        ingredients = [i.strip().lower() for i in ingredients_text.split(',')]
        found_allergens = set()  # Track unique allergens
        high_risk_ingredients = []  # Track direct matches
        potential_risks = []  # Track similar ingredient matches

        for ingredient in ingredients:
            # Check for exact matches in database
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

        # Return comprehensive analysis results
        return {
            'allergens_found': list(found_allergens),
            'high_risk_ingredients': high_risk_ingredients,
            'potential_risks': potential_risks
        }