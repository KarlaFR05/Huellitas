import 'package:flutter/material.dart';
import '../../../../styles/constantes/app_colors.dart';

class BottomBarWidget extends StatelessWidget {
  final VoidCallback? onHomePressed;

  const BottomBarWidget({super.key, this.onHomePressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap:
                onHomePressed ??
                () {
                  // Comportamiento por defecto si no se proporciona callback
                  // Navegar al home directamente
                },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, color: Colors.white, size: 28),
              ],
            ),
          ),
          const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
          const Icon(Icons.volunteer_activism_outlined, color: Colors.white, size: 28),
          const Icon(Icons.person_outline, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}
