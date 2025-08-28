# Import required libraries
import json
import numpy as np
import requests
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_cors import CORS
from extensions import db
from models import User
from db_config import get_db_connection
import tensorflow as tf
from util.preprocessing import preprocess, preprocess_halal
from transformers import BertTokenizer
import os

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
SPOONACULAR_API_KEY = 'c58c7853ee004c26b4de0f0eedaa09fd'

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
    print("Received allergens:", allergens, flush=True)
    print("Expanded allergen terms:", allergen_terms, flush=True)
    print("Spoonacular URL:", url, flush=True)
    print("Spoonacular response:", response.text, flush=True)
    recipes = response.json().get('results', [])
    print("Recipes list:", recipes, flush=True)

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
                print(f"Filtered out recipe {recipe_id} due to allergen match: {matched}", flush=True)
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
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

labels_path = os.path.join(BASE_DIR,'model', 'exolabels.txt')

# Load allergen labels
with open(labels_path, 'r') as f:
    ALLERGEN_LABELS = [line.strip() for line in f.readlines()]
# Get the directory where app.py is located




# Endpoint for allergen prediction
@app.route('/predict', methods=['POST'])
def predict():
    print("=== /predict endpoint called ===", flush=True)
    try:
        # Example: Load a file in a 'data' subfolder
        model_path = os.path.join(BASE_DIR,'model', 'model.tflite')
        print(f"Model path: {model_path}", flush=True)
        # Load TFLite model for allergen detection
        interpreter = tf.lite.Interpreter(model_path=model_path)
        interpreter.allocate_tensors()
        print("Interpreter loaded and tensors allocated.", flush=True)

        # Get input/output details from the model
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        print(f"Input details: {input_details}", flush=True)
        print(f"Output details: {output_details}", flush=True)

        # Get input text from request
        data = request.get_json()
        print("Received data:", data, flush=True)
        text = data['text']
        print("Text to process:", text, flush=True)

        # === Preprocess text ===
        input_word_ids, input_mask, input_type_ids = preprocess(text)
        print("Preprocessed input shapes:",
              input_word_ids.shape, input_mask.shape, input_type_ids.shape, flush=True)

        # Set TFLite model inputs
        interpreter.set_tensor(input_details[0]['index'], input_word_ids)
        interpreter.set_tensor(input_details[1]['index'], input_mask)
        interpreter.set_tensor(input_details[2]['index'], input_type_ids)
        print("Input tensors set.", flush=True)

        # Run the model
        interpreter.invoke()
        print("Model invoked.", flush=True)

        # Get model output
        output = interpreter.get_tensor(output_details[0]['index'])  # shape: (1, num_labels)
        prediction = output[0]  # shape: (num_labels,)
        print("Raw model output:", prediction, flush=True)

        # Apply threshold to filter relevant predictions
        threshold = 0.5
        model_prediction = {
            label: float(score)
            for label, score in zip(ALLERGEN_LABELS, prediction)
            if score > threshold
        }

        # If no allergens above threshold, explicitly set to none
        if not model_prediction:
            response = {
                "model_prediction": {},
                "final_decision": "No Major Allergens",
                "high_risk_ingredients": [],
                "confidence": "Low"
            }
        else:
            response = {
                "model_prediction": model_prediction,
                "final_decision": "Contains Allergens",
                "high_risk_ingredients": list(model_prediction.keys()),
                "confidence": "High"
            }

        return jsonify(response)
    except Exception as e:
        print("Exception in /predict:", e, flush=True)
        return jsonify({'error': str(e)}), 500


# Example: Load a file in a 'data' subfolder
halal_model_path = os.path.join(BASE_DIR, 'halal_model.tflite')

# Check if the halal model file exists
print(os.path.exists(halal_model_path), flush=True)
# Load TFLite model for halal detection


# Load tokenizer and e_code mapping once for efficiency
tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
e_code_mapping_path = 'e_code_mapping.json'

