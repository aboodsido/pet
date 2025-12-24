import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key, required this.onFinished});

  final Future<void> Function() onFinished;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      titleKey: 'onboarding_title_1',
      descriptionKey: 'onboarding_description_1',
      icon: Icons.savings_rounded,
      accent: AppTheme.primaryColor,
      badgeTextKey: 'onboarding_badge_finances',
    ),
    _OnboardingPage(
      titleKey: 'onboarding_title_2',
      descriptionKey: 'onboarding_description_2',
      icon: Icons.auto_awesome,
      accent: AppTheme.accentColor,
      badgeTextKey: 'onboarding_badge_ai',
    ),
    _OnboardingPage(
      titleKey: 'onboarding_title_3',
      descriptionKey: 'onboarding_description_3',
      icon: Icons.stacked_line_chart_rounded,
      accent: AppTheme.errorColor,
      badgeTextKey: 'onboarding_badge_control',
    ),
  ];

  int _currentIndex = 0;

  void _handlePageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _finish() async {
    await widget.onFinished();
  }

  Future<void> _next() async {
    if (_currentIndex == _pages.length - 1) {
      await _finish();
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).cardColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -60,
              child: _GradientBlob(
                color: _pages[_currentIndex].accent.withValues(alpha: 0.18),
                size: 260,
              ),
            ),
            Positioned(
              bottom: -140,
              left: -40,
              child: _GradientBlob(
                color: AppTheme.primaryColor.withValues(
                  alpha: isDark ? 0.22 : 0.15,
                ),
                size: 300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(
                        'skip'.tr(),
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _BrandHeader(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: _handlePageChanged,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        return _OnboardingCard(
                          page: page,
                          surface: surface,
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PageIndicator(
                    length: _pages.length,
                    activeIndex: _currentIndex,
                    color: _pages[_currentIndex].accent,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentIndex].accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _next,
                    child: Text(
                      _currentIndex == _pages.length - 1
                          ? 'get_started'.tr()
                          : 'next'.tr(),
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.page,
    required this.surface,
    required this.isDark,
  });

  final _OnboardingPage page;
  final Color surface;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.85 : 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: page.accent.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: page.accent.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: page.accent.withValues(alpha: isDark ? 0.16 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              page.badgeTextKey.tr(),
              style: textTheme.bodyMedium?.copyWith(
                color: page.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  page.accent.withValues(alpha: 0.14),
                  page.accent.withValues(alpha: 0.35),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isDark ? 0.07 : 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: page.accent.withValues(alpha: 0.25),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(
                  page.icon,
                  size: 48,
                  color:
                      isDark ? Colors.white : AppTheme.scaffoldBackgroundColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            page.titleKey.tr(),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.lightTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            page.descriptionKey.tr(),
            style: textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color:
                  isDark
                      ? AppTheme.secondaryTextColor
                      : AppTheme.lightSecondaryTextColor,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FeatureChip(
                icon: Icons.shield_rounded,
                label: 'onboarding_chip_security'.tr(),
              ),
              _FeatureChip(
                icon: Icons.notifications_active_outlined,
                label: 'onboarding_chip_reminders'.tr(),
              ),
              _FeatureChip(
                icon: Icons.analytics_outlined,
                label: 'onboarding_chip_insights'.tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark
                  ? AppTheme.secondaryTextColor
                  : AppTheme.lightSecondaryTextColor)
              .withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.length,
    required this.activeIndex,
    required this.color,
  });

  final int length;
  final int activeIndex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 10,
          width: isActive ? 28 : 10,
          decoration: BoxDecoration(
            color:
                isActive
                    ? color
                    : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  const _GradientBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 120,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.appName,
          style: textTheme.titleLarge?.copyWith(
            letterSpacing: -0.3,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'onboarding_tagline'.tr(),
          style: textTheme.bodyLarge?.copyWith(
            color:
                isDark
                    ? AppTheme.secondaryTextColor
                    : AppTheme.lightSecondaryTextColor,
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.accent,
    required this.badgeTextKey,
  });

  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color accent;
  final String badgeTextKey;
}
