import 'package:flutter/material.dart';

class SliceWidget extends StatefulWidget {
  final Offset sliceBegin;
  final Offset sliceEnd;
  final VoidCallback sliceFinished;

  const SliceWidget({
    super.key,
    required this.sliceBegin,
    required this.sliceEnd,
    required this.sliceFinished,
  });

  @override
  State<SliceWidget> createState() => _SliceWidgetState();
}

class _SliceWidgetState extends State<SliceWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.sliceFinished();
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
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final Offset sliceDirection = widget.sliceEnd - widget.sliceBegin;

          return CustomPaint(
            painter: SlicePainter(
              begin: widget.sliceBegin,
              end: widget.sliceBegin + sliceDirection * controller.value,
            ),
          );
        },
      ),
    );
  }
}

class SlicePainter extends CustomPainter {
  final Offset begin;
  final Offset end;

  const SlicePainter({required this.begin, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(begin, end, paint);
  }

  @override
  bool shouldRepaint(covariant SlicePainter oldDelegate) {
    return true;
  }
}
