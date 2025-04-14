import pandas as pd

# Load your dataset
df = pd.read_csv(r'C:\Users\PMLS\Downloads\NUTRI-GUARD\py\allergen.csv')
# Step 1: Combine ingredient-related columns into a single string
ingredient_columns = ['Main Ingredient', 'Sweetener', 'Fat/Oil', 'Seasoning']
df['Combined_Ingredients'] = df[ingredient_columns].fillna('').agg(', '.join, axis=1)

# Step 2: Convert 'Prediction' column to binary label
# 'Contains' => 1 (allergen present), others => 0
df['Label'] = df['Prediction'].apply(
    lambda x: 1 if str(x).strip().lower() == 'contains' else 0
)

# Step 3: Keep only what's needed
cleaned_df = df[['Combined_Ingredients', 'Label']]

# Step 4: Save cleaned data to new CSV
cleaned_df.to_csv("cleaned_allergen_dataset.csv", index=False)

print("✅ Preprocessing complete! Cleaned data saved to 'cleaned_allergen_dataset.csv'")
