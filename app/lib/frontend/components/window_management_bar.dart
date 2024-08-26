import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';

class WindowManagementBarComponent extends StatelessWidget {
  const WindowManagementBarComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Flexible(
            child: MoveWindow(),
          ),
          Row(
            children: [
              MinimizeWindowButton(
                colors: WindowButtonColors(
                  iconNormal:
                      AdaptiveTheme.of(context).theme.colorScheme.secondary,
                  iconMouseOver: Colors.green,
                ),
              ),
              MaximizeWindowButton(
                colors: WindowButtonColors(
                  iconNormal:
                      AdaptiveTheme.of(context).theme.colorScheme.secondary,
                  iconMouseOver: Colors.orange,
                ),
              ),
              CloseWindowButton(
                colors: WindowButtonColors(
                  iconNormal:
                      AdaptiveTheme.of(context).theme.colorScheme.secondary,
                  iconMouseOver: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
