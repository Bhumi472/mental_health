import 'dart:math';
import 'package:flutter/material.dart';
import 'model.dart';

class FlightPathWidget extends StatefulWidget {
  final FlightPath flightPath;
  final Size unitSize;
  final double pixelsPerUnit;
  final Widget child;
  final VoidCallback onOffScreen;

  const FlightPathWidget({
    super.key,
    required this.flightPath,
    required this.unitSize,
    required this.pixelsPerUnit,
    required this.child,
    required this.onOffScreen,
  });

  @override
  State<FlightPathWidget> createState() => _FlightPathWidgetState();
}

class _FlightPathWidgetState extends State<FlightPathWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    final zeros = widget.flightPath.zeroes;
    final time = max(zeros[0], zeros[1]);

    controller = AnimationController(
      vsync: this,
      upperBound: time + 1.0,
      duration: Duration(milliseconds: ((time + 1.0) * 1000).round()),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onOffScreen();
      }
    });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (context, child) {
        final pos =
            widget.flightPath.getPosition(controller.value) *
            widget.pixelsPerUnit;

        return Positioned(
          left: pos.dx - widget.unitSize.width * 0.5 * widget.pixelsPerUnit,
          bottom: pos.dy - widget.unitSize.height * 0.5 * widget.pixelsPerUnit,
          child: Transform.rotate(
            angle: widget.flightPath.getAngle(controller.value),
            child: child,
          ),
        );
      },
    );
  }
}
