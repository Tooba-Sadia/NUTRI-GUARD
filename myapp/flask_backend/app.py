import json
import requests
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_cors import CORS
from extensions import db
from models import User
from db_config import get_db_connection


app = Flask(__name__)
CORS(app)
bcrypt = Bcrypt(app)

# Configure the database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)  # Initialize the database

# Initialize the database
with app.app_context():
    db.create_all()

@app.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    email = data['email']
    password = data['password']
    username = data['username']

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("INSERT INTO users (email, password, username) VALUES (%s, %s, %s)", (email, password, username))
        conn.commit()
        return jsonify({'status': 'success', 'message': 'Signup successful'}), 201
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})
    finally:
        cursor.close()
        conn.close()

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data['email']
    password = data['password']

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM users WHERE email = %s AND password = %s", (email, password))
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    if user:
        return jsonify({'status': 'success', 'message': 'Login successful', 'user': user})
    else:
        return jsonify({'status': 'error', 'message': 'Invalid credentials'})

@app.route('/user/allergens', methods=['POST'])
def set_allergens():
    data = request.json
    user_id = data['user_id']
    allergens = data['allergens']
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE users SET allergens=%s WHERE id=%s", (json.dumps(allergens), user_id))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'status': 'success'})

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

SPOONACULAR_API_KEY = '357b073edf8b4c059217c3f6eec6e283'

@app.route('/recipes/recommend', methods=['POST'])
def recommend_recipes():
    data = request.json
    allergens = data.get('allergens', [])
    exclude = ','.join(allergens)
    url = f'https://api.spoonacular.com/recipes/complexSearch?apiKey={SPOONACULAR_API_KEY}&excludeIngredients={exclude}&number=10'
    response = requests.get(url)
    recipes = response.json().get('results', [])
    return jsonify({'recipes': recipes})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
