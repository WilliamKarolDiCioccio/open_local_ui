import 'package:flutter/material.dart';

class TextIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const TextIconButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 8.0),
        TextButton(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16.0),
          ),
          onPressed: () => onPressed(),
        ),
      ],
    );
  }
}
