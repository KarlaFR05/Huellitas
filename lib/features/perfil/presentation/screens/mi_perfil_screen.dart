import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/avatar_helper.dart';
import '../../../../core/widgets/verificado_badge.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/domain/entities/usuario_publico.dart';
import '../../../auth/domain/usecases/obtener_perfil_publico_usecase.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../foro/domain/entities/publicacion.dart';
import '../../../foro/domain/entities/solicitudes_foro.dart';
import '../../../foro/domain/repositories/foro_repository.dart';
import '../../../foro/presentation/screens/comentarios_screen.dart';
import '../../../foro/presentation/widgets/publicacion_card.dart';
import '../../../insignias/data/repositories/insignia_repository_impl.dart';
import '../../../insignias/domain/entities/categoria_insignia.dart';
import '../../../insignias/domain/entities/insignia.dart';
import '../../../reporte/domain/entities/reporte.dart';
import '../../../reporte/domain/repositories/reporte_repository.dart';
import '../widgets/reporte_card.dart';

class MiPerfilScreen extends StatefulWidget {
  const MiPerfilScreen({super.key, this.usuarioId});

  final int? usuarioId;

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  UsuarioPublico? _perfilPublico;
  List<Publicacion> _publicaciones = const [];
  List<Reporte> _reportes = const [];
  List<Insignia> _insignias = const [];
  bool _cargandoPerfil = false;
  bool _cargandoContenido = false;
  int? _usuarioCargadoId;
  String? _errorPerfil;
  String? _errorContenido;

  bool get _esPerfilPropio => widget.usuarioId == null;

