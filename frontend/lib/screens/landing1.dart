import 'package:flutter/material.dart';
import 'dart:async'; // Added for Timer
import 'package:google_fonts/google_fonts.dart'; // Added for fonts

// Theme constants
class AppTheme {
  static const borderRadius = 16.0;
  static const effects = AppEffects();
}

class AppColors {
  const AppColors._();
  static const Color primary = Color(0xFF6366F1);
}

class AppShadows {
  const AppShadows._();

  static const BoxShadow glow = BoxShadow(
    color: Color.fromRGBO(99, 102, 241, 0.4),
    blurRadius: 24,
    spreadRadius: 0,
  );

  static const BoxShadow soft = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    blurRadius: 8,
    spreadRadius: 0,
  );

  static const BoxShadow card = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.08),
    blurRadius: 12,
    spreadRadius: 0,
  );

  static const BoxShadow innerGlow = BoxShadow(
    color: Color.fromRGBO(99, 102, 241, 0.3),
    blurRadius: 16,
    spreadRadius: 0,
  );
}

class AppGradients {
  const AppGradients._();

  static const LinearGradient ocean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const LinearGradient forest = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  static const LinearGradient sunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF38EF7D), Color(0xFFFF5858)],
  );

  static const LinearGradient peace = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  );

  static const LinearGradient primaryGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );
}

class AppEffects {
  const AppEffects();

  BoxDecoration get glassCard => BoxDecoration(
        color: Colors.white.withAlpha(51), // 20% opacity
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withAlpha(77), // 30% opacity
          width: 1,
        ),
        backgroundBlendMode: BlendMode.overlay,
      );

  BoxDecoration get glass => BoxDecoration(
        color: Colors.white.withAlpha(38), // 15% opacity
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(
          color: Colors.white.withAlpha(51), // 20% opacity
          width: 1,
        ),
      );
}

// Onboarding slide model
class OnboardingSlide {
  final String title;
  final String description;
  final LinearGradient gradient;
  final String imagePath;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.gradient,
    required this.imagePath,
  });
}

class Landing1 extends StatefulWidget {
  const Landing1({super.key});

  @override
  State<Landing1> createState() => _Landing1State();
}

class _Landing1State extends State<Landing1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;

  // New Gradients as per request
  static const List<LinearGradient> _gradients = [
    LinearGradient( // Welcome page
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6B9BD1), Color(0xFFA8C5A5)],
    ),
    LinearGradient( // Understand yourself better
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFA5C3A8), Color(0xFFF4A59C)],
    ),
    LinearGradient( // Evidence based exercises
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFECA89D), Color(0xFF6B9BD1)],
    ),
    LinearGradient( // You're not alone
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF719CCF), Color(0xFFB0C8A0)],
    ),
  ];

  final List<OnboardingSlide> onboardingSlides = const [
    OnboardingSlide(
      title: "Welcome to MindfulCare",
      description: "Your personalized mental health companion",
      gradient: AppGradients.ocean, // Overridden by _gradients[index]
      imagePath: 'assets/images/Baseline welcome.png', // Fixed path
    ),
    OnboardingSlide(
      title: "Understand Yourself Better",
      description: "Take validated assessments to track your mental health",
      gradient: AppGradients.forest,
      imagePath: 'assets/images/Understand urself.png', // Corrected path
    ),
    OnboardingSlide(
      title: "Evidence-Based Exercises",
      description: "Access 12+ unique activities tailored to your needs",
      gradient: AppGradients.sunset,
      imagePath: 'assets/images/Evidence lp.png',
    ),
    OnboardingSlide(
      title: "You're Not Alone",
      description: "Connect with a supportive community",
      gradient: AppGradients.peace,
      imagePath: 'assets/images/Community lp.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_pageController.hasClients && _currentPage < onboardingSlides.length - 1) {
        try {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          debugPrint("Error auto-advancing page: $e");
          timer.cancel(); // Stop trying if it fails
        }
      } else {
        // Loop back to start instead of stopping
        _pageController.animateToPage(0, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: _gradients[_currentPage],
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Dot Pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(painter: DotPatternPainter()),
                      ),
                    ),
                    
                    // PageView
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: onboardingSlides.length,
                      itemBuilder: (context, index) {
                        final slide = onboardingSlides[index];
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image with Glass Effect
                              Container(
                                width: 200, // Increased size for impact
                                height: 200,
                                margin: const EdgeInsets.only(bottom: 40),
                                padding: const EdgeInsets.all(20),
                                decoration: AppTheme.effects.glassCard.copyWith(
                                  boxShadow: [AppShadows.glow],
                                ),
                                child: Image.asset(
                                  slide.imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60, color: Colors.white),
                                ),
                              ),
                              
                              // Title
                              Text(
                                slide.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins( // Changed to Poppins for professional look
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold, // Added bold
                                  color: Colors.white,
                                  shadows: [
                                    const Shadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.2),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Description
                              Text(
                                slide.description,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins( // Changed to Poppins for consistency
                                  fontSize: 18,
                                  color: Colors.white.withAlpha(242),
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Navigation
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column( // Changed to Column to center indicators above buttons
                  children: [
                   // Indicators (Center)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingSlides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4), // Reduced margin
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(_currentPage == index ? 255 : 100),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        if (_currentPage > 0)
                          GestureDetector(
                            onTap: () {
                              _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5FC3B0), // Requested Back Color
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [AppShadows.card],
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  color: Colors.white, // White font
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        else
                           const SizedBox(), // Spacer to keep layout balanced if needed, or just let SpaceBetween handle it

                        // Next/Get Started Button
                        GestureDetector(
                          onTap: () {
                            // As requested, Continue button now goes to Auth Choice page
                            Navigator.pushNamed(context, '/auth-choice');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B9BD1), // Requested Continue Color
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [AppShadows.card],
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white, // White font
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for dot pattern
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(38) // 15% opacity
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    const dotRadius = 1.0;

    for (double x = 2; x < size.width; x += spacing) {
      for (double y = 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Reusable glass button widget
class _GlassButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _GlassButton({
    required this.onPressed,
    required this.child,
  });

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52,
          decoration: AppTheme.effects.glass.copyWith(
            boxShadow: [AppShadows.card],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            child: IconTheme(
              data: const IconThemeData(color: AppColors.primary),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable primary button widget
class _PrimaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _PrimaryButton({
    required this.onPressed,
    required this.child,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGlow,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            boxShadow: [AppShadows.innerGlow],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
