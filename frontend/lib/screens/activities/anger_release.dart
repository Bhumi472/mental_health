import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;
import 'dart:async';

class AngerRelease extends StatefulWidget {
  const AngerRelease({super.key});

  @override
  State<AngerRelease> createState() => _AngerReleaseState();
}

class _AngerReleaseState extends State<AngerRelease> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  // Theme Colors
  final Color _darkBg = Colors.black;
  final Color _lightBg = const Color(0xFFD7D8DA);
  bool _isDarkMode = true; // Default to dark for fire effect

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize Fire Video
    _videoController = VideoPlayerController.asset("assets/Video/Calm_Flame_Video_Generation.mp4")
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
          _videoController.setLooping(true);
          _videoController.setVolume(0); // Silence? Or calming crackle? User said "calm", maybe silence is safer.
          _videoController.play();
        });
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? _darkBg : _lightBg,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text('Anger Release', style: GoogleFonts.poppins(color: _isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: _isDarkMode ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, color: _isDarkMode ? Colors.white : Colors.black),
            onPressed: _toggleTheme,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE53E3E),
          unselectedLabelColor: _isDarkMode ? Colors.grey : Colors.grey[700],
          indicatorColor: const Color(0xFFE53E3E),
          tabs: const [
            Tab(text: "Write & Burn"),
            Tab(text: "Scribble & Throw"),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. Background Video (Fire)
          if (_isVideoInitialized)
            Positioned.fill(
              child: Opacity(
                opacity: 0.3, // Subtle background
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
            ),
          
          // 2. Tab Content
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              WriteBurnTab(isDarkMode: _isDarkMode),
              ScribbleThrowTab(isDarkMode: _isDarkMode),
            ],
          ),
        ],
      ),
    );
  }
}

// --- TAB 1: WRITE & BURN ---
class WriteBurnTab extends StatefulWidget {
  final bool isDarkMode;
  const WriteBurnTab({super.key, required this.isDarkMode});

  @override
  State<WriteBurnTab> createState() => _WriteBurnTabState();
}

