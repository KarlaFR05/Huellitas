import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../home/presentation/widgets/bottom_bar.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notificaciones/presentation/bloc/notificacion_bloc.dart';
import '../../../notificaciones/presentation/bloc/notificacion_state.dart';

import '../../domain/entities/adopcion.dart';
import '../../domain/entities/mi_postulacion_adopcion.dart';
import '../../domain/repositories/crear_adopcion_solicitud.dart';
import '../bloc/adopciones_bloc.dart';
import '../bloc/adopciones_event.dart';
import '../bloc/adopciones_state.dart';

import '../widgets/adopcion_card.dart';
import 'adopciones_postulaciones_screen.dart';
import 'crear_adopcion_screen.dart';
import 'postular_adopcion_screen.dart';
import '../../data/repositories/adopciones_repository.dart';

class AdopcionesScreen extends StatefulWidget {
  const AdopcionesScreen({super.key});

  @override
  State<AdopcionesScreen> createState() => _AdopcionesScreenState();
}

class _AdopcionesScreenState extends State<AdopcionesScreen> {
  final _busquedaController = TextEditingController();
  final Map<int, Future<int>> _conteoCache = {};
  final Map<int, Future<MiPostulacionAdopcion>> _miPostulacionCache = {};

  String _busqueda = '';

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;

    final usuarioId = auth is AuthSuccess && auth.data is Usuario
        ? (auth.data as Usuario).usuarioIdPk
        : null;

    final estado = context.watch<AdopcionesBloc>().state;
    final estadoNotificaciones = context.watch<NotificacionBloc>().state;
    final termino = _busqueda.toLowerCase();

