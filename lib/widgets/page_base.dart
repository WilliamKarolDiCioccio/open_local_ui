import 'package:flutter/material.dart';

class PageBase extends StatelessWidget {
  final Widget body;

  const PageBase({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: body,
    );
  }
}