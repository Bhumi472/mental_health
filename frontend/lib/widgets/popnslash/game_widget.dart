import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'slicing_math.dart';
import 'gravity_widget.dart';
import 'model.dart';
import 'slice_widget.dart';

class FruitNinja extends StatefulWidget {
  final Size screenSize;
  final Size worldSize;

  const FruitNinja({
    super.key,
    required this.screenSize,
    required this.worldSize,
  });

  @override
  State<FruitNinja> createState() => FruitNinjaState();
}

class FruitNinjaState extends State<FruitNinja> {
  final Random r = Random();

  late Timer periodicFruitLauncher;

  final List<PieceOfFruit> fruit = [];
  final List<SlicedFruit> slicedFruit = [];
  final List<Slice> slices = [];

  late int sliceBeginMoment;
  late Offset sliceBeginPosition;
  late Offset sliceEnd;

  int sliced = 0;
  int notSliced = 0;

  @override
  void initState() {
    super.initState();

    periodicFruitLauncher = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        fruit.add(
          PieceOfFruit(
            createdMS: DateTime.now().millisecondsSinceEpoch,
            flightPath: FlightPath(
              angle: 1.0,
              angularVelocity: .3 + r.nextDouble() * 3.0,
              position: Offset(
                2.0 + r.nextDouble() * (widget.worldSize.width - 4.0),
                1.0,
              ),
              velocity: Offset(
                -1.0 + r.nextDouble() * 2.0,
                7.0 + r.nextDouble() * 7.0,
              ),
            ),
            type: FruitType.values[r.nextInt(FruitType.values.length)],
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    periodicFruitLauncher.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double ppu = widget.screenSize.height / widget.worldSize.height;

    List<Widget> stackItems = [];

    // Whole Fruits
    for (PieceOfFruit f in fruit) {
      stackItems.add(
        FlightPathWidget(
          key: f.key,
          flightPath: f.flightPath,
          unitSize: f.type.unitSize,
          pixelsPerUnit: ppu,
          child: f.type.getImageWidget(ppu),
          onOffScreen: () {
            setState(() {
              fruit.remove(f);
              notSliced++;
            });
          },
        ),
      );
    }

    // Slice lines
    for (Slice slice in slices) {
      Offset b = Offset(
        slice.begin.dx * ppu,
        (widget.worldSize.height - slice.begin.dy) * ppu,
      );

      Offset e = Offset(
        slice.end.dx * ppu,
        (widget.worldSize.height - slice.end.dy) * ppu,
      );

      stackItems.add(
        Positioned.fill(
          child: SliceWidget(
            sliceBegin: b,
            sliceEnd: e,
            sliceFinished: () {
              setState(() {
                slices.remove(slice);
              });
            },
          ),
        ),
      );
    }

    // Sliced Fruits
    for (SlicedFruit sf in slicedFruit) {
      stackItems.add(
        FlightPathWidget(
          key: sf.key,
          flightPath: sf.flightPath,
          unitSize: sf.type.unitSize,
          pixelsPerUnit: ppu,
          child: ClipPath(
            clipper: FruitSlicePath(sf.slice),
            child: sf.type.getImageWidget(ppu),
          ),
          onOffScreen: () {
            setState(() {
              slicedFruit.remove(sf);
            });
          },
        ),
      );
    }

    // Score UI
    stackItems.add(
      Positioned.fill(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ScoreBox(label: "Sliced", value: sliced),
                _ScoreBox(label: "Missed", value: notSliced),
              ],
            ),
          ),
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Stack(children: stackItems),
      onPanDown: (details) {
        sliceBeginMoment = DateTime.now().millisecondsSinceEpoch;
        sliceBeginPosition = details.localPosition;
        sliceEnd = details.localPosition;
      },
      onPanUpdate: (details) {
        sliceEnd = details.localPosition;
      },
      onPanEnd: (_) {
        _handleSlice(ppu);
      },
    );
  }

  void _handleSlice(double ppu) {
    int nowMS = DateTime.now().millisecondsSinceEpoch;

    if (nowMS - sliceBeginMoment < 1250 &&
        (sliceEnd - sliceBeginPosition).distanceSquared > 25.0) {
      setState(() {
        Offset worldSliceBegin = Offset(
          sliceBeginPosition.dx / ppu,
          (widget.screenSize.height - sliceBeginPosition.dy) / ppu,
        );

        Offset worldSliceEnd = Offset(
          sliceEnd.dx / ppu,
          (widget.screenSize.height - sliceEnd.dy) / ppu,
        );

        slices.add(Slice(worldSliceBegin, worldSliceEnd));

        Offset direction = worldSliceEnd - worldSliceBegin;
        worldSliceBegin -= direction;
        worldSliceEnd += direction;

        List<PieceOfFruit> toRemove = [];

        for (PieceOfFruit f in fruit) {
          double elapsedSeconds = (nowMS - f.createdMS) / 1000.0;

          Offset currPos = f.flightPath.getPosition(elapsedSeconds);
          double currAngle = f.flightPath.getAngle(elapsedSeconds);

          List<List<Offset>> sliceParts = getSlicePaths(
            worldSliceBegin,
            worldSliceEnd,
            f.type.unitSize,
            currPos,
            currAngle,
          );

          if (sliceParts.isNotEmpty) {
            toRemove.add(f);

            for (var part in sliceParts) {
              slicedFruit.add(
                SlicedFruit(
                  slice: part,
                  flightPath: FlightPath(
                    angle: currAngle,
                    angularVelocity:
                        f.flightPath.angularVelocity -
                        .25 +
                        r.nextDouble() * .5,
                    position: currPos,
                    velocity: Offset(r.nextBool() ? -1.0 : 1.0, 2.0),
                  ),
                  type: f.type,
                ),
              );
            }
          }
        }

        sliced += toRemove.length;
        fruit.removeWhere((e) => toRemove.contains(e));
      });
    }
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "$value",
          style: const TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// ✅ Missing class — needed for slicing
class FruitSlicePath extends CustomClipper<Path> {
  final List<Offset> normalizedPoints;

  FruitSlicePath(this.normalizedPoints);

  @override
  Path getClip(Size size) {
    Path p = Path()
      ..moveTo(
        normalizedPoints[0].dx * size.width,
        normalizedPoints[0].dy * size.height,
      );

    for (Offset o in normalizedPoints.skip(1)) {
      p.lineTo(o.dx * size.width, o.dy * size.height);
    }

    return p..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
