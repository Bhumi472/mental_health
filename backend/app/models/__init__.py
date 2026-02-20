from .. import db
import uuid
from datetime import datetime

# Import models from sub-modules to register them with SQLAlchemy
from .user import User
from .organization_token import OrganizationToken
from .community_models import CommunityPost, CommunityComment, PostVote, CommentVote, PostReport, CommentReport, UserBan
from .popslash_session import PopSlashSession
from .memorylane_session import MemoryLaneSession

class AssessmentResult(db.Model):
    __tablename__ = 'assessment_results'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    test_type = db.Column(db.String(50), nullable=False)
    score = db.Column(db.Integer)
    result_text = db.Column(db.Text)
    answers = db.Column(db.JSON)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    user = db.relationship('User', backref=db.backref('assessment_results', lazy=True))

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'test_type': self.test_type,
            'score': self.score,
            'result_text': self.result_text,
            'answers': self.answers,
            'created_at': self.created_at.isoformat()
        }

class MoodEntry(db.Model):
    __tablename__ = 'mood_entries'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    mood_label = db.Column(db.String(50), nullable=False)
    reason = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    user = db.relationship('User', backref=db.backref('mood_entries', lazy=True))

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'mood_label': self.mood_label,
            'reason': self.reason,
            'created_at': self.created_at.isoformat()
        }
