import 'package:flutter/material.dart';
import 'memory_lane_game.dart';

class MemoryLanePage extends StatelessWidget {
  const MemoryLanePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Lane'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          /// 🌿 Soft gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF7FAFC), Color(0xFFEFF3F7)],
              ),
            ),
          ),

          /// 🎮 Content
          Column(
            children: [
              const Spacer(),

              /// 🖼 Game Image
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/MemoryLane.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              /// 🧠 Title
              const Text(
                'Memory Lane',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              /// 📖 Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Watch the sequence carefully and repeat it.\n'
                  'This game observes your recall patterns and decision timing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),

              const Spacer(),

              /// ▶ Start Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: const Color(0xFFEAE6F2),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MemoryLaneGame()),
                    );
                  },
                  child: const Text(
                    'Start Game',
                    style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'No scores are judged — only patterns are observed.',
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
