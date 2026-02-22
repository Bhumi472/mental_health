from flask import Blueprint, jsonify
from app.ai.inference import mental_health as mh

mental_health_bp = Blueprint('mental_health', __name__)

@mental_health_bp.route('/assess/<string:user_id>', methods=['GET'])
def assess_user(user_id):
    risk_pred, risk_prob = mh.predict_risk(user_id)
    if risk_pred is None:
        return jsonify({'error': 'User not found or insufficient data'}), 404

    condition_pred = mh.predict_condition(user_id)
    trend_pred = mh.predict_trend(user_id)

    alerts = []
    if risk_pred == 1:
        alerts.append("High risk detected. Consider reaching out to a clinician.")
    if risk_prob > 0.8:
        alerts.append("Risk probability is very high. Immediate attention may be needed.")

    feats = mh.get_user_features(user_id)
    if feats is not None:
        feats_row = feats.iloc[0]
        recommendations = []
        if feats_row['avg_sentiment_7d'] < -0.2:
            recommendations.append("Try a gratitude journaling exercise.")
        if feats_row['total_community_actions_7d'] < 5:
            recommendations.append("Engage more in community discussions for support.")
    else:
        recommendations = []

    return jsonify({
        'user_id': user_id,
        'risk': {'level': 'High' if risk_pred == 1 else 'Low', 'probability': risk_prob},
        'condition': {'class': condition_pred, 'label': mh.CONDITION_LABELS.get(condition_pred, 'Unknown')},
        'trend_forecast': {'next_week_sentiment': trend_pred},
        'alerts': alerts,
        'recommendations': recommendations
    })