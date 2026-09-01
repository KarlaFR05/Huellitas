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


import '../adopciones_postulaciones_store.dart';
import '../widgets/adopcion_card.dart';
import 'adopciones_postulaciones_screen.dart';
import 'comentarios_screen.dart';
import 'crear_adopcion_screen.dart';
import 'postular_adopcion_screen.dart';

class AdopcionesScreen extends StatefulWidget {
  const AdopcionesScreen({
    super.key,
  });

  @override
  State<AdopcionesScreen> createState() =>
      _AdopcionesScreenState();
}

class _AdopcionesScreenState
    extends State<AdopcionesScreen> {

  final _busquedaController = TextEditingController();

  String _busqueda = '';

  // Aquí debe venir tu lista real de adopciones.
  // Si ya tienes un Bloc/Repository de adopciones,
  // sustituye esta lista por ese estado.

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;

    final usuarioId =
        auth is AuthSuccess && auth.data is Usuario
            ? (auth.data as Usuario).usuarioIdPk
            : null;

    final nombreUsuario =
        auth is AuthSuccess && auth.data is Usuario
            ? (auth.data as Usuario).nombreUsuario
            : '';

    final estado = context.watch<AdopcionesBloc>().state;
    final termino = _busqueda.toLowerCase();

    final adopciones = estado.adopciones.where((adopcion) {
      if (PostulacionesAdopcionStore.estaCerrada(adopcion.id)) return false;
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

      return termino.isEmpty ||
          texto.toLowerCase().contains(termino);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: RefreshIndicator(
        onRefresh: () async {
          // Aquí llamarías a tu repository/bloc
          // para volver a cargar las adopciones.
          context.read<AdopcionesBloc>().add(
            const AdopcionesSolicitadas(recargar: true),
          );
        },

        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            BottomBarWidget.contentClearance(context) + 88,
          ),

          children: [

            Text(
              'Adopciones',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),

            const SizedBox(height: 4),

            Text(
              'Encuentra un nuevo compañero o '
              'ayúdale a encontrar un hogar.',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
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
                hintText:
                    'Gato, perro, ciudad o característica',
                prefixIcon:
                    const Icon(Icons.search_rounded),

                suffixIcon: _busqueda.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                        ),
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

            if (estado.status == AdopcionesStatus.cargando && estado.adopciones.isEmpty)
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
                Builder(builder: (context) {
                  final postulacion = PostulacionesAdopcionStore
                      .postulacionDeUsuario(adopcion.id, usuarioId, nombreUsuario);
                  return AdopcionCard(
                  adopcion: adopcion,
                  postulacionAceptada: postulacion?.fueAceptada == true ? postulacion : null,

                  onAbrir: () {},

                  esPropietario: usuarioId != null && adopcion.usuarioId == usuarioId,

                  postulacionPendiente:
                      (usuarioId == null || adopcion.usuarioId != usuarioId) &&
                      PostulacionesAdopcionStore
                          .tienePostulacion(
                        adopcion.id,
                        nombreUsuario,
                      ),

                  onAccion: () {
                    if (usuarioId != null && adopcion.usuarioId == usuarioId) {
                      _verPostulantes(
                        context,
                        adopcion,
                      );
                    } else {
                      if (postulacion?.fueAceptada == true) {
                        _mostrarContactoAceptacion(context, adopcion, postulacion!);
                      } else {
                        _postularme(context, adopcion);
                      }
                    }
                  },
                );
                }),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom:
              BottomBarWidget.contentClearance(context) +
                  18,
        ),

        child: FloatingActionButton.extended(
          onPressed: () =>
              _crearAdopcion(context),

          icon: const Icon(
            Icons.pets_rounded,
          ),

          label: const Text(
            'Crear adopción',
          ),
        ),
      ),
    );
  }

  Future<void> _crearAdopcion(
    BuildContext context,
  ) async {
    final resultado =
        await Navigator.push<CrearAdopcionSolicitud>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CrearAdopcionScreen(),
      ),
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
          sonVariasMascotas: resultado.sonVariasMascotas,
          usuarioId: usuario?.usuarioIdPk,
          nombreUsuario: usuario?.nombreUsuario,
        ),
      ),
    );
  }

  void _mostrarContactoAceptacion(
    BuildContext context,
    Adopcion adopcion,
    PostulacionAdopcion postulacion,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.celebration_rounded),
        title: const Text('¡Tu postulación fue aceptada!'),
        content: Text(
          '${adopcion.nombreUsuario} aceptó tu solicitud para ${adopcion.nombre}.\n\n'
          'Contacto: ${postulacion.contactoResponsable ?? 'No disponible'}',
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

  Future<void> _postularme(
    BuildContext context,
    Adopcion adopcion,
  ) async {
    final auth = context.read<AuthBloc>().state;

    final nombreUsuario =
        auth is AuthSuccess && auth.data is Usuario
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
      setState(() {});
    }
  }

  Future<void> _verPostulantes(
    BuildContext context,
    Adopcion adopcion,
  ) async {
    await Navigator.push<void>(
      context,

      MaterialPageRoute(
        builder: (_) =>
            AdopcionesPostulacionesScreen(
          adopcion: adopcion,
        ),
      ),
    );
    if (mounted) setState(() {});
  }
}
