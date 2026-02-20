import 'dart:convert';
import 'package:http/http.dart' as http;
import 'test_api_service.dart';

class GamesApiService {
  // FOR CHROME/WEB:
  static const String baseUrl = 'http://127.0.0.1:5000';

  // FOR ANDROID EMULATOR:
  // static const String baseUrl = 'http://10.0.2.2:5000';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${TestApiService.token}',
      };

  /// MEMORY LANE SUBMIT
  static Future<Map<String, dynamic>> submitMemoryLane({
    required List<int> answers,
    int? duration,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/memorylane/submit');
      print('🧠 POST MemoryLane: $uri');

      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode({
          'answers': answers,
          if (duration != null) 'duration': duration,
        }),
      );

      print('🧠 Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed MemoryLane submit');
      }
    } catch (e) {
      print('🔴 MemoryLane Error: $e');
      throw Exception('MemoryLane API error: $e');
    }
  }

  /// POP & SLASH SUBMIT
  static Future<Map<String, dynamic>> submitPopSlash({
    required int score,
    required int level,
    required int mistakes,
    int? duration,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/popslash/submit');
      print('🎯 POST PopSlash: $uri');

      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode({
          'score': score,
          'level': level,
          'mistakes': mistakes,
          if (duration != null) 'duration': duration,
        }),
      );

      print('🎯 Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed PopSlash submit');
      }
    } catch (e) {
      print('🔴 PopSlash Error: $e');
      throw Exception('PopSlash API error: $e');
    }
  }
}
