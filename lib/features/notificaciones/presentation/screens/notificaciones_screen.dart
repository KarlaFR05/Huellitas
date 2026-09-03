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
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notificaciones',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<NotificacionBloc, NotificacionState>(
            builder: (context, state) {
              if (state is NotificacionLoaded) {
                return TextButton.icon(
                  onPressed: state.noLeidas == 0
                      ? null
                      : () => context.read<NotificacionBloc>().add(
                          MarcarTodasLeidas(),
                        ),
                  icon: const Icon(Icons.done_all_rounded, size: 22),
                  label: const Text('Leer todas'),
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
                  Text(
                    state.message,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<NotificacionBloc>().add(
                      CargarNotificaciones(),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificacionLoaded) {
            final notificaciones = state.notificaciones;
            if (notificaciones.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off,
                      size: 80,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes notificaciones',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                itemCount: notificaciones.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _ResumenNotificaciones(
                      total: notificaciones.length,
                      noLeidas: notificaciones.where((n) => !n.leida).length,
                    );
                  }
                  final notificacion = notificaciones[index - 1];
                  return NotificacionCard(
                    notificacion: notificacion,
                    onTap: () {
                      context.read<NotificacionBloc>().add(
                        MarcarComoLeida(notificacion.id),
                      );
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
    final tipo = notificacion.tipo.trim().toLowerCase().replaceAll('-', '_');
    final reporteId = _leerId(data, const ['reporte_id', 'reporteId']);
    final publicacionId = _leerId(data, const [
      'publicacion_id',
      'publicacionId',
    ]);
    final grupoId = _leerId(data, const ['grupo_id', 'grupoId']);

    switch (tipo) {
      case 'reporte_tomado':
      case 'reporte_cercano':
      case 'reporte_actualizado':
      case 'actualizacion_reporte':
        if (reporteId != null) {
          context.push('/reporte-estado/$reporteId');
        } else {
          _mostrarContenidoNoDisponible(context, 'reporte');
        }
        break;

      case 'reaccion':
      case 'comentario':
        if (publicacionId != null) {
          context.push('/foro?publicacionId=$publicacionId');
        } else {
          context.go('/foro');
        }
        break;

      case 'nuevo_miembro':
      case 'nuevo_miembro_grupo':
      case 'miembro_grupo':
      case 'miembro_unido':
      case 'aprobar_miembro':
        if (grupoId != null) {
          context.push('/administrar-grupo/$grupoId');
        } else {
          _mostrarContenidoNoDisponible(context, 'grupo');
        }
        break;

      case 'donacion':
        context.go('/historial');
        break;

      case 'reporte_exitoso':
      case 'reporte_creado':
        if (reporteId != null) {
          context.go('/home?reporteId=$reporteId');
        } else {
          context.go('/home');
        }
        break;

      case 'adopcion_aceptada':
      case 'adopcion_aprobada':
      case 'adopcion_no_seleccionada':
      case 'adopcion_rechazada':
        _mostrarResultadoAdopcion(context, notificacion);
        break;

      default:
        _mostrarContenidoNoDisponible(context, 'contenido');
    }
  }

  int? _leerId(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;
    for (final key in keys) {
      final valor = data[key];
      if (valor is int) return valor;
      final convertido = int.tryParse(valor?.toString() ?? '');
      if (convertido != null) return convertido;
    }
    return null;
  }

  void _mostrarResultadoAdopcion(
    BuildContext context,
    Notificacion notificacion,
  ) {
    final contacto = _leerTexto(notificacion.data, const [
      'contacto',
      'contacto_responsable',
      'medio_contacto',
    ]);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(notificacion.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notificacion.mensaje),
            if (contacto != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Medio de contacto',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              SelectableText(contacto),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  String? _leerTexto(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;
    for (final key in keys) {
      final valor = data[key]?.toString().trim();
      if (valor != null && valor.isNotEmpty) return valor;
    }
    return null;
  }

  void _mostrarContenidoNoDisponible(BuildContext context, String contenido) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo abrir el $contenido porque la notificación no incluye su identificador.',
          ),
        ),
      );
  }
}

class _ResumenNotificaciones extends StatelessWidget {
  const _ResumenNotificaciones({required this.total, required this.noLeidas});

  final int total;
  final int noLeidas;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colors.primary,
            Color.lerp(colors.primary, colors.surface, .28)!,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  noLeidas == 0
                      ? 'Estás al día'
                      : '$noLeidas ${noLeidas == 1 ? 'nueva' : 'nuevas'}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$total notificaciones en total',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
