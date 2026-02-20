import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'test_results_provider.dart';
import 'dynamictest.dart';

class AssessmentTheme {
  static const double borderRadius = 16.0;
  static final BoxShadow cardShadow = BoxShadow(
    color: const Color(0xFF6B9BD1).withAlpha(38),
    blurRadius: 32,
    offset: const Offset(0, 8),
  );
}

class AssessmentColors {
  static const Color background = Color(0xFFF5F9FC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF42474E);
  static const Color primary = Color(0xFF6B9BD1);
  static const Color success = Color(0xFF48BB78);
  static const Color surfaceVariant = Color(0xFFDDE3EA);
}

class TestItem {
  final String id;
  final String name;
  final String subtitle;
  final String duration;
  final int questions;
  final String icon;

  const TestItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.duration,
    required this.questions,
    required this.icon,
  });
}

class TestsPage extends StatelessWidget {
  TestsPage({Key? key}) : super(key: key);

  final List<TestItem> tests = const [
    TestItem(
      id: "anxiety",
      name: "Anxiety Test",
      subtitle: "Comprehensive Assessment",
      duration: "2 min",
      questions: 10,
      icon: "🌊",
    ),
    TestItem(
      id: "burnout",
      name: "Burnout Test",
      subtitle: "Professional Exhaustion Scale",
      duration: "2.5 min",
      questions: 10,
      icon: "🔥",
    ),
    TestItem(
      id: "mood",
      name: "Mood Test",
      subtitle: "Dynamic Mood Assessment",
      duration: "2 min",
      questions: 10,
      icon: "🌈",
    ),
    TestItem(
      id: "stress",
      name: "Stress Test",
      subtitle: "Perceived Stress Scale",
      duration: "3 min",
      questions: 10,
      icon: "⚡",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AssessmentColors.background,
      body: Consumer<TestResultsProvider>(
        builder: (context, testResults, child) {
          final completedCount = testResults.getCompletedCount();
          final totalTests = tests.length;

          return Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewCard(completedCount, totalTests),
                      const SizedBox(height: 24),
                      const Text(
                        'Assessment Tests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AssessmentColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...tests.map((test) {
                        final completed = testResults.isTestCompleted(test.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildTestCard(context, test, completed),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                      _buildAdditionalAssessment(context),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      color: AssessmentColors.cardBackground,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mental Health Assessments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Help us understand you better',
                style: TextStyle(fontSize: 12, color: AssessmentColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(int completedCount, int totalTests) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AssessmentColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete Basic Assessment',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            '4 tests, 41 questions total • ~7.5 minutes',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress', style: TextStyle(color: Colors.white, fontSize: 12)),
              Text('$completedCount/$totalTests completed', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalTests > 0 ? completedCount / totalTests : 0,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, TestItem test, bool completed) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AssessmentColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: completed ? AssessmentColors.success : AssessmentColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (completed ? AssessmentColors.success : AssessmentColors.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(completed ? '✓' : test.icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(test.duration, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 12),
                    Text('${test.questions} questions', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                if (!completed) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DynamicTestPage(testId: test.id)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AssessmentColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Start Test', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (completed) const Icon(Icons.check_circle, color: AssessmentColors.success, size: 20),
        ],
      ),
    );
  }

  Widget _buildAdditionalAssessment(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AssessmentColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AssessmentColors.surfaceVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_border, color: AssessmentColors.primary),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Additional Assessments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Explore more tests to gain deeper insights.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/additional-tests'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AssessmentColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(0, 32),
            ),
            child: const Text('Explore', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
