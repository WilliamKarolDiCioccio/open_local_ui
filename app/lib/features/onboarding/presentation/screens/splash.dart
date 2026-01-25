import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_local_ui/features/onboarding/presentation/screens/onboarding.dart';
import 'package:open_local_ui/features/dashboard/presentation/screens/dashboard.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  final bool userOnboarded;

  const SplashScreen({super.key, required this.userOnboarded});

  @override
  Widget build(BuildContext context) {
    final nextScreen = userOnboarded
        ? const DashboardScreen()
        : const OnboardingScreen();

    return AnimatedSplashScreen(
      splash: SvgPicture.asset(
        'assets/graphics/logos/open_local_ui.svg',
        width: 512,
        // ignore: deprecated_member_use
        color: Colors.white,
      ),
      nextScreen: nextScreen,
      backgroundColor: AdaptiveTheme.of(context).theme.primaryColor,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.theme,
      duration: 750,
      animationDuration: const Duration(seconds: 1),
    );
  }
}
