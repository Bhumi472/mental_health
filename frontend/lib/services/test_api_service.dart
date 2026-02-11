// services/test_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/test_models.dart';
import 'auth_service.dart'; // Assuming we can get the token here or via a shared storage

class TestApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000";
    }
    return "http://10.0.2.2:8000";
  }
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken(); // You need to implement this in AuthService
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Start a dynamic assessment
  static Future<Map<String, dynamic>> startAssessment(String testType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/assessment/start'),
        headers: await _getHeaders(),
        body: json.encode({'test_type': testType}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to start assessment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting assessment: $e');
    }
  }

  /// Answer a question and get the next one
  static Future<Map<String, dynamic>> answerQuestion({
    required String testType,
    required String currentQuestionId,
    required String answer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/assessment/answer'),
        headers: await _getHeaders(),
        body: json.encode({
          'test_type': testType,
          'current_question_id': currentQuestionId,
          'answer': answer,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to answer question: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error answering question: $e');
    }
  }

  /// Submit final results
  static Future<Map<String, dynamic>> submitResults({
    required String testType,
    required int score,
    required String resultText,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/assessment/submit'),
        headers: await _getHeaders(),
        body: json.encode({
          'test_type': testType,
          'score': score,
          'result_text': resultText,
          'answers': answers,
        }),
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit results: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting results: $e');
    }
  }
  
  // Keep the old ones for compatibility if needed, but updated for dynamic
  static Future<TestData> loadTest(String testId) async {
    // This is problematic now because the new flow is question by question.
    // I will refactor the dynamic test screen to use the new methods.
    throw UnimplementedError("Use startAssessment instead");
  }
}
