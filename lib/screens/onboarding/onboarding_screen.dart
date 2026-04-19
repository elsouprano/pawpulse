import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.pets,
      'color': const Color(0xFFFF8C42),
      'headline': "Meet PawPulse",
      'subheadline': "Your pet's health, all in one place.",
    },
    {
      'icon': Icons.document_scanner_outlined,
      'color': const Color(0xFF06D6A0),
      'headline': "AI Health Scanning",
      'subheadline': "Detect health issues before they become problems.",
    },
    {
      'icon': Icons.calendar_month_outlined,
      'color': const Color(0xFFFFD166),
      'headline': "Never Miss a Visit",
      'subheadline': "Smart reminders for every appointment.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkOnboardingState();
  }

  Future<void> _checkOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isDone = prefs.getBool('onboarding_done') ?? false;
    if (isDone && mounted) {
      context.go('/login');
    }
  }

  Future<void> _completeOnboarding(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      context.go(route);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: const Color(0xFF1A1200)),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [const Color(0xFFFF8C42).withOpacity(0.08), Colors.transparent],
              center: Alignment.center,
              radius: 1.5,
            ),
          ),
        ),
        Positioned(top: -50, left: -100, child: _Circle(size: 300, color: const Color(0xFFFF8C42).withOpacity(0.06))),
        Positioned(bottom: -50, right: -100, child: _Circle(size: 350, color: const Color(0xFFFF8C42).withOpacity(0.06))),
        Positioned(top: 200, right: -50, child: _Circle(size: 200, color: const Color(0xFFFF8C42).withOpacity(0.06))),
        Positioned(bottom: 150, left: -50, child: _Circle(size: 150, color: const Color(0xFFFFD166).withOpacity(0.04))),
        Positioned(top: 100, left: 150, child: _Circle(size: 100, color: const Color(0xFFFFD166).withOpacity(0.04))),
      ],
    );
  }

  Widget _buildFloatingCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFF8C42).withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C42).withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(28),
            color: const Color(0xFF3D2C00).withOpacity(0.92),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      final Color pageColor = page['color'];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [pageColor.withOpacity(0.2), Colors.transparent],
                                stops: const [0.3, 1.0],
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: pageColor.withOpacity(0.3), width: 2),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: pageColor.withOpacity(0.15),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      page['icon'] as IconData,
                                      size: 52,
                                      color: pageColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            page['headline'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              page['subheadline'] as String,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: _buildFloatingCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                height: 8,
                                width: _currentPage == index ? 24 : 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? const Color(0xFFFF8C42)
                                      : AppTheme.textSecondary.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (_currentPage < 2) ...[
                            GradientButton(
                              label: "Next",
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => _completeOnboarding('/login'),
                              child: Text(
                                "Skip",
                                style: GoogleFonts.nunito(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ] else ...[
                            GradientButton(
                              label: "Get Started",
                              onPressed: () => _completeOnboarding('/register'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account?",
                                  style: GoogleFonts.nunito(
                                      fontSize: 14, color: AppTheme.textSecondary),
                                ),
                                TextButton(
                                  onPressed: () => _completeOnboarding('/login'),
                                  child: Text(
                                    "Sign In",
                                    style: GoogleFonts.nunito(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_currentPage < 2)
            Positioned(
              top: 12 + MediaQuery.of(context).padding.top,
              right: 16,
              child: TextButton(
                onPressed: () => _completeOnboarding('/login'),
                child: Text(
                  "Skip",
                  style: GoogleFonts.nunito(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;

  const _Circle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
