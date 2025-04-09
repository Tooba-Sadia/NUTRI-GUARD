import pandas as pd


df = pd.read_csv(r'C:\Users\PMLS\OneDrive - University of Engineering and Technology Taxila\Documents\NUTRIGUARD\NUTRIGUARD\py\allergen.csv')
#print(df.head())
#explanation: remove special characters and convert to lowercase.
# anything that is NOT a letter, comma, or space.
#df['ingredients'] = df['Main Ingredient'].str.lower().str.replace(r'[^a-zA-Z, ]','', regex=True)

#print(df.head())
ocr_ingredients = "milk, sugar, wheat flour, cocoa powder"
allergens = ['milk', 'egg', 'fish', 'crustacean', 'tree nut', 'peanut', 'wheat', 'soybean']

def detect_allergens(ocr_ingredients):
    found_allergens = []
    for allergen in allergens:
        if allergen in ocr_ingredients.lower():
            found_allergens.append(allergen)
    return found_allergens

detected = detect_allergens(ocr_ingredients)
print("Detected Allergens:", detected)