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
      'color': const Color(0xFF6C63FF),
      'headline': "Meet PawPulse",
      'subheadline': "Your pet's health, smarter.",
    },
    {
      'icon': Icons.monitor_heart_outlined,
      'color': const Color(0xFF00D4AA),
      'headline': "AI Health Scanning",
      'subheadline': "Detect health issues before they become problems.",
    },
    {
      'icon': Icons.calendar_month_outlined,
      'color': const Color(0xFF6C63FF),
      'headline': "Never Miss a Visit",
      'subheadline': "Smart reminders for appointments and vaccinations.",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              (page['color'] as Color).withOpacity(0.15),
                              Colors.transparent,
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            page['icon'] as IconData,
                            size: 72,
                            color: page['color'] as Color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        page['headline'] as String,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page['subheadline'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
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
                            ? AppTheme.primary
                            : const Color(0xFF94A3B8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_currentPage < 2) ...[
                  GradientButton(
                    label: "Next",
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () => _completeOnboarding('/login'),
                    child: const Text("Skip", style: TextStyle(color: Color(0xFF94A3B8))),
                  ),
                ] else ...[
                  GradientButton(
                    label: "Get Started",
                    onPressed: () => _completeOnboarding('/register'),
                  ),
                  TextButton(
                    onPressed: () => _completeOnboarding('/login'),
                    child: const Text("Sign In", style: TextStyle(color: Color(0xFF94A3B8))),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
