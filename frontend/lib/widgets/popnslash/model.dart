import 'dart:math';
// import 'dart:ui';
import 'package:flutter/widgets.dart';

const Offset gravity = Offset(0, -9.8);
const double worldHeight = 16.0;

enum FruitType { apple, banana, mango, watermelon }

extension FruitTypeUtil on FruitType {
  Size get unitSize {
    switch (this) {
      case FruitType.apple:
        return const Size(2.04, 2.0);
      case FruitType.banana:
        return const Size(3.19, 2.0);
      case FruitType.mango:
        return const Size(3.16, 2.0);
      case FruitType.watermelon:
        return const Size(2.6, 2.0);
    }
  }

String get imageFile {
  switch (this) {
    case FruitType.apple:
      return "assets/pop_n_slash_images/apple.png";
    case FruitType.banana:
      return "assets/pop_n_slash_images/banana.png";
    case FruitType.mango:
      return "assets/pop_n_slash_images/mango.png";
    case FruitType.watermelon:
      return "assets/pop_n_slash_images/watermelon.png";
  }
}


  Widget getImageWidget(double pixelsPerUnit) {
    return Image.asset(
      imageFile,
      width: unitSize.width * pixelsPerUnit,
      height: unitSize.height * pixelsPerUnit,
    );
  }
}

class PieceOfFruit {
  final Key key = UniqueKey();
  final int createdMS;
  final FlightPath flightPath;
  final FruitType type;

  PieceOfFruit({
    required this.createdMS,
    required this.flightPath,
    required this.type,
  });
}

class SlicedFruit {
  final Key key = UniqueKey();
  final List<Offset> slice;
  final FlightPath flightPath;
  final FruitType type;

  SlicedFruit({
    required this.slice,
    required this.flightPath,
    required this.type,
  });
}

class Slice {
  final Key key = UniqueKey();
  final Offset begin;
  final Offset end;

  Slice(this.begin, this.end);
}

/// A parabolic flight path.
class FlightPath {
  final double angle;
  final double angularVelocity;
  final Offset position;
  final Offset velocity;

  const FlightPath({
    required this.angle,
    required this.angularVelocity,
    required this.position,
    required this.velocity,
  });

  Offset getPosition(double t) {
    return (gravity * 0.5) * t * t + velocity * t + position;
  }

  double getAngle(double t) {
    return angle + angularVelocity * t;
  }

  List<double> get zeroes {
    final double a = (gravity * 0.5).dy;
    final double sqrtTerm = sqrt(
      velocity.dy * velocity.dy - 4.0 * a * position.dy,
    );

    return [
      (-velocity.dy + sqrtTerm) / (2 * a),
      (-velocity.dy - sqrtTerm) / (2 * a),
    ];
  }
}
