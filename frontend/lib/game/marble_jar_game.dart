import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import '../models/mood_model.dart';


class MarbleJarGame extends Forge2DGame {
  final List<Mood> initialMarbles;
  final Function(Mood) onMarbleAdded;
  
  // Game constants
  static const double scale = 10.0;
  // Screen size approx 300x340 -> World size approx 30x34
  
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  
  // Lid removed
  late JarBody _jarBody;

  MarbleJarGame({
    required this.initialMarbles,
    required this.onMarbleAdded,
  }) : super(zoom: scale, gravity: Vector2(0, 30));

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    // Set background color to transparent to let UI show through if needed
    // But we probably want a glass effect. We'll draw the jar static body.
    
    // 1. Add Jar Boundaries
    _jarBody = JarBody(size: screenToWorld(camera.viewport.virtualSize));
    await world.add(_jarBody);

    // Lid removed

    // 3. Add Initial Marbles
    // Add them with some delay or spacing to prevent explosion
    for (var i = 0; i < initialMarbles.length; i++) {
        // Randomize x slightly
        // Randomize x slightly but keep centered
        final xPos = (i % 3 - 1) * 1.0; // Range -1 to 1, very safe
        final yPos = -5.0 - (i * 3.0); // Start higher up to drop in
        await addMarble(initialMarbles[i], position: Vector2(xPos, yPos));
    }

    // 4. Setup Sensors
    _sensorSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      // standard gravity is ~9.8.
      // x is left/right tilt. y is forward/back. z is screen up/down.
      // In portrait:
      // Holding straight: x=0, y=9.8.
      // Tilted right: x=-9.8.
      // We want to map sensor x to world x gravity.
      
      // Update gravity
      // Amplify x slightly for better effect
      final newGravity = Vector2(-event.x * 2, event.y * 2); 
      // Clamp to reasonable values
      // world.gravity = newGravity; // Dynamic gravity is dangerous if not smoothed, but let's try direct mapping first
      world.gravity = newGravity;
    });
  }

  @override
  void onRemove() {
    _sensorSubscription?.cancel();
    super.onRemove();
  }

  Future<void> addMarble(Mood mood, {Vector2? position}) async {
    // Create marble body
    final marble = MarbleBody(
      mood: mood,
      initialPosition: position ?? Vector2(0, -22), // Well above jar (-15) and lid (-15.5)
    );
    await world.add(marble);
  }

  Future<void> openLid() async {
    // No-op
  }

  Future<void> closeLid() async {
    // No-op
  }

  Future<void> clear() async {
    final marbles = world.children.whereType<MarbleBody>();
    for (final m in marbles) {
      m.removeFromParent();
    }
  }
}

class JarBody extends BodyComponent {
  final Vector2 size;
  late final List<Vector2> _vertices;
  
  JarBody({required this.size}) {
    // Define jar outline in world coordinates
    // Half width/height

    final hh = 15.0; 
    final neckW = 9.0; // Wider neck to catch marbles easier

    // Refine vertices to look more like the reference image (curved jar)
    // Using more points for a smoother curve
    _vertices = [
      Vector2(-neckW, -hh), // Top left neck
      Vector2(-neckW, -12), 
      Vector2(-10, -11),
      Vector2(-12, -10),
      Vector2(-13.5, -8),
      Vector2(-14.5, -4),
      Vector2(-15, 0), // Widest point
      Vector2(-14.8, 4),
      Vector2(-14.2, 8),
      Vector2(-13, 11),
      Vector2(-11, 13),
      Vector2(-8, 14.5),
      Vector2(0, 15), // Bottom center
      Vector2(8, 14.5),
      Vector2(11, 13),
      Vector2(13, 11),
      Vector2(14.2, 8),
      Vector2(14.8, 4),
      Vector2(15, 0),
      Vector2(14.5, -4),
      Vector2(13.5, -8),
      Vector2(12, -10),
      Vector2(10, -11),
      Vector2(neckW, -12),
      Vector2(neckW, -hh), // Top right neck
    ];
  }

  @override
  Body createBody() {
    final shape = ChainShape();
    shape.createChain(_vertices);
    
    final bodyDef = BodyDef(
      position: Vector2(0, 0),
      type: BodyType.static,
    );
    
    return world.createBody(bodyDef)..createFixture(FixtureDef(shape, friction: 0.3));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.white.withAlpha(100);
      
    final path = Path();
    if (_vertices.isNotEmpty) {
      path.moveTo(_vertices[0].x, _vertices[0].y);
      for (int i = 1; i < _vertices.length; i++) {
        // Simple lines for now, or use quadratic if we stored control points
        // But vertices are just points for ChainShape.
        // We can smooth it visually in render if we want, but physics is polygonal.
        // Let's stick to lines to match physics exactly.
        path.lineTo(_vertices[i].x, _vertices[i].y);
      }
      path.close();
    }
    
    canvas.drawPath(path, paint);
    
    // Add glass fill & highlights
    final glassPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue.withAlpha(20);
    canvas.drawPath(path, glassPaint);

    // Reflection removed
  }
}

class MarbleBody extends BodyComponent {
  final Mood mood;
  final Vector2 initialPosition;

  MarbleBody({required this.mood, required this.initialPosition});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Add sprite
    final sprite = await Sprite.load(mood.imagePath.replaceFirst('assets/images/', '')); // Flame assets are in assets/images by default? No, assets/images/
    // Flame assumes assets/images for 'images' prefix.
    // Our path is 'assets/images/filename.png'.
    // Sprite.load takes a filename relative to assets/images.
    // So we need to strip 'assets/images/'.
    
    add(SpriteComponent(
      sprite: sprite,
      size: Vector2(2.8, 2.8), // Approx 28px
      anchor: Anchor.center,
    ));
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 1.4; // 14px radius
    
    final bodyDef = BodyDef(
      position: initialPosition,
      type: BodyType.dynamic,
    );

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.2,
      friction: 0.5,
      density: 1.0,
    );
    
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

// LidBody class removed as per user request to have an open jar.

