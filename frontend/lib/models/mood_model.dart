import 'package:flutter/material.dart';
import '../constants/app_gradients.dart';

class Mood {
  final String emoji;
  final String label;
  final Gradient color;
  final Color baseColor;
  final String imagePath;

  const Mood({
    required this.emoji,
    required this.label,
    required this.color,
    required this.baseColor,
    required this.imagePath,
  });

  static const List<Mood> all = [
    Mood(
        emoji: "😠",
        label: "Angry",
        color: AppGradients.sunset,
        baseColor: Color(0xFFE89E98),
        imagePath: 'assets/images/angry marble.png'),
    Mood(
        emoji: "😨",
        label: "Scared",
        color: AppGradients.peace,
        baseColor: Color(0xFF9B9BE8),
        imagePath: 'assets/images/Scared marble.png'),
    Mood(
        emoji: "😢",
        label: "Sad",
        color: AppGradients.primaryGlow,
        baseColor: Color(0xFF6B9BD1),
        imagePath: 'assets/images/sad marble.png'),
    Mood(
        emoji: "😐",
        label: "Neutral",
        color: AppGradients.ocean,
        baseColor: Color(0xFF6DD5D5),
        imagePath: 'assets/images/neutral marble.png'),
    Mood(
        emoji: "😊",
        label: "Good",
        color: AppGradients.warmth,
        baseColor: Color(0xFFF4C96F),
        imagePath: 'assets/images/Good marble.png'),
    Mood(
        emoji: "😄",
        label: "Great",
        color: AppGradients.positivity,
        baseColor: Color(0xFF7FC29B),
        imagePath: 'assets/images/great marble.png'),
  ];
}

class MarbleData {
  final String id;
  final Mood mood;
  final DateTime date;
  final double x;
  final double y;

  MarbleData({
    required this.id,
    required this.mood,
    required this.date,
    required this.x,
    required this.y,
  });
}
