import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/test_api_service.dart';
import 'test_results_provider.dart';

class DynamicTestPage extends StatefulWidget {
  final String testId;

  const DynamicTestPage({super.key, required this.testId});

  @override
  State<DynamicTestPage> createState() => _DynamicTestPageState();
}

class _DynamicTestPageState extends State<DynamicTestPage> {
  Map<String, dynamic>? _currentQuestion;
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, String> _answers = {};
  int _totalScore = 0;
  bool _isFinished = false;
  String _finalInterpretation = "Minimal";

  // Theme colors
  static const Color primaryColor = Color(0xFF6B9BD1);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF6C7A89);
  static const Color backgroundColor = Color(0xFFF5F9FC);
  static const Color cardBackground = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  Future<void> _startTest() async {
    setState(() => _isLoading = true);
    try {
      final response = await TestApiService.startAssessment(widget.testId);
      setState(() {
        _currentQuestion = response['question'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAnswer(String option) async {
    setState(() => _isLoading = true);
    
    // Store answer
    final questionId = _currentQuestion!['id'];
    _answers[questionId] = option;
    
    // Add to score
    final severity = _currentQuestion!['severity_map'][option] ?? 0;
    _totalScore += (severity as num).toInt();

    try {
      final response = await TestApiService.answerQuestion(
        testType: widget.testId,
        currentQuestionId: questionId,
        answer: option,
      );

      final next = response['next'];
      if (next != null && next['end'] == true) {
        _finishTest();
      } else if (next != null) {
        setState(() {
          _currentQuestion = next;
          _isLoading = false;
        });
      } else {
        _finishTest();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _finishTest() async {
    setState(() => _isLoading = true);
    
    try {
      // The backend now calculates the interpretation based on score and number of questions
      final response = await TestApiService.submitResults(
        testType: widget.testId,
        score: _totalScore,
        resultText: "", // Backend will override this
        answers: _answers,
      );

      // In a real app, the backend would return the final diagnosis
      // For now, we use a simple calculation but better than before
      final interpretation = response['result_text'] ?? "Minimal";

      // Update local provider
      final provider = context.read<TestResultsProvider>();
      provider.addTestResult(TestResult(
        testId: widget.testId,
        score: _totalScore,
        label: interpretation,
        msg: "Based on your clinical responses.",
        color: _getColorForInterpretation(interpretation),
        date: DateTime.now(),
      ));

      setState(() {
        _finalInterpretation = interpretation;
        _isFinished = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to submit results: $e";
        _isLoading = false;
      });
    }
  }

  String _calculateResultOnProbability() {
    if (_answers.isEmpty) return "Minimal";
    
    // Maximum severity is usually 4/5 per question
    double maxSeverityPerQuestion = 4.0;
    double normalized = (_totalScore / (_answers.length * maxSeverityPerQuestion)) * 100;

    if (normalized < 25) return "Minimal";
    if (normalized < 50) return "Mild";
    if (normalized < 75) return "Moderate";
    return "Severe";
  }

  Color _getColorForInterpretation(String label) {
    switch (label) {
      case "Minimal": return Colors.green;
      case "Mild": return Colors.blue;
      case "Moderate": return Colors.orange;
      case "Severe": return Colors.red;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error: $_errorMessage", style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
            ],
          ),
        ),
      );
    }

    if (_isFinished) {
      return _buildResultsScreen();
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _buildQuestionScreen();
  }

  Widget _buildQuestionScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('${widget.testId.toUpperCase()} Assessment'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: (_answers.length + 1) / 10,
              backgroundColor: Colors.black12,
              valueColor: const AlwaysStoppedAnimation(primaryColor),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Phase ${(_answers.length ~/ 3) + 1} - Question ${_answers.length + 1}",
                    style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentQuestion!['text'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: _currentQuestion!['options'].length,
                itemBuilder: (context, index) {
                  final option = _currentQuestion!['options'][index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _handleAnswer(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cardBackground,
                        foregroundColor: textPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                      child: Text(option, textAlign: TextAlign.center),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getColorForInterpretation(_finalInterpretation).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.analytics_outlined, color: _getColorForInterpretation(_finalInterpretation), size: 100),
                ),
                const SizedBox(height: 24),
                const Text("Assessment Complete", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text("Analysis indicates:", style: TextStyle(color: textSecondary)),
                const SizedBox(height: 8),
                Text(
                  _finalInterpretation,
                  style: TextStyle(
                    fontSize: 32, 
                    color: _getColorForInterpretation(_finalInterpretation), 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  )
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Score: $_totalScore points across ${_answers.length} indicators.",
                    style: const TextStyle(fontSize: 14, color: textSecondary),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, 
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Return to Dashboard", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
