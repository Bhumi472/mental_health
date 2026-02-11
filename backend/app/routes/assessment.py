from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from ..ai.orchestrator import Orchestrator
from ..models import AssessmentResult
from .. import db

assessment_bp = Blueprint("assessment", __name__)
orch = Orchestrator()


@assessment_bp.route("/start", methods=["POST"])
@jwt_required()
def start_assessment():
    data = request.get_json() or {}
    test_type = data.get("test_type", "stress")

    first_question = orch.get_first_question(test_type)

    return jsonify({
        "question": first_question
    })


@assessment_bp.route("/answer", methods=["POST"])
@jwt_required()
def answer_question():
    data = request.get_json() or {}

    test_type = data.get("test_type", "stress")
    current_id = data.get("current_question_id")
    answer = data.get("answer")

    if not current_id or not answer:
        return jsonify({"error": "current_question_id and answer required"}), 400

    next_question = orch.get_next_question(
        test_type,
        current_id,
        answer
    )

    return jsonify({
        "next": next_question
    })

@assessment_bp.route("/submit", methods=["POST"])
@jwt_required()
def submit_assessment():
    try:
        data = request.get_json() or {}
        user_id = get_jwt_identity()
        
        test_type = data.get("test_type")
        score = data.get("score")
        answers = data.get("answers", {})
        num_questions = len(answers)
        
        # Calculate interpretation on backend for better reliability
        result_text = orch.analyze_results(test_type, score, num_questions)
        
        if not test_type:
            return jsonify({"error": "test_type is required"}), 400
            
        result = AssessmentResult(
            user_id=user_id,
            test_type=test_type,
            score=score,
            result_text=result_text,
            answers=answers
        )
        
        db.session.add(result)
        db.session.commit()
        
        return jsonify({
            "message": "Assessment submitted successfully",
            "id": result.id,
            "result_text": result_text
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@assessment_bp.route("/history", methods=["GET"])
@jwt_required()
def get_assessment_history():
    user_id = get_jwt_identity()
    results = AssessmentResult.query.filter_by(user_id=user_id).order_by(AssessmentResult.created_at.desc()).all()
    
    return jsonify([r.to_dict() for r in results]), 200