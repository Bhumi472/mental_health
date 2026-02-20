import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Model for a single test result
class TestResult {
  final String testId;
  final int score;
  final String label;
  final String msg;
  final Color color;
  final DateTime date;

  TestResult({
    required this.testId,
    required this.score,
    required this.label,
    required this.msg,
    required this.color,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'testId': testId,
        'score': score,
        'label': label,
        'msg': msg,
        'color': color.value,
        'date': date.toIso8601String(),
      };

  factory TestResult.fromJson(Map<String, dynamic> json) => TestResult(
        testId: json['testId'],
        score: json['score'],
        label: json['label'],
        msg: json['msg'],
        color: Color(json['color']),
        date: DateTime.parse(json['date']),
      );
}

// Manages the state of test results
class TestResultsProvider with ChangeNotifier {
  Map<String, TestResult> _results = {};
  bool _hasSeenInitialNotice = false;
  SharedPreferences? _prefs;
  String? _currentUserId;
  Completer<void> _initCompleter = Completer<void>();

  TestResultsProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _initCompleter.complete();
    notifyListeners();
  }

  Future<void> setCurrentUser(String userId) async {
    await _initCompleter.future;
    _currentUserId = userId;
    _loadResults();
    _loadNoticeStatus();
    notifyListeners();
  }

  void _loadResults() {
    if (_currentUserId == null || _prefs == null) return;
    
    final String? resultsJson = _prefs!.getString('test_results_$_currentUserId');
    if (resultsJson != null) {
      final Map<String, dynamic> decoded = json.decode(resultsJson);
      _results = decoded.map((key, value) => MapEntry(key, TestResult.fromJson(value)));
      
      // Check if we need to reset results (if older than current day)
      _checkAndResetDaily();
    } else {
      _results = {};
    }
  }

  void _checkAndResetDaily() {
    if (_results.isEmpty) return;

    // Find the latest test date
    DateTime latestDate = _results.values.map((r) => r.date).reduce((a, b) => a.isAfter(b) ? a : b);
    
    // Reset if the last test was on a previous day
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastTestDay = DateTime(latestDate.year, latestDate.month, latestDate.day);

    if (today.isAfter(lastTestDay)) {
      _results.clear();
      _saveResults();
    }
  }

  void _loadNoticeStatus() {
    if (_currentUserId == null || _prefs == null) return;
    _hasSeenInitialNotice = _prefs!.getBool('has_seen_initial_notice_$_currentUserId') ?? false;
  }

  bool get hasSeenInitialNotice {
    if (_currentUserId == null) return true;
    return _hasSeenInitialNotice;
  }

  Future<void> markNoticeAsSeen() async {
    if (_currentUserId == null || _prefs == null) return;
    _hasSeenInitialNotice = true;
    await _prefs!.setBool('has_seen_initial_notice_$_currentUserId', true);
    notifyListeners();
  }

  Map<String, TestResult> get results => _results;
  bool get isInitialized => _prefs != null;

  bool isTestCompleted(String testId) {
    _checkAndResetDaily();
    return _results.containsKey(testId);
  }

  int getCompletedCount() {
    _checkAndResetDaily();
    return _results.length;
  }

  TestResult? getTestResult(String testId) {
    return _results[testId];
  }

  int getDaysUntilRetake() {
    if (_results.isEmpty) return 0;

    DateTime latestTestDate =
        _results.values.map((r) => r.date).reduce((a, b) => a.isAfter(b) ? a : b);
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextDay = today.add(const Duration(days: 1));
    
    if (now.isBefore(nextDay)) {
      final difference = nextDay.difference(now).inHours;
      return max(0, (difference / 24).ceil());
    }
    return 0;
  }

  void addTestResult(TestResult result) {
    _results[result.testId] = result;
    _saveResults();
    notifyListeners();
  }

  Future<void> _saveResults() async {
    if (_currentUserId == null || _prefs == null) return;
    final String encoded = json.encode(_results.map((key, value) => MapEntry(key, value.toJson())));
    await _prefs!.setString('test_results_$_currentUserId', encoded);
  }

  void clearResults() {
    _results.clear();
    _saveResults();
    notifyListeners();
  }
}
