import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_gate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.home_repair_service_rounded,
      iconBg: Color(0xFFE3F2FD),
      iconColor: Color(0xFF1565C0),
      title: 'Find Local Services',
      subtitle:
      'Discover trusted plumbers, electricians, doctors, and more in your area — all in one place.',
      bg: Color(0xFFF4F6FB),
    ),
    _OnboardingData(
      icon: Icons.calendar_today_rounded,
      iconBg: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
      title: 'Book in Seconds',
      subtitle:
      'Pick a date, choose a time slot, and confirm your booking instantly. No calls, no waiting.',
      bg: Color(0xFFF1F8F1),
    ),
    _OnboardingData(
      icon: Icons.star_rounded,
      iconBg: Color(0xFFFFF8E1),
      iconColor: Color(0xFFF9A825),
      title: 'Rate & Review',
      subtitle:
      'Share your experience to help others find the best service providers near them.',
      bg: Color(0xFFFFFBF0),
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const AuthGate(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pages[_currentPage].bg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    _currentPage == _pages.length - 1 ? '' : 'Skip',
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) =>
                    _buildPage(_pages[index]),
              ),
            ),

            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Column(
                children: [
                  _buildDots(),
                  const SizedBox(height: 32),
                  _buildButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon illustration
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: data.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 80, color: data.iconColor),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF888888),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1565C0)
                : const Color(0xFFCCCCCC),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildButton() {
    final isLast = _currentPage == _pages.length - 1;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          if (isLast) {
            _finishOnboarding();
          } else {
            _controller.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          isLast ? 'Get Started' : 'Next',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color bg;

  const _OnboardingData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.bg,
  });
}