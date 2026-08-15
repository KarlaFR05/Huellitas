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

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notificaciones',
              onPressed: () => context.push('/notificaciones'),
              icon: Icon(
                Icons.notifications_none_rounded,
                color: colorScheme.primary,
                size: 29,
              ),
            ),
            if (noLeidas > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 19,
                    minHeight: 19,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                  child: Text(
                    noLeidas > 99 ? '99+' : '$noLeidas',
                    style: TextStyle(
                      color: colorScheme.onError,
                      fontSize: 10,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
