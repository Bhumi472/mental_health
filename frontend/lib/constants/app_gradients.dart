import 'package:flutter/material.dart';

class AppGradients {
  const AppGradients._();

  static const primaryGlow = LinearGradient(
    colors: [Color(0xFF6B9BD1), Color(0xFF8AB5DD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const serenity = LinearGradient(
    colors: [Color(0xFFA8C5A5), Color(0xFFC2D9BF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const warmth = LinearGradient(
    colors: [Color(0xFFF4C96F), Color(0xFFFFDB89)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const peace = LinearGradient(
    colors: [Color(0xFF9B9BE8), Color(0xFFAFAFF4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const ocean = LinearGradient(
    colors: [Color(0xFF6DD5D5), Color(0xFF8FE5E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sunset = LinearGradient(
    colors: [Color(0xFFE89E98), Color(0xFFF4A59C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const positivity = LinearGradient(
    colors: [Color(0xFF7FC29B), Color(0xFF9FD4B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Quick Access Specific Gradients
  
  static const games = LinearGradient(
    colors: [Color(0xFF4392EB), Color(0xFFC7E3FE), Color(0xFF4392EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const activities = LinearGradient(
    colors: [Color(0xFF83ECE3), Color(0xFFECFFE8), Color(0xFF83ECE3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const community = LinearGradient(
    colors: [Color(0xFFDD5A8A), Color(0xFFF5BED5), Color(0xFFDD5A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const reports = LinearGradient(
    colors: [Color(0xFF9462EE), Color(0xFFC1A4F4), Color(0xFF9462EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const journal = LinearGradient(
    colors: [Color(0xFFD5500E), Color(0xFFEAAD70), Color(0xFFD5500E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const consult = LinearGradient(
    colors: [Color(0xFFF9604F), Color(0xFFFFB5A8), Color(0xFFF9604F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );
}
