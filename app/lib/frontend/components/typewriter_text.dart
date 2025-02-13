import 'package:flutter/material.dart';

class TypewriterTextComponent extends StatefulWidget {
  final String text;
  final Duration duration;

  const TypewriterTextComponent({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<TypewriterTextComponent> createState() =>
      _TypewriterTextComponentState();
}

class _TypewriterTextComponentState extends State<TypewriterTextComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        final String visibleText = widget.text.substring(
          0,
          _characterCount.value,
        );
        return Text(
          visibleText,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
