import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:open_local_ui/core/logger.dart';

class FloatingMenuComponent extends StatefulWidget {
  final GlobalKey buttonKey;
  final List<Widget> actions;

  const FloatingMenuComponent({
    super.key,
    required this.buttonKey,
    required this.actions,
  });

  @override
  State<FloatingMenuComponent> createState() => _FloatingMenuComponentState();
}

class _FloatingMenuComponentState extends State<FloatingMenuComponent> {
  final GlobalKey _menuKey = GlobalKey();
  Offset _buttonOffset = Offset.zero;
  Size _menuSize = Size.zero;

  Offset _getButtonOffset() {
    final RenderBox renderBox =
        widget.buttonKey.currentContext?.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(Offset.zero);
  }

  Size _getMenuSize() {
    final RenderBox? renderBox =
        _menuKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size ?? Size.zero;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _buttonOffset = _getButtonOffset();
        _menuSize = _getMenuSize();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const double margin = 16.0; // Constant margin between button and menu

    // Determine available space on all sides of the button
    final double availableSpaceAbove = _buttonOffset.dy;
    final double availableSpaceBelow = screenSize.height - _buttonOffset.dy;
    final double availableSpaceLeft = _buttonOffset.dx;
    final double availableSpaceRight = screenSize.width - _buttonOffset.dx;

    // Variables to hold the final positions
    double? topPosition;
    double? leftPosition;

    // Determine the best position based on available space
    if (availableSpaceBelow >= _menuSize.height + margin) {
      // Place below if there is enough space
      topPosition = _buttonOffset.dy + margin;
      leftPosition = _buttonOffset.dx;
    } else if (availableSpaceAbove >= _menuSize.height + margin) {
      // Place above if there is enough space
      topPosition = _buttonOffset.dy - _menuSize.height - margin;
      leftPosition = _buttonOffset.dx;
    } else if (availableSpaceLeft >= _menuSize.width + margin) {
      // Place on the left if there is enough space
      topPosition = _buttonOffset.dy;
      leftPosition = _buttonOffset.dx - _menuSize.width - margin;
    } else if (availableSpaceRight >= _menuSize.width + margin) {
      // Place on the right if there is enough space
      topPosition = _buttonOffset.dy;
      leftPosition = _buttonOffset.dx + margin;
    } else {
      // No space available, log an error and avoid rendering the menu
      logger.e("No sufficient space to display the floating menu.");
      return Container(); // Optionally, you can return nothing or an empty widget
    }

    // Prevent horizontal overflow
    if (leftPosition + _menuSize.width > screenSize.width) {
      leftPosition = screenSize.width - _menuSize.width - margin;
    } else if (leftPosition < 0) {
      leftPosition = margin;
    }

    // Prevent vertical overflow
    if (topPosition + _menuSize.height > screenSize.height) {
      topPosition = screenSize.height - _menuSize.height - margin;
    } else if (topPosition < 0) {
      topPosition = margin;
    }

    MediaQuery.of(context);

    return Positioned(
      top: topPosition,
      left: leftPosition,
      child: Container(
        key: _menuKey,
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
            children: widget.actions,
          ),
        ),
      ).animate().fadeIn(
            duration: 200.ms,
          ),
    );
  }
}
