import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8000";

  static Future<String> pingBackend() async {
    final response = await http.get(Uri.parse("$baseUrl/"));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception("Backend not reachable");
    }
  }
}
