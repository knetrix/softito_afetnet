import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RadarTargetWidget extends StatefulWidget {
  final double size;

  const RadarTargetWidget({
    super.key,
    this.size = 220,
  });

  @override
  State<RadarTargetWidget> createState() => _RadarTargetWidgetState();
}

class _RadarTargetWidgetState extends State<RadarTargetWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft background cyan ambient glow
                Container(
                  width: widget.size * 0.75,
                  height: widget.size * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryCyan.withValues(alpha: 0.18),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),

                // Radar rings and crosshairs painter
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RadarPainter(rotation: _rotationAnimation.value),
                ),

                // Center circular core with the broadcast tower
                Container(
                  width: widget.size * 0.38,
                  height: widget.size * 0.38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0C1624),
                    border: Border.all(
                      color: AppColors.primaryCyan.withValues(alpha: 0.7),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryCyan.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.cell_tower_rounded,
                      size: widget.size * 0.18,
                      color: AppColors.primaryCyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double rotation;

  _RadarPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // 1. Outer subtle circle
    final outerRingPaint = Paint()
      ..color = AppColors.primaryCyan.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, maxRadius * 0.88, outerRingPaint);

    // 2. Dashed / segmented intermediate circle
    final dashRingPaint = Paint()
      ..color = AppColors.primaryCyan.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const int dashCount = 36;
    final double dashAngle = (2 * math.pi) / dashCount;
    final double dashedRadius = maxRadius * 0.65;

    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        final startAngle = i * dashAngle + (rotation * 0.2);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: dashedRadius),
          startAngle,
          dashAngle * 0.6,
          false,
          dashRingPaint,
        );
      }
    }

    // 3. Crosshair tick marks (North, South, East, West)
    final tickPaint = Paint()
      ..color = AppColors.primaryCyan
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const double tickLength = 16.0;
    final double tickDistance = maxRadius * 0.88;

    // Top tick
    canvas.drawLine(
      Offset(center.dx, center.dy - tickDistance - (tickLength / 2)),
      Offset(center.dx, center.dy - tickDistance + (tickLength / 2)),
      tickPaint,
    );
    // Bottom tick
    canvas.drawLine(
      Offset(center.dx, center.dy + tickDistance - (tickLength / 2)),
      Offset(center.dx, center.dy + tickDistance + (tickLength / 2)),
      tickPaint,
    );
    // Left tick
    canvas.drawLine(
      Offset(center.dx - tickDistance - (tickLength / 2), center.dy),
      Offset(center.dx - tickDistance + (tickLength / 2), center.dy),
      tickPaint,
    );
    // Right tick
    canvas.drawLine(
      Offset(center.dx + tickDistance - (tickLength / 2), center.dy),
      Offset(center.dx + tickDistance + (tickLength / 2), center.dy),
      tickPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
