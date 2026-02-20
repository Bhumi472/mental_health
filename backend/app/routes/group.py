from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from ..models import User, OrganizationToken, AssessmentResult, MoodEntry
from .. import db
from datetime import datetime, timedelta
from sqlalchemy import func

group_bp = Blueprint('group', __name__)

@group_bp.route('/join', methods=['POST'])
@jwt_required()
def join_group():
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        token_str = data['token'].strip()
        
        # Check if token exists
        token_record = OrganizationToken.query.filter(
            func.lower(OrganizationToken.token) == func.lower(token_str),
            OrganizationToken.is_active == True
        ).first()
        if not token_record:
            return jsonify({'error': 'Invalid or inactive group token'}), 404
        
        if token_record.current_members >= token_record.max_members:
            return jsonify({'error': 'Group is full'}), 400
        
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        if user.organization_token == token_str:
            return jsonify({'message': 'You are already in this group'}), 200
        
        # If user was in another group, decrement its count
        if user.organization_token:
            old_token = OrganizationToken.query.filter_by(token=user.organization_token).first()
            if old_token:
                old_token.current_members -= 1
        
        user.organization_token = token_str
        token_record.current_members += 1
        
        db.session.commit()
        
        return jsonify({
            'message': f'Successfully joined {token_record.organization_name or "group"}',
            'group_name': token_record.organization_name
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@group_bp.route('/report', methods=['GET'])
@jwt_required()
def get_group_report():
    try:
        admin_id = get_jwt_identity()
        
        # Find the token created by this admin
        token_record = OrganizationToken.query.filter_by(created_by=admin_id).first()
        if not token_record:
            return jsonify({'error': 'No group found for this admin'}), 404
        
        # Find all members of this group
        members = User.query.filter_by(organization_token=token_record.token).all()
        member_ids = [m.id for m in members]
        
        if not member_ids:
            return jsonify({
                'group_name': token_record.organization_name or token_record.token,
                'stats': {
                    'stress_level': 'Unknown',
                    'emotional_balance': 0,
                    'weekly_trend': []
                },
                'members': []
            }), 200

        # Calculate Emotional Balance (Avg Mood in last 7 days)
        # Mapping: Happy=10, Calm=8, Neutral=5, Sad=3, Angry=2 (Simplified)
        mood_map = {
            'Very Happy': 10, 'Happy': 8, 'Calm': 7, 'Neutral': 5, 
            'Anxious': 4, 'Sad': 3, 'Very Sad': 1, 'Angry': 2, 'Stressed': 2
        }
        
        one_week_ago = datetime.utcnow() - timedelta(days=7)
        moods = MoodEntry.query.filter(
            MoodEntry.user_id.in_(member_ids),
            MoodEntry.created_at >= one_week_ago
        ).all()
        
        avg_balance = 0
        if moods:
            scores = [mood_map.get(m.mood_label, 5) for m in moods]
            avg_balance = sum(scores) / len(scores)

        # Weekly trend (Moods per day)
        trend = []
        for i in range(7):
            date = (datetime.utcnow() - timedelta(days=6-i)).date()
            day_moods = [m for m in moods if m.created_at.date() == date]
            day_score = sum([mood_map.get(m.mood_label, 5) for m in day_moods]) / len(day_moods) if day_moods else 5
            trend.append({'day': date.strftime('%a'), 'score': round(float(day_score), 1)})

        # Member-wise Status (Abstract)
        member_reports = []
        overall_stress_scores = []
        
        for member in members:
            # Get latest assessment result
            latest_result = AssessmentResult.query.filter_by(user_id=member.id).order_by(AssessmentResult.created_at.desc()).first()
            
            status = 'Unknown'
            score = 0
            if latest_result:
                score = latest_result.score
                # Logic: lower score is better? Usually for mental health tests.
                # Let's assume high score = high risk (GAD-7 style)
                if score < 5: status = 'Stable'
                elif score < 10: status = 'Mild'
                elif score < 15: status = 'Moderate Stress'
                else: status = 'High Risk'
                overall_stress_scores.append(score)
            
            # Mood counts for this member
            member_moods = [m for m in moods if m.user_id == member.id]
            
            member_reports.append({
                'id': member.id,
                'name': f"{member.first_name or ''} {member.last_name or ''}".strip() or member.username,
                'status': status,
                'last_assessment': latest_result.test_type if latest_result else 'None',
                'mood_count': len(member_moods)
            })

        # Overall Stress Level
        overall_avg = sum(overall_stress_scores) / len(overall_stress_scores) if overall_stress_scores else 0
        stress_level = 'Low'
        if overall_avg > 15: stress_level = 'High'
        elif overall_avg > 8: stress_level = 'Medium'

        return jsonify({
            'group_name': token_record.organization_name or token_record.token,
            'stats': {
                'stress_level': stress_level,
                'emotional_balance': round(float(avg_balance * 10), 1), # Scale to 100
                'weekly_trend': trend
            },
            'members': member_reports
        }), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@group_bp.route('/my-group', methods=['GET'])
@jwt_required()
def get_my_group():
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user or not user.organization_token:
            return jsonify({'error': 'You have not joined any group yet.'}), 404
            
        token_record = OrganizationToken.query.filter(
            func.lower(OrganizationToken.token) == func.lower(user.organization_token)
        ).first()
        if not token_record:
            return jsonify({'error': f'Group data for token "{user.organization_token}" not found'}), 404
            
        # Get group members
        members = User.query.filter_by(organization_token=user.organization_token).all()
        member_list = [{
            'id': m.id,
            'name': f"{m.first_name or ''} {m.last_name or ''}".strip() or m.username,
            'is_me': m.id == user.id
        } for m in members]

        return jsonify({
            'name': token_record.organization_name,
            'token': token_record.token,
            'type': token_record.account_type,
            'member_count': token_record.current_members,
            'members': member_list,
            'created_at': token_record.created_at.isoformat() if token_record.created_at else None
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
