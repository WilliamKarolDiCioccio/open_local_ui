import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_local_ui/frontend/screens/dashboard.dart';
import 'package:open_local_ui/frontend/screens/onboarding.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  final bool userOnboarded;

  const SplashScreen({super.key, required this.userOnboarded});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: SvgPicture.asset(
        'assets/graphics/logos/open_local_ui.svg',
        width: 512,
        // ignore: deprecated_member_use
        color:
            AdaptiveTheme.of(context).mode.isDark ? Colors.white : Colors.black,
      ),
      nextScreen:
          userOnboarded ? const DashboardScreen() : const OnboardingScreen(),
      backgroundColor: AdaptiveTheme.of(context).theme.primaryColor,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.theme,
      duration: 1500,
    );
  }
}
