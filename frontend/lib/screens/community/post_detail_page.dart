import 'package:flutter/material.dart';
import '../../models/community_models.dart';
import '../../services/community_api_service.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  CommunityPost? _post;
  bool _isLoading = true;
  String? _errorMessage;
  final _commentController = TextEditingController();
  bool _isAnonymous = false;
  bool _isSubmittingComment = false;
  String? _replyingToCommentId;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    setState(() => _isLoading = true);
    try {
      final post = await CommunityApiService.getPost(widget.postId);
      setState(() {
        _post = post;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading post: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComment({String? parentCommentId}) async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmittingComment = true);

    try {
      await CommunityApiService.createComment(
        postId: widget.postId,
        content: _commentController.text.trim(),
        parentCommentId: parentCommentId,
        isAnonymous: _isAnonymous,
      );

      _commentController.clear();
      setState(() {
        _isAnonymous = false;
        _replyingToCommentId = null;
      });
      await _loadPost();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Comment posted!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmittingComment = false);
    }
  }

  Future<void> _handleVote(String voteType) async {
    try {
      await CommunityApiService.votePost(widget.postId, voteType);
      _loadPost();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error voting: $e')),
      );
    }
  }

  Future<void> _handleCommentVote(String commentId, String voteType) async {
    try {
      await CommunityApiService.voteComment(commentId, voteType);
      _loadPost();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error voting: $e')),
      );
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ FIXED: Icons.spam → Icons.report
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Spam'),
              onTap: () => _reportPost('spam'),
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('Harassment'),
              onTap: () => _reportPost('harassment'),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Inappropriate Content'),
              onTap: () => _reportPost('inappropriate'),
            ),
            ListTile(
              leading: const Icon(Icons.gpp_bad, color: Colors.red),
              title: const Text('Hate Speech'),
              onTap: () => _reportPost('hate_speech'),
            ),
            ListTile(
              leading: const Icon(Icons.more_horiz, color: Colors.red),
              title: const Text('Other'),
              onTap: () => _reportPost('other'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _reportPost(String reason) async {
    Navigator.pop(context);
    try {
      await CommunityApiService.reportPost(
        postId: widget.postId,
        reason: reason,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Report submitted. Thank you for keeping our community safe.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startReply(String commentId, String username) {
    setState(() {
      _replyingToCommentId = commentId;
    });
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage ?? 'Post not found'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: _showReportDialog,
            tooltip: 'Report',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPost,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPostHeader(),
                    const SizedBox(height: 16),
                    _buildPostContent(),
                    const SizedBox(height: 16),
                    _buildPostActions(),
                    const Divider(height: 32, thickness: 1),
                    _buildCommentsSection(),
                  ],
                ),
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getCategoryColor(_post!.category),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _post!.category.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          _post!.author.isAnonymous ? Icons.person_off : Icons.person,
          size: 20,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _post!.author.username,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          _post!.getTimeAgo(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _post!.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _post!.content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildPostActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _post!.userVote == 'upvote'
                  ? Icons.arrow_upward
                  : Icons.arrow_upward_outlined,
              color: _post!.userVote == 'upvote' ? Colors.orange : Colors.grey,
            ),
            onPressed: () => _handleVote('upvote'),
            tooltip: 'Upvote',
          ),
          Text(
            '${_post!.score}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _post!.score > 0
                  ? Colors.orange
                  : _post!.score < 0
                      ? Colors.blue
                      : Colors.grey,
            ),
          ),
          IconButton(
            icon: Icon(
              _post!.userVote == 'downvote'
                  ? Icons.arrow_downward
                  : Icons.arrow_downward_outlined,
              color: _post!.userVote == 'downvote' ? Colors.blue : Colors.grey,
            ),
            onPressed: () => _handleVote('downvote'),
            tooltip: 'Downvote',
          ),
          const SizedBox(width: 8),
          const VerticalDivider(width: 1, thickness: 1),
          const SizedBox(width: 8),
          const Icon(Icons.comment, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            '${_post!.commentCount} comments',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    if (_post!.comments == null || _post!.comments!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No comments yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share your thoughts!',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.comment, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              '${_post!.commentCount} Comments',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._post!.comments!.map((comment) => _buildCommentCard(comment)),
      ],
    );
  }

  Widget _buildCommentCard(CommunityComment comment, {int depth = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        color: depth == 0 ? Colors.white : Colors.grey.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    comment.author.isAnonymous ? Icons.person_off : Icons.person,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    comment.author.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    comment.getTimeAgo(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comment.content,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      comment.userVote == 'upvote'
                          ? Icons.arrow_upward
                          : Icons.arrow_upward_outlined,
                      size: 18,
                      color: comment.userVote == 'upvote'
                          ? Colors.orange
                          : Colors.grey.shade600,
                    ),
                    onPressed: () => _handleCommentVote(comment.id, 'upvote'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${comment.score}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: comment.score > 0
                          ? Colors.orange
                          : comment.score < 0
                              ? Colors.blue
                              : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    icon: Icon(
                      comment.userVote == 'downvote'
                          ? Icons.arrow_downward
                          : Icons.arrow_downward_outlined,
                      size: 18,
                      color: comment.userVote == 'downvote'
                          ? Colors.blue
                          : Colors.grey.shade600,
                    ),
                    onPressed: () => _handleCommentVote(comment.id, 'downvote'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => _startReply(comment.id, comment.author.username),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Reply',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Reply input for this comment
              if (_replyingToCommentId == comment.id) ...[
                const Divider(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a reply to ${comment.author.username}...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: _cancelReply,
                              ),
                              IconButton(
                                icon: _isSubmittingComment
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.send, color: Colors.blue),
                                onPressed: _isSubmittingComment
                                    ? null
                                    : () => _submitComment(parentCommentId: comment.id),
                              ),
                            ],
                          ),
                        ),
                        maxLines: 2,
                        minLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Render replies
              if (comment.replies != null && comment.replies!.isNotEmpty)
                const SizedBox(height: 8),
              ...?comment.replies?.map(
                (reply) => _buildCommentCard(reply, depth: depth + 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingToCommentId == null) ...[
              Row(
                children: [
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (value) => setState(() => _isAnonymous = value ?? false),
                    activeColor: Colors.blue,
                  ),
                  const Text(
                    'Post anonymously',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: _replyingToCommentId != null
                          ? 'Write your reply...'
                          : 'Write a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: _isSubmittingComment
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isSubmittingComment
                        ? null
                        : () => _submitComment(parentCommentId: _replyingToCommentId),
                  ),
                ),
              ],
            ),
            if (_replyingToCommentId != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Replying to comment',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _cancelReply,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'anxiety':
        return Colors.purple;
      case 'depression':
        return Colors.indigo;
      case 'stress':
        return Colors.orange;
      case 'support':
        return Colors.pink;
      case 'wellness':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}