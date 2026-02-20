from flask import Blueprint, request, jsonify
from app.services.community_service import CommunityService
from app.models.community_models import CommunityPost, CommunityComment
from app import db

community_bp = Blueprint('community', __name__)

# ✅ No user ID needed - posts can be anonymous!
DEFAULT_USER_ID = None

@community_bp.route('/categories', methods=['GET'])
def get_categories():
    """Get list of available categories"""
    categories = [
        {'id': 'anxiety', 'name': 'Anxiety', 'description': 'Discussions about anxiety and coping strategies'},
        {'id': 'depression', 'name': 'Depression', 'description': 'Support for depression and mood disorders'},
        {'id': 'stress', 'name': 'Stress', 'description': 'Managing stress and work-life balance'},
        {'id': 'general', 'name': 'General', 'description': 'General mental health discussions'},
        {'id': 'support', 'name': 'Support', 'description': 'Peer support and encouragement'},
        {'id': 'wellness', 'name': 'Wellness', 'description': 'Wellness tips and healthy habits'}
    ]
    return jsonify({'categories': categories}), 200

@community_bp.route('/posts', methods=['GET'])
def get_posts():
    """Get community posts with filtering and pagination"""
    try:
        category = request.args.get('category')
        sort_by = request.args.get('sort_by', 'hot')
        page = int(request.args.get('page', 1))
        per_page = int(request.args.get('per_page', 20))
        
        result = CommunityService.get_posts(
            category=category,
            sort_by=sort_by,
            page=page,
            per_page=per_page
        )
        
        posts_data = []
        for post in result['items']:
            post_dict = post.to_dict()
            posts_data.append(post_dict)
        
        return jsonify({
            'posts': posts_data,
            'total': result['total'],
            'page': result['page'],
            'pages': result['pages'],
            'per_page': result['per_page']
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@community_bp.route('/posts/<post_id>', methods=['GET'])
def get_post(post_id):
    """Get a single post with comments"""
    try:
        post = CommunityPost.query.get(post_id)
        if not post or post.is_deleted:
            return jsonify({'error': 'Post not found'}), 404
        
        post_data = post.to_dict()
        
        # Get top-level comments
        comments = CommunityComment.query.filter_by(
            post_id=post_id,
            parent_comment_id=None,
            is_deleted=False
        ).order_by(CommunityComment.created_at.desc()).all()
        
        comments_data = []
        for comment in comments:
            comment_dict = comment.to_dict(include_replies=True)
            comments_data.append(comment_dict)
        
        post_data['comments'] = comments_data
        
        return jsonify(post_data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@community_bp.route('/posts', methods=['POST'])
def create_post():
    """Create a new community post"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        if 'title' not in data or 'content' not in data:
            return jsonify({'error': 'Title and content are required'}), 400
        
        post, error = CommunityService.create_post(
            user_id=DEFAULT_USER_ID,  # ✅ None - no user needed!
            title=data['title'],
            content=data['content'],
            category=data.get('category', 'general'),
            is_anonymous=data.get('is_anonymous', False),
            db=db
        )
        
        if error:
            return jsonify({'error': error}), 400
        
        return jsonify({
            'message': 'Post created successfully',
            'post': post.to_dict()
        }), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@community_bp.route('/posts/<post_id>', methods=['DELETE'])
def delete_post(post_id):
    """Delete a post (soft delete)"""
    try:
        post = CommunityPost.query.get(post_id)
        if not post:
            return jsonify({'error': 'Post not found'}), 404
        
        post.is_deleted = True
        db.session.commit()
        
        return jsonify({'message': 'Post deleted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@community_bp.route('/comments', methods=['POST'])
def create_comment():
    """Create a comment on a post"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        if 'post_id' not in data or 'content' not in data:
            return jsonify({'error': 'Post ID and content are required'}), 400
        
        comment, error = CommunityService.create_comment(
            user_id=DEFAULT_USER_ID,  # ✅ None - no user needed!
            post_id=data['post_id'],
            content=data['content'],
            parent_comment_id=data.get('parent_comment_id'),
            is_anonymous=data.get('is_anonymous', False),
            db=db
        )
        
        if error:
            return jsonify({'error': error}), 400
        
        return jsonify({
            'message': 'Comment created successfully',
            'comment': comment.to_dict()
        }), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@community_bp.route('/comments/<comment_id>', methods=['DELETE'])
def delete_comment(comment_id):
    """Delete a comment (soft delete)"""
    try:
        comment = CommunityComment.query.get(comment_id)
        if not comment:
            return jsonify({'error': 'Comment not found'}), 404
        
        comment.is_deleted = True
        db.session.commit()
        
        return jsonify({'message': 'Comment deleted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@community_bp.route('/posts/<post_id>/vote', methods=['POST'])
def vote_post(post_id):
    """Vote on a post"""
    try:
        data = request.get_json()
        
        if not data or 'vote_type' not in data:
            return jsonify({'error': 'Vote type is required'}), 400
        
        success, error = CommunityService.vote_post(
            user_id=DEFAULT_USER_ID,  # ✅ None - no user needed!
            post_id=post_id,
            vote_type=data['vote_type'],
            db=db
        )
        
        if error:
            return jsonify({'error': error}), 400
        
        post = CommunityPost.query.get(post_id)
        
        return jsonify({
            'message': 'Vote recorded successfully',
            'upvotes': post.upvotes,
            'downvotes': post.downvotes,
            'score': post.upvotes - post.downvotes
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@community_bp.route('/comments/<comment_id>/vote', methods=['POST'])
def vote_comment(comment_id):
    """Vote on a comment"""
    try:
        data = request.get_json()
        
        if not data or 'vote_type' not in data:
            return jsonify({'error': 'Vote type is required'}), 400
        
        success, error = CommunityService.vote_comment(
            user_id=DEFAULT_USER_ID,  # ✅ None - no user needed!
            comment_id=comment_id,
            vote_type=data['vote_type'],
            db=db
        )
        
        if error:
            return jsonify({'error': error}), 400
        
        comment = CommunityComment.query.get(comment_id)
        
        return jsonify({
            'message': 'Vote recorded successfully',
            'upvotes': comment.upvotes,
            'downvotes': comment.downvotes,
            'score': comment.upvotes - comment.downvotes
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@community_bp.route('/posts/<post_id>/report', methods=['POST'])
def report_post(post_id):
    """Report a post"""
    try:
        data = request.get_json()
        
        if not data or 'reason' not in data:
            return jsonify({'error': 'Reason is required'}), 400
        
        success, error = CommunityService.report_post(
            user_id=DEFAULT_USER_ID,  # ✅ None - no user needed!
            post_id=post_id,
            reason=data['reason'],
            description=data.get('description'),
            db=db
        )
        
        if error:
            return jsonify({'error': error}), 400
        
        return jsonify({'message': 'Report submitted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500