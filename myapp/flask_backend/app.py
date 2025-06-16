# Import required libraries
import json
import requests
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_cors import CORS
from extensions import db
from models import User
from db_config import get_db_connection
import tensorflow as tf
from util.preprocessing import preprocess

# Add this near the top of app.py
ALLERGEN_SYNONYMS = {
    "milk": ["milk", "whey", "casein", "lactose", "cheese", "cream", "butter", "yogurt"],
    "egg": ["egg", "eggs", "albumin", "mayonnaise"],
    "soy": ["soy", "soya", "soybean", "soybeans", "tofu", "edamame"],
    "peanut": ["peanut", "peanuts", "groundnut"],
    "tree nut": ["almond", "walnut", "cashew", "pecan", "hazelnut", "pistachio", "macadamia"],
    "wheat": ["wheat", "flour", "gluten", "bread", "pasta"],
    "fish": ["fish", "anchovy", "bass", "catfish", "cod", "flounder", "grouper", "haddock", "hake", "halibut", "herring", "mahi mahi", "perch", "pike", "pollock", "salmon", "snapper", "sole", "swordfish", "tilapia", "trout", "tuna"],
    "shellfish": ["shrimp", "prawn", "crab", "lobster", "scallop", "clam", "oyster", "mussel"],
    "chicken": ["chicken", "hen", "broiler"],
    "pork": ["pork", "pig", "ham", "bacon", "sausage"],
    # Add more as needed
    }


#for running:
#cd C:\Users\PMLS\Downloads\NUTRI-GUARD\myapp\flask_backend
#python app.py


# Initialize Flask application
app = Flask(__name__)

# MAhrukh Database start--------------------------------------------------------------------------------------------------------------------------

# Enable CORS (Cross-Origin Resource Sharing) for the app
CORS(app)
# Initialize Bcrypt for password hashing
bcrypt = Bcrypt(app)

# Configure the database - using SQLite for development
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)  # Initialize the database with Flask app

# Create database tables within application context
with app.app_context():
    db.create_all()

# User signup endpoint
@app.route('/signup', methods=['POST'])
def signup():
    # Get JSON data from request
    data = request.get_json()
    email = data['email']
    password = data['password']
    username = data['username']

    # Hash the password for secure storage
    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

    # Get database connection and cursor
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Insert new user into database
        cursor.execute(
            "INSERT INTO users (email, password, username) VALUES (%s, %s, %s)",
            (email, hashed_password, username)
        )
        conn.commit()
        return jsonify({'status': 'success', 'message': 'Signup successful'}), 201
    except Exception as e:
        # Return error if something goes wrong
        return jsonify({'status': 'error', 'message': str(e)})
    finally:
        # Close database connection
        cursor.close()
        conn.close()

# User login endpoint
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data['email']
    password = data['password']

    # Get database connection
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Query user by email
    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()

    # Close connection
    cursor.close()
    conn.close()

    # Verify password and return appropriate response
    if user and bcrypt.check_password_hash(user['password'], password):
        # Remove password from response for security
        user.pop('password', None)
        return jsonify({'status': 'success', 'message': 'Login successful', 'user': user})
    else:
        return jsonify({'status': 'error', 'message': 'Invalid credentials'})

# Endpoint to set user allergens
@app.route('/user/allergens', methods=['POST'])
def set_allergens():
    data = request.json
    user_id = data['user_id']
    allergens = data['allergens']
    
    # Update user's allergens in database
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE users SET allergens=%s WHERE id=%s", (json.dumps(allergens), user_id))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'status': 'success'})

