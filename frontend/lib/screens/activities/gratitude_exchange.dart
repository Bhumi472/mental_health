import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'dart:ui'; // For ImageFilter

class GratitudeExchange extends StatefulWidget {
  const GratitudeExchange({super.key});

  @override
  State<GratitudeExchange> createState() => _GratitudeExchangeState();
}

class _GratitudeExchangeState extends State<GratitudeExchange> {
  final TextEditingController _textController = TextEditingController();
  final List<GratitudeEntry> _entries = [];
  late ConfettiController _confettiController;
  
  bool _hasSharedToday = false; 
  GratitudeEntry? _receivedGratitude;

  final List<String> _mockCommunityEntries = [
    "I'm grateful for my cat who always knows when I'm sad.",
    "Found a perfect parking spot today right in front.",
    "My mom called just to say hi.",
    "Finally finished that book I've been reading for months.",
    "The sun was shining during my lunch break.",
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadCommunityEntries();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _loadCommunityEntries() {
    final random = Random();
    for (int i = 0; i < 5; i++) {
       _entries.add(GratitudeEntry(
         text: _mockCommunityEntries[random.nextInt(_mockCommunityEntries.length)],
         type: GratitudeType.community,
         likes: random.nextInt(20),
       ));
    }
  }

  void _submitGratitude() {
    if (_textController.text.trim().isEmpty) return;
    if (_hasSharedToday) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You've already shared today. Come back tomorrow!")));
       return;
    }

    setState(() {
      _hasSharedToday = true;
      // Add user entry
      _entries.insert(0, GratitudeEntry(
        text: _textController.text,
        type: GratitudeType.mine,
        likes: 0,
      ));
      
      // Unlock "Received" gratitude
      final random = Random();
      _receivedGratitude = GratitudeEntry(
         text: _mockCommunityEntries[random.nextInt(_mockCommunityEntries.length)],
         type: GratitudeType.received,
         likes: 5,
      );
      
      _textController.clear();
    });

    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text('Gratitude Exchange'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF2D3748)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "324 Online", 
                style: GoogleFonts.inter(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header / Give Area
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_hasSharedToday) ...[
                      Text(
                        "Share to Receive ✨",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _textController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "I am grateful for...",
                          filled: true,
                          fillColor: const Color(0xFFFDF2F8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _submitGratitude,
                        icon: const Icon(Icons.volunteer_activism),
                        label: const Text("Share to Pool"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC4899),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ] else ...[
                      // Success / Today's view
                       Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEC4899)),
                        ),
                        child: Column(
                          children: [
                            const Text("🎉 Shared Today!", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEC4899))),
                             const SizedBox(height: 8),
                            Text("See you tomorrow.", style: GoogleFonts.inter(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // "For You" Section
              if (_hasSharedToday && _receivedGratitude != null)
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 20),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Text("For You 💌", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF831843))),
                        const SizedBox(height: 8),
                        _buildEntryCard(_receivedGratitude!),
                     ],
                   ),
                 )
              else
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 20),
                   child: ClipRect(
                     child: ImageFiltered(
                       imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                       child: Container(
                         height: 100,
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.5),
                           borderRadius: BorderRadius.circular(16),
                         ),
                         child: Center(
                           child: Text("Share to unlock your gift", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                         ),
                       ),
                     ),
                   ),
                 ),

              const SizedBox(height: 20),
              
              // Community Feed
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildEntryCard(_entries[index]),
                    );
                  },
                ),
              ),
            ],
          ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(GratitudeEntry entry) {
    Color cardColor;
    Color iconColor;
    String headerText;

    if (entry.type == GratitudeType.received) {
      cardColor = const Color(0xFFFCE7F3); // Pink light
      iconColor = const Color(0xFFEC4899);
      headerText = "Someone shared with you";
    } else if (entry.type == GratitudeType.mine) {
      cardColor = Colors.white;
      iconColor = Colors.grey;
      headerText = "You shared";
    } else {
      cardColor = Colors.white;
      iconColor = Colors.grey;
      headerText = "Anonymous";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
        border: entry.type == GratitudeType.received ? Border.all(color: const Color(0xFFEC4899), width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Icon(Icons.format_quote, size: 16, color: iconColor),
               const SizedBox(width: 8),
               Text(headerText, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700])),
               const Spacer(),
               Icon(Icons.favorite, size: 16, color: Colors.pink[300]),
               const SizedBox(width: 4),
               Text(entry.likes.toString(), style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(entry.text, style: GoogleFonts.literata(fontSize: 16, color: const Color(0xFF2D3748))),
        ],
      ),
    );
  }
}

enum GratitudeType { mine, received, community }

class GratitudeEntry {
  final String text;
  final GratitudeType type;
  final int likes;
  GratitudeEntry({required this.text, required this.type, required this.likes});
}
