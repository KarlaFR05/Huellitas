import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomBarWidget extends StatelessWidget {
  final int currentIndex;

  const BottomBarWidget({super.key, required this.currentIndex});

  /// Espacio que deben dejar botones flotantes o contenido interactivo para no
  /// quedar detrás de la barra, incluyendo la zona gestual del dispositivo.
  static double contentClearance(BuildContext context) {
    return 114 + MediaQuery.viewPaddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 4),
      child: Container(
        height: 78,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildItem(
              context,
              icon: Icons.map_outlined,
              selectedIcon: Icons.map_rounded,
              label: 'Mapa',
              index: 0,
              route: '/home',
            ),
            _buildItem(
              context,
              icon: Icons.mode_comment_outlined,
              selectedIcon: Icons.mode_comment_rounded,
              label: 'Foro',
              index: 1,
              route: '/foro',
            ),
            _buildItem(
              context,
              icon: Icons.volunteer_activism_outlined,
              selectedIcon: Icons.volunteer_activism_rounded,
              label: 'Donaciones',
              index: 2,
              route: '/donaciones',
            ),
            _buildItem(
              context,
              icon: Icons.person_outline,
              selectedIcon: Icons.person_rounded,
              label: 'Perfil',
              index: 3,
              route: '/perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
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
        width: 76,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: .12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? selectedIcon : icon,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: selected ? 26 : 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
