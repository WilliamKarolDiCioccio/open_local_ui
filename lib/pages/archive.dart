import 'package:flutter/material.dart';
import 'package:open_local_ui/widgets/page_base.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageBase(
      body: Center(
        child: Text(
          'Archive Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
