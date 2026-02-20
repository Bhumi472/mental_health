import 'package:flutter/material.dart';
import '../../../widgets/popnslash/model.dart';
// import '../../../widgets/popnslash/gravity_widget.dart';
import '../../../widgets/popnslash/game_widget.dart';

class PopAndSlashGamePage extends StatelessWidget {
  const PopAndSlashGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final Size screenSize = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );

          final Size worldSize = Size(
            worldHeight * screenSize.aspectRatio,
            worldHeight,
          );

          return Stack(
            children: [
              // 🌌 Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E1E2C), Color(0xFF0F0F18)],
                  ),
                ),
              ),

              // 🎮 Game Engine
              FruitNinja(screenSize: screenSize, worldSize: worldSize),

              // 🔙 Back button overlay
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