# Endpoint to get user allergens
@app.route('/user/allergens/<int:user_id>', methods=['GET'])
def get_allergens(user_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT allergens FROM users WHERE id=%s", (user_id,))
    row = cursor.fetchone()
    cursor.close()
    conn.close()
    if row and row['allergens']:
        return jsonify({'allergens': json.loads(row['allergens'])})
    return jsonify({'allergens': []})

# Spoonacular API key for recipe recommendations
SPOONACULAR_API_KEY = '7bb378a3d04a4accb92f61c3a3ddd940'

# Endpoint to get allergen-free recipe recommendations
@app.route('/recipes/recommend', methods=['POST'])
def recommend_recipes():
    data = request.json
    allergens = data.get('allergens', [])
    # Expand allergens to include synonyms
    allergen_terms = set()
    for allergen in allergens:
        allergen = allergen.lower()
        if allergen in ALLERGEN_SYNONYMS:
            allergen_terms.update([a.lower() for a in ALLERGEN_SYNONYMS[allergen]])
        else:
            allergen_terms.add(allergen)
    exclude = ','.join(allergen_terms)
    url = f'https://api.spoonacular.com/recipes/complexSearch?apiKey={SPOONACULAR_API_KEY}&number=10'
    if exclude:
        url += f"&excludeIngredients={exclude}"
    response = requests.get(url)
    print("Received allergens:", allergens)
    print("Expanded allergen terms:", allergen_terms)
    print("Spoonacular URL:", url)
    print("Spoonacular response:", response.text)
    recipes = response.json().get('results', [])
    print("Recipes list:", recipes)

    safe_recipes = []
    for recipe in recipes:
        recipe_id = recipe['id']
        detail_url = f'https://api.spoonacular.com/recipes/{recipe_id}/information?apiKey={SPOONACULAR_API_KEY}'
        detail_resp = requests.get(detail_url)
        if detail_resp.status_code == 200:
            details = detail_resp.json()
            ingredient_names = [i['name'].lower() for i in details.get('extendedIngredients', [])]
            matched = [term for term in allergen_terms for ingredient in ingredient_names if term in ingredient]
            if not matched:
                safe_recipes.append(recipe)
            else:
                print(f"Filtered out recipe {recipe_id} due to allergen match: {matched}")
    return jsonify({'recipes': safe_recipes})

# Endpoint for password reset
@app.route('/reset_password', methods=['POST'])
def reset_password():
    data = request.get_json()
    email = data.get('email')
    new_password = data.get('new_password')

    # Validate input
    if not email or not new_password:
        return jsonify({'status': 'error', 'message': 'Email and new password required'}), 400

    # Hash the new password
    hashed_password = bcrypt.generate_password_hash(new_password).decode('utf-8')

    # Update password in database
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE users SET password=%s WHERE email=%s", (hashed_password, email))
    conn.commit()
    updated = cursor.rowcount
    cursor.close()
    conn.close()

    # Return appropriate response
    if updated:
        return jsonify({'status': 'success', 'message': 'Password reset successful'})
    else:
        return jsonify({'status': 'error', 'message': 'User not found'}), 404
 
# MAhrukh Database End--------------------------------------------------------------------------------------------------------------------------


# Tooba Model Start --------------------------------------------------------------------------------------------------------------------------

# Load TFLite model for allergen detection
interpreter = tf.lite.Interpreter(model_path="model/model.tflite")
interpreter.allocate_tensors()

# Get input/output details from the model
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Load allergen labels
with open('model/exolabels.txt', 'r') as f:
    ALLERGEN_LABELS = [line.strip() for line in f.readlines()]




# Endpoint for allergen prediction
@app.route('/predict', methods=['POST'])
def predict():
    # Get input text from request
    data = request.get_json()
    print("Received data:", data)
    text = data['text']
    print("Text to process:", text)

    # === Preprocess text ===
    input_word_ids, input_mask, input_type_ids = preprocess(text)

    # Set TFLite model inputs
    interpreter.set_tensor(input_details[0]['index'], input_word_ids)
    interpreter.set_tensor(input_details[1]['index'], input_mask)
    interpreter.set_tensor(input_details[2]['index'], input_type_ids)

    # Run the model
    interpreter.invoke()

    # Get model output
    output = interpreter.get_tensor(output_details[0]['index'])  # shape: (1, num_labels)
    prediction = output[0]  # shape: (num_labels,)

    # Apply threshold to filter relevant predictions
    threshold = 0.5
    model_prediction = {
        label: float(score)
        for label, score in zip(ALLERGEN_LABELS, prediction)
        if score > threshold
    }

    # Prepare response
    response = {
        "model_prediction": model_prediction,
        "final_decision": "Contains Allergens" if model_prediction else "No Major Allergens",
        "high_risk_ingredients": list(model_prediction.keys()),
        "confidence": "High" if model_prediction else "Low"
    }

    return jsonify(response)

# Tooba Model End --------------------------------------------------------------------------------------------------------------------------

# Main entry point
if __name__ == '__main__':
    # Run the Flask app on all network interfaces, port 5000, with debug mode on
    app.run(host='0.0.0.0', port=5050)