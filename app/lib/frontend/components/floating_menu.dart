import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FloatingMenuComponent extends StatefulWidget {
  final GlobalKey buttonKey;
  final List<Widget> actions;
  final int upPosition;
  final int downPosition;

  const FloatingMenuComponent({
    super.key,
    required this.buttonKey,
    required this.actions,
    this.upPosition = 300,
    this.downPosition = 30,
  });

  @override
  _FloatingMenuComponentState createState() => _FloatingMenuComponentState();
}

class _FloatingMenuComponentState extends State<FloatingMenuComponent> {
  Offset? buttonOffset;
  double? topPosition;
  double? leftPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateButtonOffset();
    });
  }

  Offset _getButtonOffset() {
    final RenderBox renderBox =
        widget.buttonKey.currentContext?.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(Offset.zero);
  }

  void _updateButtonOffset() {
    final Offset offset = _getButtonOffset();
    setState(() {
      buttonOffset = offset;
      _calculatePosition();
    });
  }

  void _calculatePosition() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust positioning based on buttonOffset
    double newTopPosition =
        (screenHeight - buttonOffset!.dy >= widget.upPosition)
            ? buttonOffset!.dy + widget.downPosition
            : buttonOffset!.dy - widget.upPosition;

    double newLeftPosition = buttonOffset!.dx;

    // Adjust the position if the menu goes off-screen horizontally
    if (buttonOffset!.dx + 200 > screenWidth) {
      newLeftPosition = screenWidth - 200 - 16; // Adjust with padding
    } else if (buttonOffset!.dx < 16) {
      newLeftPosition = 16; // Adjust with padding
    }

    setState(() {
      topPosition = newTopPosition;
      leftPosition = newLeftPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (buttonOffset == null) {
      return Container();
    }

    return VisibilityDetector(
      key: Key('floating-menu-visibility-detector'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          // If the menu is not visible, reposition it
          _updateButtonOffset();
        }
      },
      child: Positioned(
        top: topPosition,
        left: leftPosition,
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
              children: widget.actions,
            ),
          ),
        ).animate().fadeIn(
              duration: 200.ms,
            ),
      ),
    );
  }
}