  @override
  void initState() {
    super.initState();
    if (!_esPerfilPropio) _cargarPerfilPublico();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_esPerfilPropio) return;
    final state = context.read<AuthBloc>().state;
    if (state is AuthSuccess && state.data is Usuario) {
      _cargarContenido((state.data as Usuario).usuarioIdPk);
    }
  }

  Future<void> _cargarPerfilPublico() async {
    setState(() => _cargandoPerfil = true);
    try {
      final perfil = await ObtenerPerfilPublicoUseCase(
        context.read<AuthRepositoryImpl>(),
      )(widget.usuarioId!);
      if (!mounted) return;
      setState(() {
        _perfilPublico = perfil;
        _cargandoPerfil = false;
      });
      await _cargarContenido(widget.usuarioId!);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorPerfil = 'No se pudo cargar el perfil';
        _cargandoPerfil = false;
      });
    }
  }

  Future<void> _cargarContenido(int usuarioId, {bool forzar = false}) async {
    if (!forzar && (_usuarioCargadoId == usuarioId || _cargandoContenido)) return;
    _usuarioCargadoId = usuarioId;
    setState(() {
      _cargandoContenido = true;
      _errorContenido = null;
    });
    try {
      final resultados = await Future.wait<dynamic>([
        context.read<ForoRepository>().obtenerFeed(
          FiltroPublicaciones(usuarioId: usuarioId, limite: 50),
        ),
        context.read<ReporteRepository>().obtenerReportes(),
        context
            .read<InsigniaRepositoryImpl>()
            .obtenerTodasLasInsignias(usuarioId)
            .catchError(
              (_) => <CategoriaInsignia, List<Insignia>>{},
            ),
      ]);
      if (!mounted) return;
      final pagina = resultados[0];
      final reportes = resultados[1] as List<Reporte>;
      final insigniasPorCategoria = resultados[2]
          as Map<CategoriaInsignia, List<Insignia>>;
      setState(() {
        // El filtro local evita mostrar contenido ajeno si una versión antigua
        // del backend ignora temporalmente el parámetro usuario_id.
        _publicaciones = (pagina.elementos as List<Publicacion>)
            .where((item) => item.usuarioId == usuarioId)
            .toList();
        _reportes = reportes.where((item) => item.usuarioId == usuarioId).toList()
          ..sort((a, b) => (b.fechaActualizacion ?? DateTime(0))
              .compareTo(a.fechaActualizacion ?? DateTime(0)));
        _insignias = insigniasPorCategoria.values
            .expand((lista) => lista)
            .where((insignia) => insignia.obtenida)
            .toList()
          ..sort((a, b) => b.nivel.compareTo(a.nivel));
        _cargandoContenido = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorContenido = 'No se pudieron cargar las publicaciones y reportes';
        _cargandoContenido = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final usuario = authState is AuthSuccess && authState.data is Usuario
        ? authState.data as Usuario
        : null;

    if (_esPerfilPropio && usuario != null && _usuarioCargadoId != usuario.usuarioIdPk) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cargarContenido(usuario.usuarioIdPk);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_esPerfilPropio ? 'Mi perfil' : 'Perfil'),
        centerTitle: true,
      ),
      body: _cargandoPerfil
          ? const Center(child: CircularProgressIndicator())
          : _errorPerfil != null
              ? Center(child: Text(_errorPerfil!))
              : RefreshIndicator(
                  onRefresh: () async {
                    final id = widget.usuarioId ?? usuario?.usuarioIdPk;
                    if (id != null) await _cargarContenido(id, forzar: true);
                  },
                  child: _PerfilContenido(
                    esPerfilPropio: _esPerfilPropio,
                    nombre: _esPerfilPropio
                        ? '${usuario?.nombre ?? ''} ${usuario?.apellidos ?? ''}'.trim()
                        : '${_perfilPublico?.nombre ?? ''} ${_perfilPublico?.apellidos ?? ''}'.trim(),
                    nombreUsuario: _esPerfilPropio
                        ? usuario?.nombreUsuario ?? ''
                        : _perfilPublico?.nombreUsuario ?? '',
                    correo: _esPerfilPropio ? usuario?.correo ?? '' : _perfilPublico?.correo ?? '',
                    telefono: _esPerfilPropio
                        ? usuario?.numTelefono ?? ''
                        : _perfilPublico?.numTelefono ?? '',
                    foto: _esPerfilPropio ? usuario?.fotoPerfil : _perfilPublico?.fotoPerfil,
                    verificado: _esPerfilPropio
                        ? usuario?.verificado ?? false
                        : _perfilPublico?.verificado ?? false,
                    publicaciones: _publicaciones,
                    reportes: _reportes,
                    insignias: _insignias,
                    cargandoContenido: _cargandoContenido,
                    errorContenido: _errorContenido,
                    onReintentar: () {
                      final id = widget.usuarioId ?? usuario?.usuarioIdPk;
                      if (id != null) _cargarContenido(id, forzar: true);
                    },
                    onMeGusta: _cambiarMeGusta,
                    onComentarios: _abrirComentarios,
                  ),
                ),
    );
  }

  Future<void> _cambiarMeGusta(Publicacion publicacion) async {
    final indice = _publicaciones.indexWhere((item) => item.id == publicacion.id);
    if (indice < 0) return;
    final anterior = _publicaciones[indice];
    setState(() {
      _publicaciones = [..._publicaciones];
      _publicaciones[indice] = anterior.copyWith(
        leGustaAlUsuario: !anterior.leGustaAlUsuario,
        meGusta: anterior.meGusta + (anterior.leGustaAlUsuario ? -1 : 1),
      );
    });
    try {
      final actualizada = await context.read<ForoRepository>().cambiarMeGusta(publicacion.id);
      if (!mounted) return;
      setState(() => _publicaciones[indice] = actualizada);
    } catch (_) {
      if (mounted) setState(() => _publicaciones[indice] = anterior);
    }
  }

  void _abrirComentarios(Publicacion publicacion) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ComentariosScreen(publicacion: publicacion)),
    );
  }
}

class _PerfilContenido extends StatelessWidget {
  const _PerfilContenido({
    required this.esPerfilPropio,
    required this.nombre,
    required this.nombreUsuario,
    required this.correo,
    required this.telefono,
    required this.foto,
    required this.verificado,
    required this.publicaciones,
    required this.reportes,
    required this.insignias,
    required this.cargandoContenido,
    required this.errorContenido,
    required this.onReintentar,
    required this.onMeGusta,
    required this.onComentarios,
  });

