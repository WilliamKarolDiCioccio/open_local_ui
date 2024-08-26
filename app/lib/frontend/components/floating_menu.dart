import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FloatingMenuComponent extends StatelessWidget {
  final GlobalKey buttonKey;
  final List<Widget> actions;
  final int upPosition;
  final int downPosition;

  FloatingMenuComponent({
    required this.buttonKey,
    required this.actions,
    this.upPosition = 300,
    this.downPosition = 30,
  });

  Offset _getButtonOffset() {
    final RenderBox renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox;

    return renderBox.localToGlobal(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final buttonOffeset = _getButtonOffset();

    return Positioned(
      top: MediaQuery.of(context).size.height - buttonOffeset.dy >= upPosition
          ? buttonOffeset.dy + downPosition
          : buttonOffeset.dy - upPosition,
      left: buttonOffeset.dx,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AdaptiveTheme.of(context).mode.isDark
                  ? Colors.black
                  : Colors.grey,
              blurRadius: 10.0,
              offset: const Offset(2, 4),
            ),
          ],
          color: AdaptiveTheme.of(context).theme.canvasColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: actions,
          ),
        ),
      ).animate().fadeIn(
            duration: 200.ms,
          ),
    );
  }
}
