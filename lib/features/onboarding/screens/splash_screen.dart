import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../widgets/radar_target_widget.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onInitializationComplete;

  const SplashScreen({
    super.key,
    this.onInitializationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  String _statusText = 'AfetNet protokolü hazır.';

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progressAnimation = Tween<double>(begin: 0.15, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _progressController.forward().then((_) {
      if (mounted && widget.onInitializationComplete != null) {
        widget.onInitializationComplete!();
      }
    });

    // Optional status transition to feel alive yet clean
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _statusText = 'AfetNet protokolü hazır.';
        });
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.2),
            radius: 1.1,
            colors: [
              Color(0xFF101926), // Center subtle dark blue highlight
              Color(0xFF090D14), // Base deep dark slate
              Color(0xFF05070B), // Outer dark edge
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Center Radar Graphic
                const RadarTargetWidget(size: 200),

                const SizedBox(height: 36),

                // Title
                const Text(
                  'AfetNet',
                  style: AppTextStyles.displayTitle,
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Canlı Kriz Yönetimi Ağı',
                  style: AppTextStyles.subtitle,
                ),

                const Spacer(flex: 2),

                // Circular Progress Spinner
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryCyan.withValues(alpha: 0.9),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Status Message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _statusText,
                    key: ValueKey<String>(_statusText),
                    style: AppTextStyles.statusText,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 18),

                // Progress Bar
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 140,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 140 * _progressAnimation.value,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryCyan.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
