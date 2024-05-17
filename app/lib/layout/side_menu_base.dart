import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';

class SideMenuBaseLayout extends StatelessWidget {
  final Widget body;

  const SideMenuBaseLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AdaptiveTheme.of(context).mode.isDark
                ? Colors.black
                : Colors.grey,
            blurRadius: 10.0,
          ),
        ],
        color: AdaptiveTheme.of(context).mode.isDark
            ? Colors.black
            : Colors.grey[200],
      ),
      padding: const EdgeInsets.all(32.0),
      child: body,
    );
  }
}
