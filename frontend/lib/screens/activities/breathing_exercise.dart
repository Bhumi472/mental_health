import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;

class BreathingExercise extends StatefulWidget {
  const BreathingExercise({super.key});

  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

enum BreathingMode { circle, box }

class _BreathingExerciseState extends State<BreathingExercise> with TickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circleAnimation;
  
  late AnimationController _boxController;

  BreathingMode _mode = BreathingMode.circle;
  String _instruction = "Get Ready";
  Timer? _timer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Circle Animation (Physiological Sigh -> Now 4-4-4-4)
    // We will control this manually with animateTo to sequecing the 4 steps
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _circleAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );
    _circleController.addStatusListener(_onCircleStatusChanged);

    // Box Animation (Square Breathing)
    _boxController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16), // 4s * 4 sides
    );
  }

  @override
  void dispose() {
    _circleController.dispose();
    _boxController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleMode(BreathingMode mode) {
    if (_isPlaying) _stopBreathing();
    setState(() {
      _mode = mode;
      _instruction = "Get Ready";
    });
  }

  void _startBreathing() {
    setState(() => _isPlaying = true);
    if (_mode == BreathingMode.circle) {
      _runCircleCycle();
    } else {
      _runBoxCycle();
    }
  }

  void _stopBreathing() {
    setState(() {
      _isPlaying = false;
      _instruction = "Paused";
    });
    _circleController.stop();
    _boxController.stop();
    _timer?.cancel();
  }

  // --- 4-4-4-4 Circle Logic ---
  void _runCircleCycle() {
    if (!mounted || !_isPlaying) return;
    
    // Start the cycle: Inhale (Expand)
    _startInhale();
  }

  void _startInhale() {
    if (!mounted || !_isPlaying) return;
    setState(() => _instruction = "Inhale (4s)");
    _circleController.duration = const Duration(seconds: 4);
    _circleController.forward();
  }

  void _onCircleStatusChanged(AnimationStatus status) {
    if (!_isPlaying || _mode != BreathingMode.circle) return;

    if (status == AnimationStatus.completed) {
      // Finished Inhaling -> Hold (4s)
      setState(() => _instruction = "Hold (4s)");
      Timer(const Duration(seconds: 4), () {
        if (!mounted || !_isPlaying) return;
        _startExhale(); // Then Exhale
      });
    } else if (status == AnimationStatus.dismissed) {
      // Finished Exhaling -> Hold (4s)
      setState(() => _instruction = "Hold (4s)");
      Timer(const Duration(seconds: 4), () {
        if (!mounted || !_isPlaying) return;
        _startInhale(); // Loop back to Inhale
      });
    }
  }

  void _startExhale() {
    if (!mounted || !_isPlaying) return;
    setState(() => _instruction = "Exhale (4s)");
    _circleController.duration = const Duration(seconds: 4);
    _circleController.reverse();
  }

  // --- Box Breathing Logic ---
  void _runBoxCycle() async {
    if (!mounted || !_isPlaying) return;
    
    _boxController.repeat(); // Loops 0.0 -> 1.0 over 16 seconds
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_isPlaying) {
        timer.cancel();
        return;
      }
      
      final value = _boxController.value;
      if (value < 0.25) {
        if (_instruction != "Inhale (4s)") setState(() => _instruction = "Inhale (4s)");
      } else if (value < 0.50) {
        if (_instruction != "Hold (4s)") setState(() => _instruction = "Hold (4s)");
      } else if (value < 0.75) {
         if (_instruction != "Exhale (4s)") setState(() => _instruction = "Exhale (4s)");
      } else {
         if (_instruction != "Hold (4s)") setState(() => _instruction = "Hold (4s)");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text('Breathing Exercise', style: GoogleFonts.poppins(color: const Color(0xFF2D3748))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF2D3748)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Toggle Segmented Control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleBtn("Circle Mode", BreathingMode.circle),
                _buildToggleBtn("Box Mode", BreathingMode.box),
              ],
            ),
          ),
          
          Expanded(
            child: Center(
              child: _mode == BreathingMode.circle 
                  ? _buildCircleVisual() 
                  : _buildBoxVisual(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Inhale, Hold, Exhale, Hold. Equal duration (4s).",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF718096),
              ),
            ),
          ),
          const SizedBox(height: 40),

          GestureDetector(
            onTap: _isPlaying ? _stopBreathing : _startBreathing,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF6B9BD1),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B9BD1).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _isPlaying ? "Stop" : "Start",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, BreathingMode mode) {
    bool isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => _toggleMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B9BD1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFFA0AEC0),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleVisual() {
    return AnimatedBuilder(
      animation: _circleAnimation,
      builder: (context, child) {
        return Container(
          width: 200 * _circleAnimation.value,
          height: 200 * _circleAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF6B9BD1).withOpacity(0.4),
                const Color(0xFF6B9BD1).withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B9BD1).withOpacity(0.2),
                blurRadius: 30 * _circleAnimation.value,
                spreadRadius: 10,
              )
            ],
          ),
          child: Center(
            child: Container(
              width: 180 * _circleAnimation.value,
              height: 180 * _circleAnimation.value,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  _instruction,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoxVisual() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        children: [
          Center(
            child: Text(
              _instruction,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _boxController,
              builder: (context, child) {
                return CustomPaint(
                  painter: BoxBreathingPainter(progress: _boxController.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BoxBreathingPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  BoxBreathingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: 200, height: 200);
    
    path.addRect(rect);
    canvas.drawPath(path, paint); 

    final activePaint = Paint()
      ..color = const Color(0xFF6B9BD1)
      ..style = PaintingStyle.fill;
      
    // Calculate position
    Offset dotPos;
    if (progress < 0.25) {
      // Top: (-100, -100) -> (100, -100)
      double t = progress / 0.25;
      dotPos = Offset(rect.left + (rect.width * t), rect.top);
    } else if (progress < 0.50) {
      // Right: (100, -100) -> (100, 100)
      double t = (progress - 0.25) / 0.25;
      dotPos = Offset(rect.right, rect.top + (rect.height * t));
    } else if (progress < 0.75) {
      // Bottom: (100, 100) -> (-100, 100)
      double t = (progress - 0.50) / 0.25;
      dotPos = Offset(rect.right - (rect.width * t), rect.bottom);
    } else {
      // Left: (-100, 100) -> (-100, -100)
      double t = (progress - 0.75) / 0.25;
      dotPos = Offset(rect.left, rect.bottom - (rect.height * t));
    }

    // Draw Trail
    for (int i = 1; i <= 5; i++) {
        double trailProgress = progress - (0.005 * i);
        if (trailProgress < 0) trailProgress += 1.0;
        
        Offset trailPos = _getPosForProgress(trailProgress, rect);
        canvas.drawCircle(trailPos, 8.0 - i, activePaint..color = const Color(0xFF6B9BD1).withOpacity(1.0 - (i * 0.15)));
    }

    canvas.drawCircle(dotPos, 10.0, Paint()..color = const Color(0xFF6B9BD1));
  }
  
  Offset _getPosForProgress(double p, Rect rect) {
     if (p < 0.25) {
      double t = p / 0.25;
      return Offset(rect.left + (rect.width * t), rect.top);
    } else if (p < 0.50) {
      double t = (p - 0.25) / 0.25;
      return Offset(rect.right, rect.top + (rect.height * t));
    } else if (p < 0.75) {
      double t = (p - 0.50) / 0.25;
      return Offset(rect.right - (rect.width * t), rect.bottom);
    } else {
      double t = (p - 0.75) / 0.25;
      return Offset(rect.left, rect.bottom - (rect.height * t));
    }
  }

  @override
  bool shouldRepaint(covariant BoxBreathingPainter oldDelegate) => oldDelegate.progress != progress;
}
