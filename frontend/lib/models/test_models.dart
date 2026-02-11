import 'package:flutter/material.dart';

// ============================================================================
// DATA MODELS
// ============================================================================

class TestQuestion {
  final String id;
  final String text;
  final String type;
  final List<String> options;
  final List<int> values;

  TestQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.values,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    return TestQuestion(
      id: json['id'],
      text: json['text'],
      type: json['type'],
      options: List<String>.from(json['options']),
      values: List<int>.from(json['values']),
    );
  }
}

class TestInterpretation {
  final String label;
  final Color color;
  final String message;

  TestInterpretation({
    required this.label,
    required this.color,
    required this.message,
  });
}

class TestData {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String description;
  final String timeframe;
  final int questionCount;
  final String estimatedTime;
  final List<TestQuestion> questions;
  final int maxScore;
  final String? nextTestRoute;

  TestData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
    required this.timeframe,
    required this.questionCount,
    required this.estimatedTime,
    required this.questions,
    required this.maxScore,
    this.nextTestRoute,
  });

  factory TestData.fromJson(Map<String, dynamic> json) {
    return TestData(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      icon: json['icon'],
      description: json['description'],
      timeframe: json['timeframe'],
      questionCount: json['questionCount'],
      estimatedTime: json['estimatedTime'],
      questions: (json['questions'] as List)
          .map((q) => TestQuestion.fromJson(q))
          .toList(),
      maxScore: json['maxScore'],
      nextTestRoute: json['nextTest'],
    );
  }

  // Interpretation logic
  TestInterpretation interpret(int rawScore) {
    switch (id) {
      case 'baseline':
        final scaledScore = rawScore * 4;
        if (scaledScore <= 28) {
          return TestInterpretation(
            label: 'Very Low',
            color: const Color(0xFFE89E98),
            message:
                'Your wellbeing score is very low. Professional support is strongly recommended.',
          );
        } else if (scaledScore <= 49) {
          return TestInterpretation(
            label: 'Low',
            color: const Color(0xFFF4C96F),
            message:
                'Your wellbeing is below the healthy threshold. Consider self-care practices and speaking to a professional.',
          );
        } else if (scaledScore <= 70) {
          return TestInterpretation(
            label: 'Moderate',
            color: const Color(0xFFF4A59C),
            message:
                'You\'re in an average range. Keep monitoring and nurturing your wellbeing.',
          );
        }
        return TestInterpretation(
          label: 'Good',
          color: const Color(0xFF7FC29B),
          message: 'Your wellbeing is healthy! Keep up the positive routines.',
        );

      case 'anxiety-screening':
        if (rawScore <= 4) {
          return TestInterpretation(
            label: 'Minimal',
            color: const Color(0xFF7FC29B),
            message: 'Your anxiety levels are minimal.',
          );
        } else if (rawScore <= 9) {
          return TestInterpretation(
            label: 'Mild',
            color: const Color(0xFFF4C96F),
            message:
                'You\'re experiencing mild anxiety. Self-care and monitoring recommended.',
          );
        } else if (rawScore <= 14) {
          return TestInterpretation(
            label: 'Moderate',
            color: const Color(0xFFF4A59C),
            message:
                'Moderate anxiety detected. Consider speaking with a professional.',
          );
        }
        return TestInterpretation(
          label: 'Severe',
          color: const Color(0xFFE89E98),
          message:
              'Severe anxiety detected. Professional support is strongly recommended.',
        );

      case 'depression-screening':
        if (rawScore <= 4) {
          return TestInterpretation(
            label: 'Minimal',
            color: const Color(0xFF7FC29B),
            message: 'Minimal or no depression.',
          );
        } else if (rawScore <= 9) {
          return TestInterpretation(
            label: 'Mild',
            color: const Color(0xFFF4C96F),
            message: 'Mild depression. Monitor your symptoms.',
          );
        } else if (rawScore <= 14) {
          return TestInterpretation(
            label: 'Moderate',
            color: const Color(0xFFF4A59C),
            message: 'Moderate depression. Consider professional support.',
          );
        } else if (rawScore <= 19) {
          return TestInterpretation(
            label: 'Moderately Severe',
            color: const Color(0xFFE89E98),
            message:
                'Moderately severe depression. Professional help recommended.',
          );
        }
        return TestInterpretation(
          label: 'Severe',
          color: const Color(0xFFE89E98),
          message:
              'Severe depression. Immediate professional support is strongly recommended.',
        );

      case 'stress-resilience':
        final percentage = (rawScore / maxScore) * 100;
        if (percentage <= 25) {
          return TestInterpretation(
            label: 'Low Stress',
            color: const Color(0xFF7FC29B),
            message: 'You\'re managing stress well.',
          );
        } else if (percentage <= 50) {
          return TestInterpretation(
            label: 'Moderate Stress',
            color: const Color(0xFFF4C96F),
            message: 'Some stress present. Practice self-care.',
          );
        } else if (percentage <= 75) {
          return TestInterpretation(
            label: 'High Stress',
            color: const Color(0xFFF4A59C),
            message:
                'High stress levels. Consider stress management techniques.',
          );
        }
        return TestInterpretation(
          label: 'Very High Stress',
          color: const Color(0xFFE89E98),
          message: 'Very high stress. Professional support recommended.',
        );

      default:
        return TestInterpretation(
          label: 'Complete',
          color: const Color(0xFF7FC29B),
          message: 'Assessment complete.',
        );
    }
  }
}
