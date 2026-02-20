from app import db
import uuid
from datetime import datetime

class MemoryLaneSession(db.Model):
    __tablename__ = "memorylane_sessions"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=False, index=True)

    level_reached = db.Column(db.Integer, nullable=False)
    total_sequences = db.Column(db.Integer, nullable=False)
    correct_sequences = db.Column(db.Integer, nullable=False)
    wrong_attempts = db.Column(db.Integer, nullable=False)
    avg_reaction_time = db.Column(db.Float, nullable=False)
    max_streak = db.Column(db.Integer, nullable=False)
    session_duration = db.Column(db.Integer, nullable=False)

    memory_score = db.Column(db.Float)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "memory_score": self.memory_score,
            "created_at": self.created_at.isoformat()
        }
