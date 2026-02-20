import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api/auth";
    }
    return "http://10.0.2.2:8000/api/auth";
  }

  static String get groupBaseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api/group";
    }
    return "http://10.0.2.2:8000/api/group";
  }

  static String? _token;
  static Map<String, dynamic>? _user;
  
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _instance.notifyListeners();
  }

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> setUser(Map<String, dynamic> user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user', jsonEncode(user));
    _instance.notifyListeners();
  }

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  
  static Map<String, dynamic>? get currentUser => _user;
  static String? get currentToken => _token;
  
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('auth_user');
    if (userStr != null) {
      _user = jsonDecode(userStr);
      _instance.notifyListeners();
    }
    return _user;
  }

  static Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    _instance.notifyListeners();
  }

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
    String? organizationToken,
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
      "organization_token": organizationToken,
    };

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup/individual"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data.containsKey('token')) {
        await setToken(data['token']);
        await setUser(data['user']);
      }
      return data;
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  /// 🏢 Organization/Family Signup (Admin)
  static Future<Map<String, dynamic>> signupOrganization({
    required String accountType,
    required String username,
    required String email,
    required String password,
    required String organizationName,
    required String organizationToken,
    required String ageGroup,
    required String language,
    required bool termsAccepted,
    required bool privacyAccepted,
  }) async {
    final requestBody = {
      "account_type": accountType,
      "username": username,
      "email": email,
      "password": password,
      "organization_name": organizationName,
      "organization_token": organizationToken,
      "age_group": ageGroup,
      "language": language,
      "terms_accepted": termsAccepted,
      "privacy_accepted": privacyAccepted,
    };

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup/organization"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data.containsKey('token')) {
        await setToken(data['token']);
        await setUser(data['user']);
      }
      return data;
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  /// 🤝 Join Group
  static Future<Map<String, dynamic>> joinGroup(String token) async {
    final authToken = await getToken();
    try {
      final response = await http.post(
        Uri.parse("$groupBaseUrl/join"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken"
        },
        body: jsonEncode({"token": token}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  /// 📊 Get Group Report
  static Future<Map<String, dynamic>> getGroupReport() async {
    final authToken = await getToken();
    try {
      final response = await http.get(
        Uri.parse("$groupBaseUrl/report"),
        headers: {
          "Authorization": "Bearer $authToken"
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  /// 🏠 Get Joined Group Details
  static Future<Map<String, dynamic>> getMyGroup() async {
    final authToken = await getToken();
    try {
      final response = await http.get(
        Uri.parse("$groupBaseUrl/my-group"),
        headers: {
          "Authorization": "Bearer $authToken"
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  /// 👤 Get Current User Profile (Refresh Data)
  static Future<Map<String, dynamic>> getMe() async {
    final authToken = await getToken();
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/me"),
        headers: {
          "Authorization": "Bearer $authToken"
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await setUser(data);
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
        await setToken(data['token']);
        await setUser(data['user']);
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
