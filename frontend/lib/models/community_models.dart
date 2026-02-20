class CommunityPost {
  final String id;
  final String title;
  final String content;
  final String category;
  final bool isAnonymous;
  final int upvotes;
  final int downvotes;
  final int score;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Author author;
  String? userVote;
  List<CommunityComment>? comments;

  CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.isAnonymous,
    required this.upvotes,
    required this.downvotes,
    required this.score,
    required this.commentCount,
    required this.createdAt,
    this.updatedAt,
    required this.author,
    this.userVote,
    this.comments,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'] ?? 'general',
      isAnonymous: json['is_anonymous'] ?? false,
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      score: json['score'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      author: Author.fromJson(json['author']),
      userVote: json['user_vote'],
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((c) => CommunityComment.fromJson(c))
              .toList()
          : null,
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class CommunityComment {
  final String id;
  final String postId;
  final String? parentCommentId;
  final String content;
  final bool isAnonymous;
  final int upvotes;
  final int downvotes;
  final int score;
  final DateTime createdAt;
  final Author author;
  String? userVote;
  List<CommunityComment>? replies;

  CommunityComment({
    required this.id,
    required this.postId,
    this.parentCommentId,
    required this.content,
    required this.isAnonymous,
    required this.upvotes,
    required this.downvotes,
    required this.score,
    required this.createdAt,
    required this.author,
    this.userVote,
    this.replies,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'],
      postId: json['post_id'],
      parentCommentId: json['parent_comment_id'],
      content: json['content'],
      isAnonymous: json['is_anonymous'] ?? false,
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      score: json['score'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      author: Author.fromJson(json['author']),
      userVote: json['user_vote'],
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((r) => CommunityComment.fromJson(r))
              .toList()
          : null,
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class Author {
  final String username;
  final bool isAnonymous;
  final String? id;

  Author({
    required this.username,
    this.isAnonymous = false,
    this.id,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      username: json['username'] ?? 'Anonymous',
      isAnonymous: json['username'] == 'Anonymous',
      id: json['id'],
    );
  }
}

class Category {
  final String id;
  final String name;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}