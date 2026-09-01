import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/widgets/bottom_bar.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../../domain/entities/adopcion.dart';
import '../../domain/repositories/crear_adopcion_solicitud.dart';
import '../bloc/adopciones_bloc.dart';
import '../bloc/adopciones_event.dart';
import '../bloc/adopciones_state.dart';

import '../widgets/adopcion_card.dart';
import 'adopciones_postulaciones_screen.dart';
import 'comentarios_screen.dart';
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
  final Map<int, Future<bool>> _yaPostuladoCache = {};

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
                        ? Future.value(false)
                        : _yaPostuladoDe(adopcion.id),
                  ]),
                  builder: (context, snapshot) {
                    final cantidad = snapshot.hasData
                        ? snapshot.data![0] as int
                        : 0;
                    final yaPostulado = snapshot.hasData
                        ? snapshot.data![1] as bool
                        : false;

                    return AdopcionCard(
                      adopcion: adopcion,
                      onAbrir: () {},
                      esPropietario:
                          usuarioId != null && adopcion.usuarioId == usuarioId,
                      postulacionPendiente: yaPostulado,
                      cantidadSolicitudes: cantidad,
                      onAccion: () {
                        if (usuarioId != null &&
                            adopcion.usuarioId == usuarioId) {
                          _verPostulantes(context, adopcion);
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

  Future<bool> _yaPostuladoDe(int adopcionId) {
    return _yaPostuladoCache.putIfAbsent(
      adopcionId,
      () => context.read<AdopcionesRepository>().yaPostulado(adopcionId),
    );
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
      _yaPostuladoCache.remove(adopcion.id);
      setState(() {});
    }
  }

  void _verPostulantes(BuildContext context, Adopcion adopcion) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AdopcionesPostulacionesScreen(adopcion: adopcion),
      ),
    );
  }
}
