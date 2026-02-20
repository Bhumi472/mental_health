from app import db
import uuid
from datetime import datetime

class PopSlashSession(db.Model):
    __tablename__ = "popslash_sessions"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=False, index=True)

    reaction_time_avg = db.Column(db.Float, nullable=False)
    reaction_time_variance = db.Column(db.Float, nullable=False)
    correct_hits = db.Column(db.Integer, nullable=False)
    wrong_hits = db.Column(db.Integer, nullable=False)
    missed_targets = db.Column(db.Integer, nullable=False)
    accuracy = db.Column(db.Float, nullable=False)
    session_duration = db.Column(db.Integer, nullable=False)

    cognitive_score = db.Column(db.Float)
    risk_level = db.Column(db.String(20))  # optional future use

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "reaction_time_avg": self.reaction_time_avg,
            "accuracy": self.accuracy,
            "cognitive_score": self.cognitive_score,
            "created_at": self.created_at.isoformat()
        }