class _WriteBurnTabState extends State<WriteBurnTab> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  
  // Animation Controllers
  late AnimationController _burnController;
  late AnimationController _entryController;
  late Animation<double> _shaderAnimation;
  late Animation<Offset> _slideAnimation;

  // Parchment Color
  final Color _parchmentColor = const Color(0xFFE3DAC9); // Parchment

  @override
  void initState() {
    super.initState();
    
    // Burn Animation (0.0 -> 1.0)
    // 0.0 = Normal, 1.0 = Fully burnt (Transparent/Ash)
    _burnController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _shaderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _burnController, curve: Curves.easeInOut));
    
    // Entry Animation (Slide from Top)
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack)
    );
    
    _entryController.forward(); // Initial slide in
    
    _burnController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Reset Logic
        setState(() {
          _textController.clear();
          _burnController.reset();
        });
        // Short delay then slide new paper in
        Timer(const Duration(milliseconds: 200), () {
           _entryController.reset();
           _entryController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _burnController.dispose();
    _entryController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _burnIt() {
    if (_textController.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    _burnController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 60), // Spacing
          Text(
            "Write your worries. Watch them burn.",
            style: GoogleFonts.inter(
              fontSize: 14, 
              color: widget.isDarkMode ? Colors.white70 : Colors.black87
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([_burnController, _entryController]),
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      // Burning Edge Gradient
                      // Progress 0.0 -> Normal
                      // Progress 0.5 -> Half burnt
                      // Progress 1.0 -> Gone
                      // Create a gradient that moves vertically or radially? Let's do vertical bottom-up
                      
                      final t = _shaderAnimation.value;
                      if (t == 0) return const LinearGradient(colors: [Colors.white, Colors.white]).createShader(bounds);
                      
                      return LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: const [
                          Colors.transparent, // Ash/Gone
                          Colors.transparent, // Ash/Gone
                          Colors.black,       // Charred edge
                          Color(0xFFE53E3E),  // Fire Red
                          Color(0xFFFF9800),  // Fire Orange
                          Colors.white,       // Visible Paper
                        ],
                        stops: [
                          0.0,
                          math.max(0.0, t - 0.1),
                          t, 
                          math.min(1.0, t + 0.05),
                          math.min(1.0, t + 0.1), 
                          math.min(1.0, t + 0.2)
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn, // The mask alpha determines visibility
                    child: Container(
                      decoration: BoxDecoration(
                        color: _parchmentColor,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                        image: const DecorationImage(
                           image: NetworkImage("https://www.transparenttextures.com/patterns/aged-paper.png"), // Subtle noise if available, else fallback to color
                           opacity: 0.1,
                           fit: BoxFit.cover,
                        )
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: "Vent here...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(24),
                        ),
                        style: GoogleFonts.caveat(fontSize: 24, color: const Color(0xFF2D3748)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: (_burnController.isAnimating || _entryController.isAnimating) ? null : _burnIt,
            icon: const Icon(Icons.fireplace, color: Colors.white),
            label: const Text("Burn It"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}


// --- TAB 2: SCRIBBLE & THROW ---
class ScribbleThrowTab extends StatefulWidget {
  final bool isDarkMode;
  const ScribbleThrowTab({super.key, required this.isDarkMode});

  @override
  State<ScribbleThrowTab> createState() => _ScribbleThrowTabState();
}

class _ScribbleThrowTabState extends State<ScribbleThrowTab> with TickerProviderStateMixin {
  List<DrawingPoint?> points = [];
  Color selectedColor = Colors.black; 
  late AnimationController _tossController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _pathAnimation;
  late Animation<double> _morphAnimation; // 0.0 (Rect) -> 1.0 (Ball)

  final List<Color> colors = [
    Colors.black, Colors.red, Colors.blue, Colors.green, Colors.purple
  ];

  @override
  void initState() {
    super.initState();
    _tossController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    
    // 1. Morph to ball & Shrink (0-50% time)
    _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tossController, curve: const Interval(0.0, 0.4, curve: Curves.easeInOut))
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _tossController, curve: const Interval(0.0, 0.4, curve: Curves.easeInOut))
    );
    
    // 2. Toss to Bin (Parabolic-ish) (20-100% time)
    _pathAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(10.0, 10.0)).animate( // Fly off screen
       CurvedAnimation(parent: _tossController, curve: const Interval(0.3, 1.0, curve: Curves.easeInQuad))
    );
    
    // 3. Rotate wildly
    _rotationAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(_tossController);

    _tossController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          points.clear();
          _tossController.reset();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Discarded.")));
      }
    });
  }

  @override
  void dispose() {
    _tossController.dispose();
    super.dispose();
  }

  void _throwIt() {
    if (points.isEmpty) return;
    _tossController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 60),
          
          // Color Picker
          Container(
             height: 50,
             padding: const EdgeInsets.symmetric(horizontal: 16),
             decoration: BoxDecoration(
               color: widget.isDarkMode ? Colors.white10 : Colors.white,
               borderRadius: BorderRadius.circular(25),
             ),
             child: ListView(
               scrollDirection: Axis.horizontal,
               children: colors.map((color) => GestureDetector(
                 onTap: () => setState(() => selectedColor = color),
                 child: Container(
                   margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                   width: 30,
                   height: 30,
                   decoration: BoxDecoration(
                     color: color,
                     shape: BoxShape.circle,
                     border: Border.all(color: Colors.white, width: selectedColor == color ? 3 : 1),
                     boxShadow: [if(selectedColor == color) const BoxShadow(color: Colors.black26, blurRadius: 4)],
                   ),
                 ),
               )).toList(),
             ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: AnimatedBuilder(
              animation: _tossController,
              builder: (context, child) {
                 final morph = _morphAnimation.value; // 0 (Rect) -> 1 (Circle)
                 final currentRadius = 16.0 * (1 - morph) + 150.0 * morph; // Morph to ball
                 
                 return Transform.translate(
                   offset: Offset(_pathAnimation.value.dx * 100, _pathAnimation.value.dy * 100), // Amplify offset
                   child: Transform.rotate(
                     angle: _rotationAnimation.value,
                     child: Transform.scale(
                       scale: _scaleAnimation.value,
                       child: Container(
                         clipBehavior: Clip.hardEdge,
                         decoration: BoxDecoration(
                           color: const Color(0xFFFDFDFD),
                           borderRadius: BorderRadius.circular(currentRadius),
                           boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                         ),
                         child: GestureDetector(
                           onPanUpdate: (details) {
                             setState(() {
                               points.add(DrawingPoint(details.localPosition, selectedColor));
                             });
                           },
                           onPanEnd: (details) => points.add(null),
                           child: CustomPaint(
                             painter: ScribblePainter(points),
                             size: Size.infinite,
                           ),
                         ),
                       ),
                     ),
                   ),
                 );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: (_tossController.isAnimating) ? null : _throwIt,
            icon: const Icon(Icons.delete_sweep, color: Colors.white), 
            label: const Text("Toss It"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class DrawingPoint {
  final Offset point;
  final Color color;
  DrawingPoint(this.point, this.color);
}

class ScribblePainter extends CustomPainter {
  final List<DrawingPoint?> points;
  ScribblePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i+1] != null) {
        paint.color = points[i]!.color;
        canvas.drawLine(points[i]!.point, points[i+1]!.point, paint);
      }
    }
  }
  @override
  bool shouldRepaint(ScribblePainter oldDelegate) => true;
}
