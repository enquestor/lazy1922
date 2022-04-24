import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  final Color? color;
  final double size;
  final bool filled;
  const Circle({
    Key? key,
    this.color,
    this.size = 24,
    this.filled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? color ?? Theme.of(context).colorScheme.primary : Colors.transparent,
        border: Border.all(
          color: color ?? Theme.of(context).colorScheme.primary,
          width: 1,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}