    final adopciones = estado.adopciones.where((adopcion) {
      final texto = [
        adopcion.nombre,
        adopcion.especie,
        adopcion.edad,
        adopcion.tamano,
        adopcion.ciudad,
        adopcion.sexo,
        adopcion.vacunas,
        adopcion.descripcion,
        adopcion.nombreUsuario,
      ].join(' ');

      return termino.isEmpty || texto.toLowerCase().contains(termino);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          _conteoCache.clear();
          _miPostulacionCache.clear();
          context.read<AdopcionesBloc>().add(
            const AdopcionesSolicitadas(recargar: true),
          );
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            BottomBarWidget.contentClearance(context) + 88,
          ),
          children: [
            Text(
              'Adopciones',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Encuentra un nuevo compañero o '
              'ayúdale a encontrar un hogar.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _busquedaController,
              onChanged: (valor) {
                setState(() {
                  _busqueda = valor.trim();
                });
              },
              decoration: InputDecoration(
                labelText: 'Buscar adopciones',
                hintText: 'Gato, perro, ciudad o característica',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _busqueda.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _busquedaController.clear();
                          setState(() {
                            _busqueda = '';
                          });
                        },
                      ),
              ),
            ),
            const SizedBox(height: 18),
            if (estado.status == AdopcionesStatus.cargando &&
                estado.adopciones.isEmpty)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (estado.status == AdopcionesStatus.error)
              Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  'No se pudieron cargar las adopciones. ${estado.mensajeError ?? ''}',
                  textAlign: TextAlign.center,
                ),
              )
            else if (adopciones.isEmpty)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'No encontramos adopciones con esas características.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              for (final adopcion in adopciones)
                FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    _conteoDe(adopcion.id),
                    (usuarioId != null && adopcion.usuarioId == usuarioId)
                        ? Future.value(
                            const MiPostulacionAdopcion.noPostulado(),
                          )
                        : _miPostulacionDe(adopcion.id),
                  ]),
                  builder: (context, snapshot) {
                    final cantidad = snapshot.hasData
                        ? snapshot.data![0] as int
                        : 0;
                    final miPostulacion = snapshot.hasData
                        ? snapshot.data![1] as MiPostulacionAdopcion
                        : const MiPostulacionAdopcion.noPostulado();
                    final esPropietario =
                        usuarioId != null && adopcion.usuarioId == usuarioId;
                    final resultadoNotificado = _resultadoNotificado(
                      estadoNotificaciones,
                      adopcion.id,
                    );
                    final fueAceptada =
                        usuarioId != null &&
                        (adopcion.adoptanteId == usuarioId ||
                            miPostulacion.fueAceptada ||
                            resultadoNotificado.$1);

                    if (adopcion.estaCompletada &&
                        !esPropietario &&
                        !fueAceptada) {
                      return const SizedBox.shrink();
                    }

                    return AdopcionCard(
                      adopcion: adopcion,
                      onAbrir: () {},
                      esPropietario: esPropietario,
                      postulacionPendiente:
                          miPostulacion.yaPostulado && !fueAceptada,
                      postulacionAceptada: fueAceptada,
                      cantidadSolicitudes: cantidad,
                      onAccion: () {
                        if (esPropietario) {
                          _verPostulantes(context, adopcion);
                        } else if (adopcion.estaCompletada && fueAceptada) {
                          _mostrarContactoResponsable(
                            context,
                            miPostulacion.contactoResponsable ??
                                adopcion.contactoResponsable ??
                                resultadoNotificado.$2,
                          );
                        } else {
                          _postularme(context, adopcion);
                        }
                      },
                    );
                  },
                ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: BottomBarWidget.contentClearance(context) + 18,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _crearAdopcion(context),
          icon: const Icon(Icons.pets_rounded),
          label: const Text('Crear adopción'),
        ),
      ),
    );
  }

  Future<int> _conteoDe(int adopcionId) {
    return _conteoCache.putIfAbsent(
      adopcionId,
      () => context.read<AdopcionesRepository>().contarSolicitudes(adopcionId),
    );
  }

  Future<MiPostulacionAdopcion> _miPostulacionDe(int adopcionId) {
    return _miPostulacionCache.putIfAbsent(
      adopcionId,
      () =>
          context.read<AdopcionesRepository>().obtenerMiPostulacion(adopcionId),
    );
  }

  (bool, String?) _resultadoNotificado(
    NotificacionState estado,
    int adopcionId,
  ) {
    if (estado is! NotificacionLoaded) return (false, null);
    for (final notificacion in estado.notificaciones) {
      final tipo = notificacion.tipo.trim().toLowerCase().replaceAll('-', '_');
      if (tipo != 'adopcion_aceptada' && tipo != 'adopcion_aprobada') continue;
      final data = notificacion.data;
      final id = int.tryParse(
        (data?['adopcion_id'] ?? data?['adopcionId'])?.toString() ?? '',
      );
      if (id != adopcionId) continue;
      final contacto =
          (data?['contacto_responsable'] ??
                  data?['contacto'] ??
                  data?['medio_contacto'])
              ?.toString()
              .trim();
      return (true, contacto?.isNotEmpty == true ? contacto : null);
    }
    return (false, null);
  }

  Future<void> _crearAdopcion(BuildContext context) async {
    final resultado = await Navigator.push<CrearAdopcionSolicitud>(
      context,
      MaterialPageRoute(builder: (_) => const CrearAdopcionScreen()),
    );

    if (resultado == null || !mounted) {
      return;
    }
    final auth = context.read<AuthBloc>().state;
    final usuario = auth is AuthSuccess && auth.data is Usuario
        ? auth.data as Usuario
        : null;
    context.read<AdopcionesBloc>().add(
      AdopcionCreada(
        CrearAdopcionSolicitud(
          nombre: resultado.nombre,
          especie: resultado.especie,
          edad: resultado.edad,
          tamano: resultado.tamano,
          ciudad: resultado.ciudad,
          sexo: resultado.sexo,
          vacunas: resultado.vacunas,
          descripcion: resultado.descripcion,
          imagenLocalPath: resultado.imagenLocalPath,
          imagenExistenteUrl: resultado.imagenExistenteUrl,
          preguntas: resultado.preguntas,
          usuarioId: usuario?.usuarioIdPk,
          nombreUsuario: usuario?.nombreUsuario,
        ),
      ),
    );
  }

  Future<void> _postularme(BuildContext context, Adopcion adopcion) async {
    final auth = context.read<AuthBloc>().state;

    final nombreUsuario = auth is AuthSuccess && auth.data is Usuario
        ? (auth.data as Usuario).nombreUsuario
        : 'Postulante';

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PostularAdopcionScreen(
          adopcion: adopcion,
          nombreUsuario: nombreUsuario,
        ),
      ),
    );

    if (resultado == true && mounted) {
      _conteoCache.remove(adopcion.id);
      _miPostulacionCache.remove(adopcion.id);
      setState(() {});
    }
  }

  Future<void> _verPostulantes(BuildContext context, Adopcion adopcion) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AdopcionesPostulacionesScreen(adopcion: adopcion),
      ),
    );
    if (!mounted) return;
    _conteoCache.remove(adopcion.id);
    _miPostulacionCache.remove(adopcion.id);
    context.read<AdopcionesBloc>().add(
      const AdopcionesSolicitadas(recargar: true),
    );
  }

  void _mostrarContactoResponsable(BuildContext context, String? contacto) {
    final contactoDisponible = contacto?.trim();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: const Text('Adopción completada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fuiste la persona seleccionada. Puedes comunicarte con quien dio a la mascota en adopción.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Medio de contacto',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            SelectableText(
              contacto?.trim().isNotEmpty == true
                  ? contacto!.trim()
                  : 'El responsable todavía no compartió un medio de contacto.',
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: contactoDisponible?.isNotEmpty == true
                ? () async {
                    await Clipboard.setData(
                      ClipboardData(text: contactoDisponible!),
                    );
                    if (!dialogContext.mounted) return;
                    ScaffoldMessenger.of(dialogContext)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('Contacto copiado al portapapeles.'),
                        ),
                      );
                  }
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
}
