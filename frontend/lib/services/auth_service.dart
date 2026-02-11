import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000/api/auth";
    }
    return "http://10.0.2.2:8000/api/auth";
  }
  static String? _token;
  static Map<String, dynamic>? _user;

  static void setToken(String token) {
    _token = token;
  }

  static Future<String?> getToken() async {
    return _token;
  }

  static void setUser(Map<String, dynamic> user) {
    _user = user;
  }

  static Map<String, dynamic>? get user => _user;

  /// 🔐 Individual Signup
  static Future<Map<String, dynamic>> signupIndividual({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String city,
    required String language,
    required bool termsAccepted,
    required bool privacyAccepted,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(dateOfBirth);
    final ageGroup = getAgeGroupFromDOB(dateOfBirth);

    final requestBody = {
      "account_type": "individual",
      "username": username,
      "email": email,
      "password": password,
      "first_name": firstName,
      "last_name": lastName,
      "date_of_birth": formattedDate,
      "age_group": ageGroup,
      "city": city,
      "country": city,
      "language": language,
      "terms_accepted": termsAccepted,
      "privacy_accepted": privacyAccepted,
    };

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup/individual"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data.containsKey('token')) {
        setToken(data['token']);
        setUser(data['user']);
      }
      return data;
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  /// 🔓 Login
  static Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username_or_email": usernameOrEmail,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data.containsKey('token')) {
        setToken(data['token']);
        setUser(data['user']);
      }
      return data;
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  /// 🧮 Helpers
  static int calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  static String getAgeGroupFromDOB(DateTime dob) {
    final age = calculateAge(dob);
    if (age < 13) return "under_13";
    if (age <= 17) return "13_17";
    if (age <= 25) return "18_25";
    if (age <= 35) return "26_35";
    if (age <= 50) return "36_50";
    if (age <= 65) return "51_65";
    return "66_plus";
  }
}
