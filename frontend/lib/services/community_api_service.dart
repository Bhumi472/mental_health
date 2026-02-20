import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/community_models.dart';

class CommunityApiService {
  // FOR CHROME/WEB:
  static const String baseUrl = 'http://127.0.0.1:8000/api/community';
  
  // FOR ANDROID EMULATOR:
  // static const String baseUrl = 'http://10.0.2.2:8000/api/community';
  
  // ✅ NO AUTH, NO TOKENS, NO HEADERS!

  static Future<List<CommunityPost>> getPosts({
    String? category,
    String sortBy = 'hot',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = {
        if (category != null) 'category': category,
        'sort_by': sortBy,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri = Uri.parse('$baseUrl/posts').replace(queryParameters: queryParams);
      print('🔵 GET Posts: $uri');
      
      final response = await http.get(uri);
      print('🔵 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final posts = (data['posts'] as List)
            .map((post) => CommunityPost.fromJson(post))
            .toList();
        return posts;
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 Error: $e');
      throw Exception('Error loading posts: $e');
    }
  }

  static Future<CommunityPost> getPost(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CommunityPost.fromJson(data);
      } else {
        throw Exception('Failed to load post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading post: $e');
    }
  }

  static Future<CommunityPost> createPost({
    required String title,
    required String content,
    required String category,
    bool isAnonymous = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'content': content,
          'category': category,
          'is_anonymous': isAnonymous,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return CommunityPost.fromJson(data['post']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to create post');
      }
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  static Future<CommunityComment> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
    bool isAnonymous = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'post_id': postId,
          'content': content,
          if (parentCommentId != null) 'parent_comment_id': parentCommentId,
          'is_anonymous': isAnonymous,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return CommunityComment.fromJson(data['comment']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to create comment');
      }
    } catch (e) {
      throw Exception('Error creating comment: $e');
    }
  }

  static Future<Map<String, dynamic>> votePost(String postId, String voteType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/vote'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'vote_type': voteType}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to vote');
      }
    } catch (e) {
      throw Exception('Error voting: $e');
    }
  }

  static Future<Map<String, dynamic>> voteComment(String commentId, String voteType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comments/$commentId/vote'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'vote_type': voteType}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to vote');
      }
    } catch (e) {
      throw Exception('Error voting: $e');
    }
  }

  static Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = (data['categories'] as List)
            .map((cat) => Category.fromJson(cat))
            .toList();
        return categories;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }

  static Future<void> deletePost(String postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$postId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }

  static Future<void> deleteComment(String commentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/comments/$commentId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete comment');
      }
    } catch (e) {
      throw Exception('Error deleting comment: $e');
    }
  }

  static Future<void> reportPost({
    required String postId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/report'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reason': reason,
          if (description != null) 'description': description,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to report post');
      }
    } catch (e) {
      throw Exception('Error reporting post: $e');
    }
  }
}