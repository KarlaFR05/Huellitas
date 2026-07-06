import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../styles/constantes/app_colors.dart';

class BottomBarWidget extends StatelessWidget {
  final int currentIndex;

  const BottomBarWidget({
    super.key,
    required this.currentIndex,
  });

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
          _buildItem(
            context,
            icon: Icons.home_outlined,
            index: 0,
            route: '/home',
          ),
          _buildItem(
            context,
            icon: Icons.chat_bubble_outline,
            index: 1,
            route: '/chat',
          ),
          _buildItem(
            context,
            icon: Icons.volunteer_activism_outlined,
            index: 2,
            route: '/adopciones',
          ),
          _buildItem(
            context,
            icon: Icons.person_outline,
            index: 3,
            route: '/perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required int index,
    required String route,
  }) {
    final bool selected = currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        if (!selected) {
          context.go(route);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: .20)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: selected ? 30 : 26,
        ),
      ),
    );
  }
}