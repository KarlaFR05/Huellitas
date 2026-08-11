import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/notificacion_bloc.dart';
import '../bloc/notificacion_event.dart';
import '../bloc/notificacion_state.dart';
import '../widgets/notificacion_card.dart';
import '../../domain/entities/notificacion.dart';
class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificacionBloc>().add(CargarNotificaciones());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notificaciones',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<NotificacionBloc, NotificacionState>(
            builder: (context, state) {
              if (state is NotificacionLoaded && state.noLeidas > 0) {
                return TextButton(
                  onPressed: () => context.read<NotificacionBloc>().add(MarcarTodasLeidas()),
                  child: const Text('Marcar todas'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificacionBloc, NotificacionState>(
        builder: (context, state) {
          if (state is NotificacionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificacionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message, style: TextStyle(color: colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<NotificacionBloc>().add(CargarNotificaciones()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificacionLoaded) {
            if (state.notificaciones.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 80, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes notificaciones',
                      style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificacionBloc>().add(CargarNotificaciones());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notificaciones.length,
                itemBuilder: (context, index) {
                  final notificacion = state.notificaciones[index];
                  return NotificacionCard(
                    notificacion: notificacion,
                    onTap: () {
                      context.read<NotificacionBloc>().add(MarcarComoLeida(notificacion.id));
                      _navegarSegunTipo(context, notificacion);
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _navegarSegunTipo(BuildContext context, Notificacion notificacion) {
    final data = notificacion.data;
    
    switch (notificacion.tipo) {
      case 'reporte_tomado':
      case 'reporte_cercano':
        if (data?['reporte_id'] != null) {
          final reporteId = data!['reporte_id'];  // ← Extrae el valor
          context.push('/reporte-estado/$reporteId');
        }
        break;
        
      case 'reaccion':
      case 'comentario':
        if (data?['publicacion_id'] != null) {
          final publicacionId = data!['publicacion_id'];  // ← Extrae el valor
          context.push('/foro?publicacionId=$publicacionId');
        } else {
          context.go('/foro');
        }
        break;
        
      case 'nuevo_miembro':
      case 'aprobar_miembro':
        if (data?['grupo_id'] != null) {
          final grupoId = data!['grupo_id'];  // ← Extrae el valor
          context.push('/administrar-grupo/$grupoId');
        }
        break;
        
      case 'donacion':
        context.go('/historial');
        break;
        
      case 'reporte_exitoso':
        if (data?['reporte_id'] != null) {
          final reporteId = data!['reporte_id'];  // ← Extrae el valor
          context.go('/home?reporteId=$reporteId');
        } else {
          context.go('/home');
        }
        break;
    }
  }
}