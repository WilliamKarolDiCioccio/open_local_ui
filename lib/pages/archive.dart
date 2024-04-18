import 'package:flutter/material.dart';
import 'package:open_local_ui/layout/page_base.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageBaseLayout(
      body: Center(
        child: Text(
          'Archive Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
