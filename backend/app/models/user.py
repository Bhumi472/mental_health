from app import db
import uuid
from datetime import datetime
from app.models.community_models import UserBan

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)
    
    # Add these fields for your auth system
    account_type = db.Column(db.String(20), default='individual')
    age_group = db.Column(db.String(20), default='over_18')
    language = db.Column(db.String(10), default='en')
    first_name = db.Column(db.String(50))
    last_name = db.Column(db.String(50))
    date_of_birth = db.Column(db.Date)
    gender = db.Column(db.String(20))
    profession = db.Column(db.String(100))
    city = db.Column(db.String(100))
    country = db.Column(db.String(100))
    address = db.Column(db.String(200))
    organization_name = db.Column(db.String(100))
    organization_token = db.Column(db.String(100))
    terms_accepted = db.Column(db.Boolean, default=False)
    privacy_accepted = db.Column(db.Boolean, default=False)
    is_active = db.Column(db.Boolean, default=True)
    
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # ============ COMMUNITY RELATIONSHIPS ============
    # THESE MUST MATCH THE back_populates IN community_models.py
    
    # 1. Posts created by user
    posts = db.relationship(
        'CommunityPost',
        back_populates='user',  # This matches 'user' in CommunityPost, not 'author'
        foreign_keys='CommunityPost.user_id',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    # 2. Comments created by user
    comments = db.relationship(
        'CommunityComment',
        back_populates='user',  # This matches 'user' in CommunityComment
        foreign_keys='CommunityComment.user_id',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    # 3. Votes on posts by user
    post_votes = db.relationship(
        'PostVote',
        back_populates='user',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    # 4. Votes on comments by user
    comment_votes = db.relationship(
        'CommentVote',
        back_populates='user',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    # 5. Reports on posts by user
    post_reports = db.relationship(
        'PostReport',
        back_populates='user',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    # 6. Reports on comments by user
    comment_reports = db.relationship(
        'CommentReport',
        back_populates='user',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    # 7. Bans received by user
    bans_received = db.relationship(
        'UserBan',
        foreign_keys='UserBan.user_id',
        back_populates='user',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    # 8. Bans issued by user
    bans_issued = db.relationship(
        'UserBan',
        foreign_keys='UserBan.banned_by',
        back_populates='admin',
        lazy='dynamic'
    )
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'account_type': self.account_type,
            'age_group': self.age_group,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'city': self.city,
            'country': self.country,
            'organization_name': self.organization_name,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'post_count': self.get_post_count(),
            'comment_count': self.get_comment_count(),
            'is_banned': self.is_banned()
        }
    
    def get_post_count(self):
        return self.posts.filter_by(is_deleted=False).count()
    
    def get_comment_count(self):
        return self.comments.filter_by(is_deleted=False).count()
    
    def is_banned(self):
        active_ban = self.bans_received.filter(
            (UserBan.is_permanent == True) |
            ((UserBan.is_permanent == False) & (UserBan.expires_at > datetime.utcnow()))
        ).first()
        return active_ban is not None
    
    def __repr__(self):
        return f'<User {self.username}>'