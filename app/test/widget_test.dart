import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_local_ui/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(
        themeAccentColor: Colors.cyan,
        themeMode: AdaptiveThemeMode.light,
      ),
    );
  });
}