  final bool esPerfilPropio;
  final String nombre;
  final String nombreUsuario;
  final String correo;
  final String telefono;
  final String? foto;
  final bool verificado;
  final List<Publicacion> publicaciones;
  final List<Reporte> reportes;
  final List<Insignia> insignias;
  final bool cargandoContenido;
  final String? errorContenido;
  final VoidCallback onReintentar;
  final ValueChanged<Publicacion> onMeGusta;
  final ValueChanged<Publicacion> onComentarios;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(radius: 50, backgroundImage: avatarProvider(foto)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      nombre,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (verificado) ...[const SizedBox(width: 6), const VerificadoBadge(size: 21)],
                ],
              ),
              Text('@$nombreUsuario', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (esPerfilPropio) ...[
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(correo),
                ),
                if (telefono.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: Text(telefono),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ] else ...[
          if (telefono.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Teléfono de contacto'),
                subtitle: Text(telefono),
              ),
            )
          else
            Text(
              'Esta persona no tiene un número de contacto disponible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 24),
        ],
        _TituloSeccion(titulo: esPerfilPropio ? 'Mis insignias' : 'Insignias'),
        const SizedBox(height: 12),
        if (cargandoContenido)
          const SizedBox(
            height: 145,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (insignias.isEmpty)
          const _MensajeVacio(mensaje: 'Aún no hay insignias obtenidas.')
        else
          SizedBox(
            height: 155,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: insignias.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, index) => _InsigniaPerfil(
                insignia: insignias[index],
              ),
            ),
          ),
        const SizedBox(height: 26),
        _TituloSeccion(titulo: esPerfilPropio ? 'Mis reportes' : 'Reportes'),
        const SizedBox(height: 12),
        if (cargandoContenido)
          const SizedBox(height: 205, child: Center(child: CircularProgressIndicator()))
        else if (errorContenido != null)
          _MensajeVacio(mensaje: errorContenido!, onTap: onReintentar)
        else if (reportes.isEmpty)
          const _MensajeVacio(mensaje: 'Aún no hay reportes publicados.')
        else
          SizedBox(
            height: 270,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reportes.length,
              itemBuilder: (_, index) => ReporteCard(reporte: reportes[index]),
            ),
          ),
        const SizedBox(height: 26),
        const _TituloSeccion(titulo: 'Publicaciones'),
        const SizedBox(height: 6),
        if (!cargandoContenido && errorContenido == null && publicaciones.isEmpty)
          const _MensajeVacio(mensaje: 'Aún no hay publicaciones.')
        else
          for (final publicacion in publicaciones)
            PublicacionCard(
              publicacion: publicacion,
              avatarUrl: publicacion.fotoUsuarioUrl ?? foto,
              onMeGusta: () => onMeGusta(publicacion),
              onComentarios: () => onComentarios(publicacion),
            ),
      ],
    );
  }
}

class _InsigniaPerfil extends StatelessWidget {
  const _InsigniaPerfil({required this.insignia});

  final Insignia insignia;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 118,
      child: Column(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: insignia.imagenUrl?.isNotEmpty == true
                ? Image.network(
                    insignia.imagenUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      insignia.categoria.icon,
                      size: 58,
                      color: colors.primary,
                    ),
                  )
                : Icon(
                    insignia.categoria.icon,
                    size: 58,
                    color: colors.primary,
                  ),
          ),
          const SizedBox(height: 5),
          Text(
            insignia.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Nivel ${insignia.nivel}',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.titulo});
  final String titulo;

  @override
  Widget build(BuildContext context) => Text(
    titulo,
    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
  );
}

class _MensajeVacio extends StatelessWidget {
  const _MensajeVacio({required this.mensaje, this.onTap});
  final String mensaje;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Icon(Icons.pets_outlined, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(mensaje, textAlign: TextAlign.center),
        if (onTap != null) TextButton(onPressed: onTap, child: const Text('Reintentar')),
      ],
    ),
  );
}
