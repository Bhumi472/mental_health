import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class MoodService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api/mood";
    }
    return "http://10.0.2.2:8000/api/mood";
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> saveMood({
    required String moodLabel,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save'),
        headers: await _getHeaders(),
        body: json.encode({
          'mood_label': moodLabel,
          'reason': reason ?? '',
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to save mood: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving mood: $e');
    }
  }

  static Future<List<dynamic>> getMoodHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load mood history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading mood history: $e');
    }
  }
}