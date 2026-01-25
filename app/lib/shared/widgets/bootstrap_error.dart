import 'package:flutter/material.dart';

class BootstrapErrorWidget extends StatelessWidget {
  final String? error;
  const BootstrapErrorWidget({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(error ?? 'Unknown error'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
