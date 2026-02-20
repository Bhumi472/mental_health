from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.popslash_session import PopSlashSession
from app.ai.inference.popslash_model_loader import model
import uuid

popslash_bp = Blueprint("popslash", __name__)

@popslash_bp.route("/session", methods=["POST"])
@jwt_required()
def create_popslash_session():
    data = request.get_json()

    # Save raw session first
    session = PopSlashSession(
        id=str(uuid.uuid4()),
        user_id=get_jwt_identity(),
        reaction_time_avg=data["reaction_time_avg"],
        reaction_time_variance=data["reaction_time_variance"],
        correct_hits=data["correct_hits"],
        wrong_hits=data["wrong_hits"],
        missed_targets=data["missed_targets"],
        accuracy=data["accuracy"],
        session_duration=data["session_duration"]
    )

    db.session.add(session)
    db.session.commit()

    # Prepare features for model
    features = [[
        session.reaction_time_avg,
        session.reaction_time_variance,
        session.correct_hits,
        session.wrong_hits,
        session.missed_targets,
        session.accuracy,
        session.session_duration
    ]]

    prediction = model.predict(features)[0]

    session.cognitive_score = round(float(prediction), 2)
    db.session.commit()

    return jsonify({
        "message": "Session saved",
        "cognitive_score": session.cognitive_score
    }), 201
