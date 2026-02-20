import 'package:flutter/material.dart';
import 'pop_and_slash_game.dart';

class PopAndSlashPage extends StatelessWidget {
  const PopAndSlashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pop and Slash'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      // 🌿 Calm background
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F8FB), Color(0xFFEFF3F7)],
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎮 Game Image Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/PopandSlash.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 32),

              // 🏷️ Title
              const Text(
                'Pop and Slash',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // 🧠 Description
              const Text(
                'Tap the fruits as fast as you can.\n'
                'This game gently tracks your reaction time and focus patterns.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 40),

              // ▶ Start Game Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PopAndSlashGamePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Start Game',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ℹ️ Subtext
              const Text(
                'No scores are judged — only patterns are observed.',
                style: TextStyle(fontSize: 13, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
