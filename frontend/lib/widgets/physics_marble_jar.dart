import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../models/mood_model.dart';
import '../constants/home_theme.dart';
import '../game/marble_jar_game.dart';

class PhysicsMarbleJar extends StatefulWidget {
  final List<Mood> marbles; // Changed from MarbleData to Mood for simplicity in game
  final Function(Mood) onMarbleAdded;
  final VoidCallback onClearJar;
  final VoidCallback? onReport;

  const PhysicsMarbleJar({
    super.key,
    required this.marbles,
    required this.onMarbleAdded,
    required this.onClearJar,
    this.onReport,
  });

  @override
  State<PhysicsMarbleJar> createState() => _PhysicsMarbleJarState();
}

class _PhysicsMarbleJarState extends State<PhysicsMarbleJar> {
  MarbleJarGame? _game;

  @override
  void initState() {
    super.initState();
    _game = MarbleJarGame(
      initialMarbles: widget.marbles,
      onMarbleAdded: widget.onMarbleAdded,
    );
  }

  @override
  void didUpdateWidget(PhysicsMarbleJar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.marbles.isEmpty && oldWidget.marbles.isNotEmpty) {
      _game?.clear();
    }
  }

  void _handleAddMarble(Mood mood) {
    if (_game == null) return;
    
    // Add marble immediately since lid is gone
    _game!.addMarble(mood);
      
    // Notify parent to update data model
    widget.onMarbleAdded(mood);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildJarHeader(),
        const SizedBox(height: 16),
        
        // Game Widget
        SizedBox(
          height: 340,
          width: 300,
          child: ClipRect(
            child: _game == null 
               ? const Center(child: CircularProgressIndicator()) 
               : GameWidget(game: _game!),
          ),
        ),

        const SizedBox(height: 16),
        _buildMoodSelector(),
      ],
    );
  }

  Widget _buildJarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Your Mood Jar",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: HomeColors.textPrimary,
          ),
        ),
        Row(
          children: [
            IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: widget.onReport),
            IconButton(
                icon: const Icon(Icons.delete_outline), onPressed: widget.onClearJar),
          ],
        )
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How are you feeling today?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: HomeColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: Mood.all.map((mood) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: () => _handleAddMarble(mood),
                child: Tooltip(
                  message: mood.label,
                  child: Container(
                    padding: const EdgeInsets.all(2), // tiny border/padding
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // color: Colors.grey.withAlpha(20),
                    ),
                    child: Image.asset(
                      mood.imagePath,
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
