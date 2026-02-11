from flask import Blueprint, request, jsonify
from ..models.services.auth_service import AuthService
from .. import db

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/signup/individual', methods=['POST'])
def signup_individual():
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        result, error = AuthService.register_individual(data, db)
        
        if error:
            return jsonify({'error': error}), 400
        
        return jsonify(result), 201
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/signup/organization', methods=['POST'])
def signup_organization():
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        result, error = AuthService.register_organization(data, db)
        
        if error:
            return jsonify({'error': error}), 400
        
        return jsonify(result), 201
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        if not data or 'username_or_email' not in data or 'password' not in data:
            return jsonify({'error': 'Username/email and password required'}), 400
        
        result, error = AuthService.login(data['username_or_email'], data['password'])
        
        if error:
            return jsonify({'error': error}), 401
        
        return jsonify(result), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/me', methods=['GET'])
def get_current_user():
    # This requires JWT authentication - we'll implement this later
    return jsonify({'message': 'Protected route - implement JWT auth'}), 200