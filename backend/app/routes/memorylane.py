from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.memorylane_session import MemoryLaneSession
from app.ai.inference.memorylane_model_loader import memory_model
import uuid

memorylane_bp = Blueprint("memorylane", __name__)

@memorylane_bp.route("/session", methods=["POST"])
@jwt_required()
def create_memorylane_session():
    data = request.get_json()

    session = MemoryLaneSession(
        id=str(uuid.uuid4()),
        user_id=get_jwt_identity(),
        level_reached=data["level_reached"],
        total_sequences=data["total_sequences"],
        correct_sequences=data["correct_sequences"],
        wrong_attempts=data["wrong_attempts"],
        avg_reaction_time=data["avg_reaction_time"],
        max_streak=data["max_streak"],
        session_duration=data["session_duration"]
    )

    db.session.add(session)
    db.session.commit()

    features = [[
        session.level_reached,
        session.total_sequences,
        session.correct_sequences,
        session.wrong_attempts,
        session.avg_reaction_time,
        session.max_streak,
        session.session_duration
    ]]

    prediction = memory_model.predict(features)[0]

    session.memory_score = round(float(prediction), 2)
    db.session.commit()

    return jsonify({
        "message": "Memory session saved",
        "memory_score": session.memory_score
    }), 201
