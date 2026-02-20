from app.models.community_models import (
    CommunityPost, CommunityComment, PostVote, CommentVote,
    PostReport, CommentReport, UserBan
)
from .moderation_service import ContentModerationService
from datetime import datetime
from typing import Tuple, Optional

class CommunityService:
    
    @staticmethod
    def create_post(user_id: str, title: str, content: str, category: str = 'general', 
                   is_anonymous: bool = False, db=None) -> Tuple[Optional[CommunityPost], Optional[str]]:
        """Create a new community post"""
        try:
            # Sanitize content
            title = ContentModerationService.sanitize_content(title)
            content = ContentModerationService.sanitize_content(content)
            
            # Moderate content
            is_approved, rejection_reason, details = ContentModerationService.moderate_content(content, title)
            
            if not is_approved:
                return None, f"Post rejected: {rejection_reason}"
            
            # Validate category
            valid_categories = ['anxiety', 'depression', 'stress', 'general', 'support', 'wellness']
            if category not in valid_categories:
                category = 'general'
            
            # Create post - user_id can be None!
            post = CommunityPost(
                user_id=user_id,
                title=title,
                content=content,
                category=category,
                is_anonymous=is_anonymous,
                moderation_status='approved'
            )
            
            db.session.add(post)
            db.session.commit()
            
            return post, None
        except Exception as e:
            db.session.rollback()
            return None, str(e)
    
    @staticmethod
    def create_comment(user_id: str, post_id: str, content: str, 
                      parent_comment_id: Optional[str] = None,
                      is_anonymous: bool = False, db=None) -> Tuple[Optional[CommunityComment], Optional[str]]:
        """Create a comment on a post"""
        try:
            # Check if post exists
            post = CommunityPost.query.get(post_id)
            if not post or post.is_deleted:
                return None, "Post not found"
            
            # Sanitize content
            content = ContentModerationService.sanitize_content(content)
            
            # Moderate content
            is_approved, rejection_reason, details = ContentModerationService.moderate_content(content)
            
            if not is_approved:
                return None, f"Comment rejected: {rejection_reason}"
            
            # Create comment - user_id can be None!
            comment = CommunityComment(
                user_id=user_id,
                post_id=post_id,
                parent_comment_id=parent_comment_id,
                content=content,
                is_anonymous=is_anonymous
            )
            
            db.session.add(comment)
            db.session.commit()
            
            return comment, None
        except Exception as e:
            db.session.rollback()
            return None, str(e)
    
    @staticmethod
    def vote_post(user_id: str, post_id: str, vote_type: str, db=None) -> Tuple[bool, Optional[str]]:
        """Vote on a post (upvote or downvote)"""
        try:
            if vote_type not in ['upvote', 'downvote']:
                return False, "Invalid vote type"
            
            post = CommunityPost.query.get(post_id)
            if not post or post.is_deleted:
                return False, "Post not found"
            
            existing_vote = PostVote.query.filter_by(
                user_id=user_id,
                post_id=post_id
            ).first()
            
            if existing_vote:
                if existing_vote.vote_type == vote_type:
                    # Remove vote
                    if vote_type == 'upvote':
                        post.upvotes = max(0, post.upvotes - 1)
                    else:
                        post.downvotes = max(0, post.downvotes - 1)
                    db.session.delete(existing_vote)
                else:
                    # Change vote
                    if existing_vote.vote_type == 'upvote':
                        post.upvotes = max(0, post.upvotes - 1)
                        post.downvotes += 1
                    else:
                        post.downvotes = max(0, post.downvotes - 1)
                        post.upvotes += 1
                    existing_vote.vote_type = vote_type
            else:
                # New vote
                vote = PostVote(
                    user_id=user_id,
                    post_id=post_id,
                    vote_type=vote_type
                )
                db.session.add(vote)
                
                if vote_type == 'upvote':
                    post.upvotes += 1
                else:
                    post.downvotes += 1
            
            db.session.commit()
            return True, None
        except Exception as e:
            db.session.rollback()
            return False, str(e)
    
    @staticmethod
    def vote_comment(user_id: str, comment_id: str, vote_type: str, db=None) -> Tuple[bool, Optional[str]]:
        """Vote on a comment"""
        try:
            if vote_type not in ['upvote', 'downvote']:
                return False, "Invalid vote type"
            
            comment = CommunityComment.query.get(comment_id)
            if not comment or comment.is_deleted:
                return False, "Comment not found"
            
            existing_vote = CommentVote.query.filter_by(
                user_id=user_id,
                comment_id=comment_id
            ).first()
            
            if existing_vote:
                if existing_vote.vote_type == vote_type:
                    if vote_type == 'upvote':
                        comment.upvotes = max(0, comment.upvotes - 1)
                    else:
                        comment.downvotes = max(0, comment.downvotes - 1)
                    db.session.delete(existing_vote)
                else:
                    if existing_vote.vote_type == 'upvote':
                        comment.upvotes = max(0, comment.upvotes - 1)
                        comment.downvotes += 1
                    else:
                        comment.downvotes = max(0, comment.downvotes - 1)
                        comment.upvotes += 1
                    existing_vote.vote_type = vote_type
            else:
                vote = CommentVote(
                    user_id=user_id,
                    comment_id=comment_id,
                    vote_type=vote_type
                )
                db.session.add(vote)
                
                if vote_type == 'upvote':
                    comment.upvotes += 1
                else:
                    comment.downvotes += 1
            
            db.session.commit()
            return True, None
        except Exception as e:
            db.session.rollback()
            return False, str(e)
    
    @staticmethod
    def report_post(user_id: str, post_id: str, reason: str, description: str = None, 
                   db=None) -> Tuple[bool, Optional[str]]:
        """Report a post for moderation"""
        try:
            valid_reasons = ['spam', 'harassment', 'inappropriate', 'hate_speech', 'other']
            if reason not in valid_reasons:
                return False, "Invalid report reason"
            
            post = CommunityPost.query.get(post_id)
            if not post or post.is_deleted:
                return False, "Post not found"
            
            report = PostReport(
                user_id=user_id,
                post_id=post_id,
                reason=reason,
                description=description
            )
            
            db.session.add(report)
            db.session.commit()
            
            return True, None
        except Exception as e:
            db.session.rollback()
            return False, str(e)
    
    @staticmethod
    def get_posts(category: Optional[str] = None, sort_by: str = 'hot', 
                 page: int = 1, per_page: int = 20) -> dict:
        """Get community posts with filtering and sorting"""
        try:
            query = CommunityPost.query.filter_by(
                is_deleted=False,
                moderation_status='approved'
            )
            
            if category:
                query = query.filter_by(category=category)
            
            if sort_by == 'new':
                query = query.order_by(CommunityPost.created_at.desc())
            elif sort_by == 'top':
                query = query.order_by((CommunityPost.upvotes - CommunityPost.downvotes).desc())
            else:  # hot
                query = query.order_by(CommunityPost.created_at.desc())
            
            paginated = query.paginate(page=page, per_page=per_page, error_out=False)
            
            return {
                'items': paginated.items,
                'total': paginated.total,
                'page': page,
                'pages': paginated.pages,
                'per_page': per_page
            }
        except Exception as e:
            return {
                'items': [],
                'total': 0,
                'page': page,
                'pages': 0,
                'per_page': per_page
            }