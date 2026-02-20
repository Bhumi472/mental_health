from app import db
import uuid
from datetime import datetime

class CommunityPost(db.Model):
    __tablename__ = 'community_posts'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    # ✅ NULLABLE - no user required!
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=True)
    title = db.Column(db.String(300), nullable=False)
    content = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(50))
    is_anonymous = db.Column(db.Boolean, default=False)
    upvotes = db.Column(db.Integer, default=0)
    downvotes = db.Column(db.Integer, default=0)
    is_flagged = db.Column(db.Boolean, default=False)
    is_deleted = db.Column(db.Boolean, default=False)
    moderation_status = db.Column(db.String(20), default='approved')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    user = db.relationship('User', back_populates='posts', foreign_keys=[user_id])
    comments = db.relationship('CommunityComment', back_populates='post', lazy='dynamic', cascade='all, delete-orphan')
    votes = db.relationship('PostVote', back_populates='post', lazy='dynamic', cascade='all, delete-orphan')
    reports = db.relationship('PostReport', back_populates='post', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self, include_user=True):
        data = {
            'id': self.id,
            'title': self.title,
            'content': self.content,
            'category': self.category,
            'is_anonymous': self.is_anonymous,
            'upvotes': self.upvotes,
            'downvotes': self.downvotes,
            'score': self.upvotes - self.downvotes,
            'comment_count': self.comments.filter_by(is_deleted=False).count(),
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
        
        # ✅ Handle case when user is None
        if include_user and not self.is_anonymous and self.user:
            data['author'] = {
                'id': self.user.id,
                'username': self.user.username,
            }
        else:
            data['author'] = {
                'username': 'Anonymous'
            }
        
        return data


class CommunityComment(db.Model):
    __tablename__ = 'community_comments'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    post_id = db.Column(db.String(36), db.ForeignKey('community_posts.id'), nullable=False)
    # ✅ NULLABLE - no user required!
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=True)
    parent_comment_id = db.Column(db.String(36), db.ForeignKey('community_comments.id'))
    content = db.Column(db.Text, nullable=False)
    is_anonymous = db.Column(db.Boolean, default=False)
    upvotes = db.Column(db.Integer, default=0)
    downvotes = db.Column(db.Integer, default=0)
    is_flagged = db.Column(db.Boolean, default=False)
    is_deleted = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    user = db.relationship('User', back_populates='comments', foreign_keys=[user_id])
    post = db.relationship('CommunityPost', back_populates='comments', foreign_keys=[post_id])
    parent = db.relationship('CommunityComment', remote_side=[id], backref='replies')
    votes = db.relationship('CommentVote', back_populates='comment', lazy='dynamic', cascade='all, delete-orphan')
    reports = db.relationship('CommentReport', back_populates='comment', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self, include_user=True, include_replies=False):
        data = {
            'id': self.id,
            'post_id': self.post_id,
            'parent_comment_id': self.parent_comment_id,
            'content': self.content,
            'is_anonymous': self.is_anonymous,
            'upvotes': self.upvotes,
            'downvotes': self.downvotes,
            'score': self.upvotes - self.downvotes,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }
        
        # ✅ Handle case when user is None
        if include_user and not self.is_anonymous and self.user:
            data['author'] = {
                'id': self.user.id,
                'username': self.user.username,
            }
        else:
            data['author'] = {
                'username': 'Anonymous'
            }
        
        if include_replies:
            data['replies'] = [reply.to_dict(include_user=True, include_replies=False) 
                             for reply in self.replies if not reply.is_deleted]
        
        return data


class PostVote(db.Model):
    __tablename__ = 'post_votes'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    post_id = db.Column(db.String(36), db.ForeignKey('community_posts.id'), nullable=False)
    # ✅ NULLABLE - no user required!
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=True)
    vote_type = db.Column(db.String(10), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    __table_args__ = (db.UniqueConstraint('post_id', 'user_id', name='unique_post_vote'),)
    
    user = db.relationship('User', back_populates='post_votes', foreign_keys=[user_id])
    post = db.relationship('CommunityPost', back_populates='votes', foreign_keys=[post_id])


class CommentVote(db.Model):
    __tablename__ = 'comment_votes'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    comment_id = db.Column(db.String(36), db.ForeignKey('community_comments.id'), nullable=False)
    # ✅ NULLABLE - no user required!
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=True)
    vote_type = db.Column(db.String(10), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    __table_args__ = (db.UniqueConstraint('comment_id', 'user_id', name='unique_comment_vote'),)
    
    user = db.relationship('User', back_populates='comment_votes', foreign_keys=[user_id])
    comment = db.relationship('CommunityComment', back_populates='votes', foreign_keys=[comment_id])


class PostReport(db.Model):
    __tablename__ = 'post_reports'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    post_id = db.Column(db.String(36), db.ForeignKey('community_posts.id'), nullable=False)
    # ✅ NULLABLE - no user required!
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=True)
    reason = db.Column(db.String(50), nullable=False)
    description = db.Column(db.Text)
    status = db.Column(db.String(20), default='pending')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    user = db.relationship('User', back_populates='post_reports', foreign_keys=[user_id])
    post = db.relationship('CommunityPost', back_populates='reports', foreign_keys=[post_id])


class CommentReport(db.Model):
    __tablename__ = 'comment_reports'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    comment_id = db.Column(db.String(36), db.ForeignKey('community_comments.id'), nullable=False)
    # ✅ NULLABLE - no user required!
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=True)
    reason = db.Column(db.String(50), nullable=False)
    description = db.Column(db.Text)
    status = db.Column(db.String(20), default='pending')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    user = db.relationship('User', back_populates='comment_reports', foreign_keys=[user_id])
    comment = db.relationship('CommunityComment', back_populates='reports', foreign_keys=[comment_id])


class UserBan(db.Model):
    __tablename__ = 'user_bans'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    # ✅ NULLABLE - no user required!
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=True)
    banned_by = db.Column(db.String(36), db.ForeignKey('users.id'))
    reason = db.Column(db.Text, nullable=False)
    is_permanent = db.Column(db.Boolean, default=False)
    expires_at = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    user = db.relationship('User', back_populates='bans_received', foreign_keys=[user_id])
    admin = db.relationship('User', back_populates='bans_issued', foreign_keys=[banned_by])