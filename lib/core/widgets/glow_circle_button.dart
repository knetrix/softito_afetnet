// Parlayan yuvarlak buton (panik ve düdük).

import 'package:flutter/material.dart';

import '../theme/app_status_colors.dart';

/// Parlayan dairesel buton (§3.4, A1 Panik, A3 Düdük)
class GlowCircleButton extends StatefulWidget {
  const GlowCircleButton({
    super.key,
    required this.onTap,
    this.onLongPress,
    required this.icon,
    this.label,
    this.color,
    this.size = 140.0,
    this.isPulsing = true,
  });

  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final IconData icon;
  final String? label;
  /// Verilmezse temadaki kritik renk (`AppStatusColors.critical`) kullanılır.
  final Color? color;
  final double size;
  final bool isPulsing;

  @override
  State<GlowCircleButton> createState() => _GlowCircleButtonState();
}

class _GlowCircleButtonState extends State<GlowCircleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _glowAnimation = Tween<double>(begin: 4.0, end: 24.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GlowCircleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing != oldWidget.isPulsing) {
      if (widget.isPulsing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.color ?? Theme.of(context).extension<AppStatusColors>()!.critical;
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: widget.isPulsing ? _glowAnimation.value : 10,
                  spreadRadius: widget.isPulsing ? _glowAnimation.value * 0.3 : 2,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: widget.size * 0.38,
                    color: Colors.white,
                  ),
                  if (widget.label != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.label!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

