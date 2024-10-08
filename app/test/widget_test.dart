import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_local_ui/main.dart';

void main() {
  testWidgets('', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(
        userOnboarded: false,
        themeAccentColor: Colors.cyan,
        themeMode: AdaptiveThemeMode.light,
      ),
    );
  });
}
