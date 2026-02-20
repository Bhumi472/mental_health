import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

class MemoryLaneGame extends StatefulWidget {
  const MemoryLaneGame({super.key});

  @override
  State<MemoryLaneGame> createState() => _MemoryLaneGameState();
}

class _MemoryLaneGameState extends State<MemoryLaneGame> {
  final List<String> _buttonColors = ['red', 'blue', 'green', 'yellow'];

  List<String> _gamePattern = [];
  List<String> _userClickedPattern = [];

  bool _started = false;
  bool _isShowingSequence = false;
  bool _isGameOver = false;

  int _level = 0;
  String _titleText = 'Press Start to Begin';

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _showGameOverFlash = false;

  final Map<String, String> _buttonState = {
    'red': 'normal',
    'blue': 'normal',
    'green': 'normal',
    'yellow': 'normal',
  };

  static const Map<String, Color> _baseColors = {
    'red': Color(0xFFFF0000),
    'blue': Color(0xFF0000FF),
    'green': Color(0xFF008000),
    'yellow': Color(0xFFFFFF00),
  };

  static const Map<String, Color> _flashColors = {
    'red': Color(0xFFFF8080),
    'blue': Color(0xFF8080FF),
    'green': Color(0xFF80C080),
    'yellow': Color(0xFFFFFF80),
  };

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String name) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$name.mp3'));
    } catch (_) {}
  }

  Future<void> _flashButton(String color) async {
    setState(() => _buttonState[color] = 'flashing');
    await _playSound(color);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _buttonState[color] = 'normal');
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> _animatePress(String color) async {
    setState(() => _buttonState[color] = 'pressed');
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _buttonState[color] = 'normal');
  }

  Future<void> _startGame() async {
    if (_started) return;

    setState(() {
      _started = true;
      _level = 0;
      _gamePattern = [];
      _userClickedPattern = [];
      _isGameOver = false;
      _titleText = 'Level $_level';
    });

    await _nextSequence();
  }

  Future<void> _nextSequence() async {
    setState(() {
      _userClickedPattern = [];
      _level++;
      _titleText = 'Level $_level';
      _isShowingSequence = true;
    });

    final rand = Random();
    final randomColor = _buttonColors[rand.nextInt(4)];
    _gamePattern.add(randomColor);

    await Future.delayed(const Duration(milliseconds: 600));

    for (final color in _gamePattern) {
      await _flashButton(color);
    }

    setState(() => _isShowingSequence = false);
  }

  Future<void> _handleButtonTap(String color) async {
    if (_isShowingSequence || !_started || _isGameOver) return;

    _userClickedPattern.add(color);
    await _playSound(color);
    await _animatePress(color);

    _checkAnswer(_userClickedPattern.length - 1);
  }

  void _checkAnswer(int currentIndex) {
    if (_gamePattern[currentIndex] == _userClickedPattern[currentIndex]) {
      if (_userClickedPattern.length == _gamePattern.length) {
        Future.delayed(const Duration(milliseconds: 1000), _nextSequence);
      }
    } else {
      _playSound('wrong');
      _triggerGameOver();
    }
  }

  void _triggerGameOver() {
    setState(() {
      _isGameOver = true;
      _titleText = 'Game Over! Tap Start to Restart';
      _showGameOverFlash = true;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _showGameOverFlash = false);
    });

    _startOver();
  }

  void _startOver() {
    setState(() {
      _level = 0;
      _gamePattern = [];
      _started = false;
    });
  }

  Widget _buildGameButton(String color) {
    final state = _buttonState[color]!;
    final bool isFlashing = state == 'flashing';
    final bool isPressed = state == 'pressed';

    Color bgColor;
    BoxDecoration decoration;

    if (isPressed) {
      bgColor = Colors.grey;
      decoration = BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.black, width: 6),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha(230),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      );
    } else if (isFlashing) {
      bgColor = _flashColors[color]!;
      decoration = BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.black, width: 6),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha(204),
            blurRadius: 24,
            spreadRadius: 6,
          ),
        ],
      );
    } else {
      bgColor = _baseColors[color]!;
      decoration = BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.black, width: 6),
        borderRadius: BorderRadius.circular(28),
      );
    }

    return GestureDetector(
      onTap: () => _handleButtonTap(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 150,
        height: 150,
        decoration: decoration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _showGameOverFlash
          ? Colors.red.withAlpha(204)
          : const Color(0xFF011F3F),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Text(
                _titleText,
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 22,
                  color: const Color(0xFFFEF2BF),
                ),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _started ? null : _startGame,
              child: Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2BF),
                  border: Border.all(color: Colors.black, width: 4),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Start',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 16,
                    color: const Color(0xFF011F3F),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGameButton('green'),
                const SizedBox(width: 20),
                _buildGameButton('red'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGameButton('yellow'),
                const SizedBox(width: 20),
                _buildGameButton('blue'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
