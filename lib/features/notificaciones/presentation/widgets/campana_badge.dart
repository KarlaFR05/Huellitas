import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/notificacion_bloc.dart';
import '../bloc/notificacion_state.dart';

class CampanaBadge extends StatelessWidget {
  const CampanaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<NotificacionBloc, NotificacionState>(
      builder: (context, state) {
        final noLeidas = state is NotificacionLoaded ? state.noLeidas : 0;

        return GestureDetector(
          onTap: () => context.push('/notificaciones'),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.onPrimary.withValues(alpha: 0.18),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
                if (noLeidas > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surface, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        noLeidas > 99 ? '99+' : '$noLeidas',
                        style: TextStyle(
                          color: colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}