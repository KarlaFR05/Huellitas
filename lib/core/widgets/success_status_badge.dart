import 'package:flutter/material.dart';

class SuccessStatusBadge extends StatelessWidget {
  final bool isSuccess;
  final double size;

  const SuccessStatusBadge({super.key, this.isSuccess = true, this.size = 120});

  @override
  Widget build(BuildContext context) {
    final color = isSuccess
        ? Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF6FD3AE)
              : Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.45), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.68,
          height: size * 0.68,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSuccess ? Icons.check_rounded : Icons.close_rounded,
            size: size * 0.46,
            color: color,
          ),
        ),
      ),
    );
  }
}
