import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/bottom_navigation_row.dart'; // Alt buton ve sayfa göstergesi bileşenidir
import '../widgets/onboarding_page_content.dart'; // Sayfa içeriklerini çizen bileşendir

// StatefulWidget: Ekrandaki verisi ve görünümü kullanıcı etkileşimiyle değişebilen widget'tır
class SplashOnboardingScreen extends StatefulWidget {
  final VoidCallback? onCompleted; // VoidCallback: Parametre almayan ve değer döndürmeyen fonksiyon tipidir

  const SplashOnboardingScreen({super.key, this.onCompleted});

  @override
  State<SplashOnboardingScreen> createState() => _SplashOnboardingScreenState();
}

class _SplashOnboardingScreenState extends State<SplashOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 2; // T6: 2 sayfa, 2 nokta

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    } else if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [
                  OnboardingPageContent(pageIndex: 0), // 1. Sayfa (Sivil kullanıcı içeriği)
                  OnboardingPageContent(pageIndex: 1), // 2. Sayfa (Saha yönetimi içeriği)
                ],
              ),
            ),
            BottomNavigationRow(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onActionPressed: _onNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final l10n = AppLocalizations.of(context);
    final skipLabel = l10n?.onboardingSkip ?? 'Atla';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage > 0)
              IconButton(
                onPressed: _onPrevious,
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF131A26),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary, size: 22),
                ),
              )
            else
              const SizedBox(width: 48),
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                skipLabel,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
