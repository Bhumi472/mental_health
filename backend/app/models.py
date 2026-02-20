from app import db
import uuid
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    account_type = db.Column(db.String(20), nullable=False)  # individual, organization, family
    age_group = db.Column(db.String(10), nullable=False)     # under_18, over_18
    organization_token = db.Column(db.String(100))
    language = db.Column(db.String(10), default='en')
    username = db.Column(db.String(50), unique=True, nullable=False, index=True)
    email = db.Column(db.String(100), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    first_name = db.Column(db.String(100))
    last_name = db.Column(db.String(100))
    date_of_birth = db.Column(db.Date)
    gender = db.Column(db.String(20))
    profession = db.Column(db.String(100))
    city = db.Column(db.String(100))
    country = db.Column(db.String(100))
    address = db.Column(db.Text)
    is_active = db.Column(db.Boolean, default=True)
    is_verified = db.Column(db.Boolean, default=False)
    terms_accepted = db.Column(db.Boolean, default=False)
    privacy_accepted = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Organization/Family specific
    organization_name = db.Column(db.String(200))
    family_name = db.Column(db.String(200))
    member_count = db.Column(db.Integer, default=1)
    
    def to_dict(self):
        return {
            'id': self.id,
            'account_type': self.account_type,
            'age_group': self.age_group,
            'username': self.username,
            'email': self.email,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'language': self.language,
            'is_verified': self.is_verified,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

class OrganizationToken(db.Model):
    __tablename__ = 'organization_tokens'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    token = db.Column(db.String(100), unique=True, nullable=False, index=True)
    account_type = db.Column(db.String(20), nullable=False)  # organization, family
    created_by = db.Column(db.String(36), db.ForeignKey('users.id'))
    organization_name = db.Column(db.String(200), nullable=False)
    max_members = db.Column(db.Integer, default=10)
    current_members = db.Column(db.Integer, default=0)
    is_active = db.Column(db.Boolean, default=True)
    expires_at = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


# pop and slash model 

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
    risk_level = db.Column(db.String(20))  # optional: low / moderate / high

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user = db.relationship("User", backref=db.backref("popslash_sessions", lazy=True))
