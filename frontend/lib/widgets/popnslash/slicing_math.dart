import 'dart:math';
import 'dart:ui';

List<Offset> rotatePointsAroundPosition(
  Offset s1,
  Offset s2,
  Offset position,
  double boxAngle,
) {
  final double s = sin(boxAngle);
  final double c = cos(boxAngle);

  final Offset local1 = s1 - position;
  final Offset local2 = s2 - position;

  final Offset new1 = Offset(
    local1.dx * c - local1.dy * s,
    local1.dx * s + local1.dy * c,
  );

  final Offset new2 = Offset(
    local2.dx * c - local2.dy * s,
    local2.dx * s + local2.dy * c,
  );

  return [new1 + position, new2 + position];
}

List<List<Offset>> getSlicePaths(
  Offset s1,
  Offset s2,
  Size boxSize,
  Offset boxPosition,
  double boxAngle,
) {
  final rotatedPoints = rotatePointsAroundPosition(
    s1,
    s2,
    boxPosition,
    boxAngle,
  );

  final Offset l1 = rotatedPoints[0];
  final Offset l2 = rotatedPoints[1];
  final Offset dir = l2 - l1;

  final Rect box = Rect.fromCenter(
    center: boxPosition,
    width: boxSize.width,
    height: boxSize.height,
  );

  final double bot = min(box.top, box.bottom);
  final double top = max(box.top, box.bottom);

  List<Offset> path1 = [];
  List<Offset> path2 = [];

  List<Offset> currentPath = path1;

  bool horizontal = false;

  for (final Offset corner in [
    Offset(box.left, bot),
    Offset(box.left, top),
    Offset(box.right, top),
    Offset(box.right, bot),
  ]) {
    currentPath.add(corner);

    final double t = horizontal
        ? (corner.dy - l1.dy) / dir.dy
        : (corner.dx - l1.dx) / dir.dx;

    if (t > 0 && t < 1.0) {
      Offset? cp; // ✅ nullable now

      if (horizontal) {
        final double xVal = l1.dx + dir.dx * t;
        if (xVal >= box.left && xVal < box.right) {
          cp = Offset(xVal, corner.dy);
        }
      } else {
        final double yVal = l1.dy + dir.dy * t;
        if (yVal >= bot && yVal < top) {
          cp = Offset(corner.dx, yVal);
        }
      }

      if (cp != null) {
        currentPath.add(cp);
        currentPath = currentPath == path1 ? path2 : path1;
        currentPath.add(cp);
      }
    }

    horizontal = !horizontal;
  }

  // Normalize coordinates (0 → 1 space)
  path1 = path1
      .map(
        (e) => Offset(
          (e.dx - box.left) / box.width,
          1.0 - (e.dy - bot) / box.height,
        ),
      )
      .toList();

  path2 = path2
      .map(
        (e) => Offset(
          (e.dx - box.left) / box.width,
          1.0 - (e.dy - bot) / box.height,
        ),
      )
      .toList();

  return (path1.length > 2 && path2.length > 2) ? [path1, path2] : [];
}
