import 'package:flutter/material.dart';
import '../../models/community_models.dart';
import '../../services/community_api_service.dart';
import 'create_post_page.dart';
import 'post_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<CommunityPost> _posts = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String _sortBy = 'hot';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadPosts();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CommunityApiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadPosts() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final posts = await CommunityApiService.getPosts(
        category: _selectedCategory,
        sortBy: _sortBy,
      );
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _categories.isEmpty ? null : _showCategoryFilter,
          ),
          IconButton(icon: const Icon(Icons.sort), onPressed: _showSortOptions),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadPosts,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: _posts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          post: _posts[index],
                          onTap: () => _navigateToPost(_posts[index]),
                          onVote: (voteType) =>
                              _handleVote(_posts[index], voteType),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreatePost,
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.forum, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No posts yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Be the first to start a conversation!'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreatePost,
            icon: const Icon(Icons.add),
            label: const Text('Create First Post'),
          ),
        ],
      ),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Category',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Categories'),
              selected: _selectedCategory == null,
              onTap: () {
                setState(() => _selectedCategory = null);
                Navigator.pop(context);
                _loadPosts();
              },
            ),
            ..._categories.map(
              (category) => ListTile(
                leading: Icon(_getCategoryIcon(category.id)),
                title: Text(category.name),
                subtitle: Text(category.description),
                selected: _selectedCategory == category.id,
                onTap: () {
                  setState(() => _selectedCategory = category.id);
                  Navigator.pop(context);
                  _loadPosts();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort Posts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.whatshot),
              title: const Text('Hot'),
              subtitle: const Text('Trending posts'),
              selected: _sortBy == 'hot',
              onTap: () {
                setState(() => _sortBy = 'hot');
                Navigator.pop(context);
                _loadPosts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.new_releases),
              title: const Text('New'),
              subtitle: const Text('Recent posts'),
              selected: _sortBy == 'new',
              onTap: () {
                setState(() => _sortBy = 'new');
                Navigator.pop(context);
                _loadPosts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Top'),
              subtitle: const Text('Most upvoted'),
              selected: _sortBy == 'top',
              onTap: () {
                setState(() => _sortBy = 'top');
                Navigator.pop(context);
                _loadPosts();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPost(CommunityPost post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailPage(postId: post.id)),
    );
    _loadPosts();
  }

  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostPage(categories: _categories),
      ),
    );
    if (result == true) {
      _loadPosts();
    }
  }

  Future<void> _handleVote(CommunityPost post, String voteType) async {
    try {
      await CommunityApiService.votePost(post.id, voteType);
      _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error voting: $e')));
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'anxiety':
        return Icons.psychology;
      case 'depression':
        return Icons.sentiment_very_dissatisfied;
      case 'stress':
        return Icons.cloud;
      case 'support':
        return Icons.favorite;
      case 'wellness':
        return Icons.spa;
      default:
        return Icons.chat;
    }
  }
}

class PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onTap;
  final Function(String) onVote;

  const PostCard({
    Key? key,
    required this.post,
    required this.onTap,
    required this.onVote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(post.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    post.author.isAnonymous ? Icons.person_off : Icons.person,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.author.username,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    post.getTimeAgo(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                post.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.userVote == 'upvote'
                          ? Icons.arrow_upward
                          : Icons.arrow_upward_outlined,
                      color: post.userVote == 'upvote'
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    onPressed: () => onVote('upvote'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.score}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: post.score > 0
                          ? Colors.orange
                          : post.score < 0
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      post.userVote == 'downvote'
                          ? Icons.arrow_downward
                          : Icons.arrow_downward_outlined,
                      color: post.userVote == 'downvote'
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    onPressed: () => onVote('downvote'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
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
