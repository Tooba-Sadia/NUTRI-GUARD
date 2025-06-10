'''import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MultiLabelBinarizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.multioutput import MultiOutputClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline
from sklearn.metrics import classification_report
import joblib

# Load the dataset
df = pd.read_csv('allergen.csv')

# Handle missing values in all relevant columns
df['Food Product'] = df['Food Product'].fillna('')
df['Main Ingredient'] = df['Main Ingredient'].fillna('')
df['Seasoning'] = df['Seasoning'].fillna('')
df['Allergens'] = df['Allergens'].fillna('')

# Preprocess the data by combining features
X = df['Food Product'] + ' ' + df['Main Ingredient'] + ' ' + df['Seasoning']

# Clean and preprocess the allergens
def clean_allergens(allergens_str):
    if pd.isna(allergens_str):
        return []
    return [a.strip().lower() for a in allergens_str.split(',')]

# Process allergens
y = df['Allergens'].apply(clean_allergens)

# Convert target to multi-label format
mlb = MultiLabelBinarizer()
y = mlb.fit_transform(y)

# Ensure we have at least two classes for each label
if (y.sum(axis=0) == 0).any() or (y.sum(axis=0) == y.shape[0]).any():
    print("Warning: Some allergens appear in all or none of the samples")

# Split the data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train the model using RandomForestClassifier instead of LogisticRegression
pipeline = Pipeline([
    ('tfidf', TfidfVectorizer(min_df=2, ngram_range=(1, 2))),
    ('clf', MultiOutputClassifier(RandomForestClassifier(n_estimators=100, random_state=42)))
])

# Fit the pipeline
pipeline.fit(X_train, y_train)

# Evaluate the model
y_pred = pipeline.predict(X_test)
print("\nClassification Report:")
print(classification_report(y_test, y_pred, target_names=mlb.classes_))

# Save the model and MultiLabelBinarizer
joblib.dump(pipeline, 'allergen_model.pkl')
joblib.dump(mlb, 'mlb.pkl')

# Print the allergen classes
print("\nAllergen Classes:")
print(mlb.classes_)'''