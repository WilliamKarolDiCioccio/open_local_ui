import 'package:flutter/material.dart';

class TextIconButtonComponent extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const TextIconButtonComponent({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          label: Text(
            text,
            style: const TextStyle(fontSize: 16.0),
          ),
          icon: Icon(icon),
          onPressed: () => onPressed(),
        ),
      ],
    );
  }
}
