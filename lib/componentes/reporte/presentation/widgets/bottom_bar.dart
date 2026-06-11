import 'package:flutter/material.dart';
import '../../../../styles/constantes/app_colors.dart';

class BottomBarWidget extends StatelessWidget {
  const BottomBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(40),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home_outlined, color: Colors.white),
          Icon(Icons.notifications_none, color: Colors.white),
          Icon(Icons.assignment_outlined, color: Colors.white),
          Icon(Icons.person_outline, color: Colors.white),
        ],
      ),
    );
  }
}