# Endpoint for halal status check
# Add commentMore actions
@app.route('/halal_check', methods=['POST'])
def halal_check():
    print("=== /halal_check endpoint called ===", flush=True)
    print("Request data:", request.get_json(), flush=True)
    
    try:
        halal_interpreter = tf.lite.Interpreter(model_path=halal_model_path)
        halal_interpreter.allocate_tensors()
        halal_input_details = halal_interpreter.get_input_details()
        halal_output_details = halal_interpreter.get_output_details()

        # Print model input details
        print("\n=== MODEL INPUT DETAILS ===", flush=True)
        for i, detail in enumerate(halal_input_details):
            print(f"Input {i}: name='{detail['name']}', shape={detail['shape']}, dtype={detail['dtype']}", flush=True)

        data = request.get_json()
        text = data.get('text', '')
        e_code = data.get('e_code', None)

        print(f"\nReceived text: '{text}'", flush=True)
        print(f"Received e_code: '{e_code}'", flush=True)

        # Preprocess input
        input_ids, attention_mask, e_code_input = preprocess_halal(
            text,
            e_code,
            tokenizer=tokenizer,
            e_code_mapping_path=e_code_mapping_path,
            max_length=128
        )

        # Print preprocessed data
        print(f"\n=== PREPROCESSED DATA ===", flush=True)
        print(f"input_ids shape: {input_ids.shape}, dtype: {input_ids.dtype}", flush=True)
        print(f"input_ids min/max: {input_ids.min()}/{input_ids.max()}", flush=True)
        print(f"input_ids first 10: {input_ids[0][:10]}", flush=True)
        
        print(f"attention_mask shape: {attention_mask.shape}, dtype: {attention_mask.dtype}", flush=True)
        print(f"attention_mask sum: {attention_mask.sum()}", flush=True)
        
        print(f"e_code_input shape: {e_code_input.shape}, dtype: {e_code_input.dtype}", flush=True)
        print(f"e_code_input value: {e_code_input}", flush=True)

        # Validate input shapes match model expectations
        print(f"\n=== SHAPE VALIDATION ===", flush=True)
        for detail in halal_input_details:
            if detail['name'] == 'input_ids':
                expected_shape = detail['shape']
                actual_shape = input_ids.shape
                print(f"input_ids - Expected: {expected_shape}, Actual: {actual_shape}, Match: {expected_shape == list(actual_shape)}", flush=True)
            elif detail['name'] == 'attention_mask':
                expected_shape = detail['shape']
                actual_shape = attention_mask.shape
                print(f"attention_mask - Expected: {expected_shape}, Actual: {actual_shape}, Match: {expected_shape == list(actual_shape)}", flush=True)
            elif detail['name'] == 'e_code_input':
                expected_shape = detail['shape']
                actual_shape = e_code_input.shape
                print(f"e_code_input - Expected: {expected_shape}, Actual: {actual_shape}, Match: {expected_shape == list(actual_shape)}", flush=True)

        # Additional safety checks before setting tensors
        print(f"\n=== SAFETY CHECKS ===", flush=True)
        
        # Check for any extremely large values that might cause issues
        if input_ids.max() > 50000:  # Reasonable upper bound for vocab
            print(f"WARNING: Very large token ID detected: {input_ids.max()}", flush=True)
            input_ids = np.clip(input_ids, 0, 30521)  # Clip to BERT vocab size
            print(f"Clipped input_ids max to: {input_ids.max()}", flush=True)
        
        if e_code_input.max() > 1000:  # Reasonable upper bound for e-codes
            print(f"WARNING: Very large e_code value detected: {e_code_input.max()}", flush=True)
            e_code_input = np.clip(e_code_input, 0, 999)
            print(f"Clipped e_code_input max to: {e_code_input.max()}", flush=True)

        # Set tensors by name with error handling
        print(f"\n=== SETTING TENSORS ===", flush=True)
        for detail in halal_input_details:
            try:
                if detail['name'] == 'input_ids':
                    print(f"Setting input_ids tensor...", flush=True)
                    halal_interpreter.set_tensor(detail['index'], input_ids)
                    print(f"✓ input_ids tensor set successfully", flush=True)
                elif detail['name'] == 'attention_mask':
                    print(f"Setting attention_mask tensor...", flush=True)
                    halal_interpreter.set_tensor(detail['index'], attention_mask)
                    print(f"✓ attention_mask tensor set successfully", flush=True)
                elif detail['name'] == 'e_code_input':
                    print(f"Setting e_code_input tensor...", flush=True)
                    halal_interpreter.set_tensor(detail['index'], e_code_input)
                    print(f"✓ e_code_input tensor set successfully", flush=True)
            except Exception as tensor_error:
                print(f"ERROR setting tensor {detail['name']}: {tensor_error}", flush=True)
                raise tensor_error

        # Try to invoke with additional error context
        print(f"\n=== INVOKING MODEL ===", flush=True)
        try:
            halal_interpreter.invoke()
            print(f"✓ Model invocation successful", flush=True)
        except Exception as invoke_error:
            print(f"ERROR during model invocation: {invoke_error}", flush=True)
            print(f"Error type: {type(invoke_error)}", flush=True)
            
            # Try to identify which specific input might be causing the issue
            print(f"\n=== DEBUGGING SPECIFIC INPUTS ===", flush=True)
            
            # Check if it's the input_ids causing issues
            unique_tokens = np.unique(input_ids)
            print(f"Unique tokens in input_ids: {len(unique_tokens)}", flush=True)
            print(f"Token range: {unique_tokens.min()} to {unique_tokens.max()}", flush=True)
            
            # Check e_code specifically
            print(f"E-code value being passed: {e_code_input[0][0]}", flush=True)
            
            raise invoke_error

        # Get output
        output = halal_interpreter.get_tensor(halal_output_details[0]['index'])
        halal_prob = float(output[0][0])

        print(f"Halal probability: {halal_prob}", flush=True)

        response = {
            "halal_probability": halal_prob,
            "halal_status": "Halal" if halal_prob > 0.5 else "Not Halal"
        }
        return jsonify(response)

    except Exception as e:
        print(f"\n=== FATAL ERROR ===", flush=True)
        print(f"Error: {str(e)}", flush=True)
        print(f"Error type: {type(e)}", flush=True)
        import traceback
        print(f"Full traceback: {traceback.format_exc()}", flush=True)
        return jsonify({"error": f"Internal server error: {str(e)}"}), 500

# Tooba Model End --------------------------------------------------------------------------------------------------------------------------

# Main entry point
if __name__ == '__main__':
    # Run the Flask app on all network interfaces, port 5000, with debug mode on
    app.run(host='0.0.0.0',debug=True, port=5050)