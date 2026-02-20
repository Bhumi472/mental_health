import 'package:flutter/material.dart';

class HomeTheme {
  const HomeTheme._();
  static const borderRadius = 16.0;

  static final BoxShadow cardShadow = BoxShadow(
    color: const Color(0xFF6B9BD1).withAlpha(38), // 15% opacity
    blurRadius: 32,
    offset: const Offset(0, 8),
  );

  static final BoxShadow softShadow = BoxShadow(
    color: Colors.black.withAlpha(13), // 5% opacity
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
}

class HomeColors {
  const HomeColors._();

  static const Color background = Color(0xFFF5F9FC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color primary = Color(0xFF6B9BD1);
}
