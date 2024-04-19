import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class PageBaseLayout extends StatelessWidget {
  final Widget body;

  const PageBaseLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).mode.isDark
            ? Colors.black54
            : Colors.white,
      ),
      padding: const EdgeInsets.all(32.0),
      child: body,
    );
  }
}
