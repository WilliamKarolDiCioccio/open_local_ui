import 'package:flutter/material.dart';

class PageBaseLayout extends StatelessWidget {
  final Widget body;

  const PageBaseLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: body,
    );
  }
}
