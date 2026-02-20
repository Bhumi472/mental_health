from app import db
import uuid
from datetime import datetime

class OrganizationToken(db.Model):
    __tablename__ = 'organization_tokens'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    token = db.Column(db.String(100), unique=True, nullable=False)
    account_type = db.Column(db.String(20), nullable=False)
    organization_name = db.Column(db.String(100), nullable=False)
    max_members = db.Column(db.Integer, default=10)
    current_members = db.Column(db.Integer, default=0)
    created_by = db.Column(db.String(36), db.ForeignKey('users.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    expires_at = db.Column(db.DateTime)
    is_active = db.Column(db.Boolean, default=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'token': self.token,
            'account_type': self.account_type,
            'organization_name': self.organization_name,
            'max_members': self.max_members,
            'current_members': self.current_members,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'expires_at': self.expires_at.isoformat() if self.expires_at else None,
            'is_active': self.is_active
        }