from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from ..models import MoodEntry, db

mood_bp = Blueprint('mood', __name__)

@mood_bp.route('/save', methods=['POST'])
@jwt_required()
def save_mood():
    user_id = get_jwt_identity()
    data = request.get_json()
    
    if not data or 'mood_label' not in data:
        return jsonify({'message': 'Mood label is required'}), 400
        
    new_entry = MoodEntry(
        user_id=user_id,
        mood_label=data['mood_label'],
        reason=data.get('reason', '')
    )
    
    try:
        db.session.add(new_entry)
        db.session.commit()
        return jsonify({'message': 'Mood saved successfully', 'mood': new_entry.to_dict()}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': str(e)}), 500

@mood_bp.route('/history', methods=['GET'])
@jwt_required()
def get_mood_history():
    user_id = get_jwt_identity()
    entries = MoodEntry.query.filter_by(user_id=user_id).order_by(MoodEntry.created_at.desc()).all()
    return jsonify([entry.to_dict() for entry in entries]), 200
