import 'package:flutter/material.dart';
import 'package:open_local_ui/layout/page_base.dart';

class ModelsPage extends StatelessWidget {
  const ModelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageBaseLayout(
      body: Center(
        child: Text(
          'Models Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
