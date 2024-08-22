import 'package:flutter/material.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_theme/system_theme.dart';

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
                  iconNormal: SystemTheme.accentColor.accent,
                  iconMouseOver: Colors.green,
                ),
              ),
              MaximizeWindowButton(
                colors: WindowButtonColors(
                  iconNormal: SystemTheme.accentColor.accent,
                  iconMouseOver: Colors.orange,
                ),
              ),
              CloseWindowButton(
                colors: WindowButtonColors(
                  iconNormal: SystemTheme.accentColor.accent,
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
