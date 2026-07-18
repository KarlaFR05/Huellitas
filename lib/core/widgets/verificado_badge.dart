import 'package:flutter/material.dart';

class VerificadoBadge extends StatelessWidget {
  final double size;

  const VerificadoBadge({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.pets, size: size, color: const Color(0xFF57C29A)),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: size * 0.55,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
