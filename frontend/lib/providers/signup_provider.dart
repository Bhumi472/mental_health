import 'package:flutter/material.dart';

class SignupProvider with ChangeNotifier {
  String _userType = '';
  String _ageGroup = '';
  String _language = 'English';
  String _token = '';

  String get userType => _userType;
  String get ageGroup => _ageGroup;
  String get language => _language;
  String get token => _token;

  void setUserType(String type) {
    _userType = type;
    notifyListeners();
  }

  void setAgeGroup(String group) {
    _ageGroup = group;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void reset() {
    _userType = '';
    _ageGroup = '';
    _language = 'English';
    _token = '';
    notifyListeners();
  }
}
