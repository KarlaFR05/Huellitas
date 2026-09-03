import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../bloc/notificacion_bloc.dart';
import '../bloc/notificacion_event.dart';
import '../bloc/notificacion_state.dart';
import '../widgets/notificacion_card.dart';
import '../../domain/entities/notificacion.dart';
import '../../../foro/data/repositories/adopciones_repository.dart';
import '../../../foro/domain/entities/adopcion.dart';
import '../../../foro/presentation/widgets/adopcion_card.dart';

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
    final tipo = notificacion.tipo.trim().toLowerCase().replaceAll('-', '_');
    final adopcionId = _leerId(notificacion.data, const [
      'adopcion_id',
      'adopcionId',
    ]);
    final contacto = _leerTexto(notificacion.data, const [
      'contacto',
      'contacto_responsable',
      'medio_contacto',
    ]);
    if ((tipo == 'adopcion_aceptada' || tipo == 'adopcion_aprobada') &&
        adopcionId != null) {
      _mostrarAdopcionAceptada(context, notificacion, adopcionId, contacto);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
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

  void _mostrarAdopcionAceptada(
    BuildContext context,
    Notificacion notificacion,
    int adopcionId,
    String? contacto,
  ) {
    final adopcionFuture = _cargarAdopcionConReintento(adopcionId);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: .92,
        child: FutureBuilder<Adopcion>(
          future: adopcionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _AdopcionNoDisponible(
                mensaje: notificacion.mensaje,
                contacto: contacto,
                onReintentar: () {
                  Navigator.pop(sheetContext);
                  if (!mounted) return;
                  _mostrarAdopcionAceptada(
                    this.context,
                    notificacion,
                    adopcionId,
                    contacto,
                  );
                },
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                Text(
                  '¡Fuiste seleccionado!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notificacion.mensaje,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                AdopcionCard(
                  adopcion: snapshot.data!,
                  onAbrir: () {},
                  postulacionAceptada: true,
                  onAccion: () =>
                      _mostrarContactoAdopcion(sheetContext, contacto),
                ),
                _ContactoAdopcionAceptada(contacto: contacto),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<Adopcion> _cargarAdopcionConReintento(int adopcionId) async {
    final repository = context.read<AdopcionesRepository>();
    try {
      return await repository.obtenerAdopcion(adopcionId);
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      return repository.obtenerAdopcion(adopcionId);
    }
  }

  void _mostrarContactoAdopcion(BuildContext context, String? contacto) {
    final contactoDisponible = contacto?.trim();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: const Text('Medio de contacto'),
        content: SelectableText(
          contacto?.trim().isNotEmpty == true
              ? contacto!.trim()
              : 'El responsable todavía no compartió un medio de contacto.',
        ),
        actions: [
          TextButton.icon(
            onPressed: contactoDisponible?.isNotEmpty == true
                ? () => _copiarContacto(dialogContext, contactoDisponible!)
                : null,
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copiar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _copiarContacto(BuildContext context, String contacto) async {
    await Clipboard.setData(ClipboardData(text: contacto));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Contacto copiado al portapapeles.')),
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

class _ContactoAdopcionAceptada extends StatelessWidget {
  const _ContactoAdopcionAceptada({required this.contacto});

  final String? contacto;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final contactoDisponible = contacto?.trim();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.contact_phone_rounded, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contacto del responsable',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                SelectableText(
                  contacto?.trim().isNotEmpty == true
                      ? contacto!.trim()
                      : 'El responsable todavía no compartió un medio de contacto.',
                  style: TextStyle(color: colors.onSurface),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: contactoDisponible?.isNotEmpty == true
                      ? () async {
                          await Clipboard.setData(
                            ClipboardData(text: contactoDisponible!),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Contacto copiado al portapapeles.',
                                ),
                              ),
                            );
                        }
                      : null,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copiar contacto'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdopcionNoDisponible extends StatelessWidget {
  const _AdopcionNoDisponible({
    required this.mensaje,
    required this.contacto,
    required this.onReintentar,
  });

  final String mensaje;
  final String? contacto;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.pets_rounded, size: 64, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          '¡Fuiste seleccionado!',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(mensaje, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        const Text(
          'No fue posible cargar la publicación en este momento.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _ContactoAdopcionAceptada(contacto: contacto),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onReintentar,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Intentar nuevamente'),
        ),
      ],
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
