// lib/services/mental_health_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class MentalHealthService {
  static String get baseUrl {
    if (kIsWeb) {
      // For web (Chrome), use localhost
      return 'http://localhost:8000/api/mental';
    } else {
      // For Android emulator
      return 'http://10.0.2.2:8000/api/mental';
    }
  }

  Future<Map<String, dynamic>> getUserAssessment(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/assess/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load assessment (status ${response.statusCode})');
    }
  }
}