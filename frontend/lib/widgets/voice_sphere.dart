import 'package:flutter/material.dart';
import 'dart:math' as math;

class VoiceSphere extends StatefulWidget {
  final bool isListening;
  final VoidCallback onStop;

  const VoiceSphere({
    super.key,
    required this.isListening,
    required this.onStop,
  });

  @override
  State<VoiceSphere> createState() => _VoiceSphereState();
}

class _VoiceSphereState extends State<VoiceSphere> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _jitterController;
  
  // We'll simulate volume levels
  double _simulatedVolume = 0.0;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    // Base breathing animation (slow pulse)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Fast jitter animation to simulate voice modulation
    _jitterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(_updateVolumeSimulation)
     ..repeat();
  }

  void _updateVolumeSimulation() {
    if (widget.isListening) {
      // Simulate random voice spikes
      // 70% chance of being "quiet", 30% chance of "talking" spike
      if (_random.nextDouble() > 0.7) {
        setState(() {
          _simulatedVolume = 0.5 + _random.nextDouble() * 0.5; // High volume
        });
      } else {
        setState(() {
          _simulatedVolume = 0.1 + _random.nextDouble() * 0.2; // Low/Silence
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _jitterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isListening) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onStop, // Tap to stop
      child: Container(
        color: Colors.black54, // Dim background
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_pulseController, _jitterController]),
              builder: (context, child) {
                // Combine slow breath with fast jitter
                // Base scale is 1.0. Breath adds up to 0.1. Volume adds up to 0.4.
                double scale = 1.0 + 
                             (_pulseController.value * 0.1) + 
                             (_simulatedVolume * 0.4);

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.purple.shade300,
                          Colors.blue.shade400.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                        stops: const [0.2, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.5),
                          blurRadius: 30 * scale, // Blur also expands
                          spreadRadius: 10 * scale,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.mic, 
                        color: Colors.white, 
                        size: 40 * (1 + _simulatedVolume * 0.2), // Icon also pulses slightly
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
            const Text(
              "Listening...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.none,
                fontFamily: 'Lato', 
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: widget.onStop,
              child: const Text("Tap anywhere to Stop", style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
