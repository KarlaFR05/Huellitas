import 'package:flutter/material.dart';

import '../../domain/entities/grupo.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../widgets/grupo_card.dart';
import '../widgets/grupo_imagen.dart';
import 'crear_grupo_screen.dart';
import 'grupo_detalle_screen.dart';

class GruposScreen extends StatefulWidget {
  const GruposScreen({super.key});

  @override
  State<GruposScreen> createState() => _GruposScreenState();
}

class _GruposScreenState extends State<GruposScreen> {
  final List<Grupo> _grupos = const [
    Grupo(
      id: 1,
      nombre: 'Rescatistas Huellitas',
      descripcion: 'Apoyo y coordinación para rescates de animales.',
      cantidadMiembros: 128,
      esMiembro: true,
      fotoPerfil: 'assets/images/avatares/avatar_01.png',
      fotoPortada: 'assets/images/avatares/avatar_04.png',
    ),
    Grupo(
      id: 2,
      nombre: 'Amantes de los gatos',
      descripcion: 'Consejos, historias y cuidados para nuestros michis.',
      cantidadMiembros: 84,
      fotoPerfil: 'assets/images/avatares/avatar_02.png',
      fotoPortada: 'assets/images/avatares/avatar_05.png',
    ),
    Grupo(
      id: 3,
      nombre: 'Paseos y convivencia',
      descripcion: 'Organicemos paseos seguros con nuestras mascotas.',
      cantidadMiembros: 47,
      fotoPerfil: 'assets/images/avatares/avatar_03.png',
      fotoPortada: 'assets/images/avatares/avatar_06.png',
    ),
  ];

  static const _acentos = [
    Color(0xFFFF9F2F),
    Color(0xFF7557D5),
    Color(0xFF3679D8),
  ];
  static const _iconos = [
    Icons.volunteer_activism_rounded,
    Icons.pets_rounded,
    Icons.directions_walk_rounded,
  ];

  void _cambiarMembresia(int index) {
    final grupo = _grupos[index];
    if (!grupo.esMiembro && grupo.privacidad == PrivacidadGrupo.privado) {
      setState(() {
        _grupos[index] = grupo.copyWith(
          solicitudPendiente: !grupo.solicitudPendiente,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            grupo.solicitudPendiente
                ? 'Solicitud cancelada'
                : 'Solicitud enviada al administrador',
          ),
        ),
      );
      return;
    }
    final seUne = !grupo.esMiembro;
    setState(() {
      _grupos[index] = grupo.copyWith(
        esMiembro: seUne,
        cantidadMiembros: grupo.cantidadMiembros + (seUne ? 1 : -1),
      );
    });
  }

  Future<void> _abrirGrupo(int index) async {
    final grupoActualizado = await Navigator.push<Grupo>(
      context,
      MaterialPageRoute(
        builder: (_) => GrupoDetalleScreen(grupo: _grupos[index]),
      ),
    );
    if (grupoActualizado == null || !mounted) return;
    setState(() => _grupos[index] = grupoActualizado);
  }

  Future<void> _verTodosMisGrupos() async {
    final indices = [
      for (var i = 0; i < _grupos.length; i++)
        if (_grupos[i].esMiembro) i,
    ];
    final seleccionado = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => _MisGruposScreen(
          grupos: [for (final index in indices) _grupos[index]],
          indicesOriginales: indices,
        ),
      ),
    );
    if (seleccionado != null && mounted) await _abrirGrupo(seleccionado);
  }

  Future<void> _buscarGrupo() async {
    final index = await showSearch<int?>(
      context: context,
      delegate: _BuscarGrupoDelegate(_grupos),
    );
    if (index != null && mounted) await _abrirGrupo(index);
  }

  Future<void> _crearGrupo() async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const CrearGrupoScreen()),
    );
    if (resultado == null || !mounted) return;
    setState(() {
      _grupos.insert(
        0,
        Grupo(
          id: DateTime.now().millisecondsSinceEpoch,
          nombre: resultado['nombre'] as String,
          descripcion: resultado['descripcion'] as String,
          fotoPerfil: 'assets/images/avatares/avatar_01.png',
          fotoPortada: 'assets/images/avatares/avatar_04.png',
          fotoPerfilLocalPath: resultado['perfilPath'] as String?,
          fotoPortadaLocalPath: resultado['portadaPath'] as String?,
          privacidad: resultado['privacidad'] as PrivacidadGrupo,
          cantidadMiembros: 1,
          esMiembro: true,
          esAdministradorActual: true,
          fechaCreacion: DateTime.now(),
        ),
      );
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Grupo creado correctamente')));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final propios = [
      for (var i = 0; i < _grupos.length; i++)
        if (_grupos[i].esMiembro) i,
    ];
    final descubrir = [
      for (var i = 0; i < _grupos.length; i++)
        if (!_grupos[i].esMiembro) i,
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          BottomBarWidget.contentClearance(context) + 88,
        ),
        children: [
          if (propios.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tus grupos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _verTodosMisGrupos,
                  child: const Text('Ver todos  ›'),
                ),
              ],
            ),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: propios.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, position) {
                  final index = propios[position];
                  return _GrupoCompacto(
                    grupo: _grupos[index],
                    color: _acentos[index % _acentos.length],
                    icon: _iconos[index % _iconos.length],
                    onTap: () => _abrirGrupo(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
          Container(
            padding: const EdgeInsets.fromLTRB(16, 15, 10, 15),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descubre nuevos grupos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Comunidades que podrían interesarte',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Buscar grupos',
                  onPressed: _buscarGrupo,
                  icon: Icon(
                    Icons.search_rounded,
                    color: colors.primary,
                    size: 29,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final index in descubrir)
            GrupoCard(
              grupo: _grupos[index],
              accentColor: _acentos[index % _acentos.length],
              icon: _iconos[index % _iconos.length],
              onAbrir: () => _abrirGrupo(index),
              onCambiarMembresia: () => _cambiarMembresia(index),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: BottomBarWidget.contentClearance(context) + 18,
        ),
        child: FloatingActionButton.extended(
          onPressed: _crearGrupo,
          icon: const Icon(Icons.group_add_rounded),
          label: const Text('Crear grupo'),
        ),
      ),
    );
  }
}

class _GrupoCompacto extends StatelessWidget {
  const _GrupoCompacto({
    required this.grupo,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final Grupo grupo;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: .5),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              SizedBox(
                height: 70,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    portadaGrupo(grupo),
                    ColoredBox(color: Colors.black.withValues(alpha: .1)),
                    Positioned(
                      left: 10,
                      bottom: -20,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: CircleAvatar(
                          radius: 21,
                          backgroundImage: imagenPerfilGrupo(grupo),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 25, 10, 8),
                child: Column(
                  children: [
                    Text(
                      grupo.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${grupo.cantidadMiembros} miembros',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '✓ Unido',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MisGruposScreen extends StatelessWidget {
  const _MisGruposScreen({
    required this.grupos,
    required this.indicesOriginales,
  });

  final List<Grupo> grupos;
  final List<int> indicesOriginales;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis grupos')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grupos.length,
        itemBuilder: (context, index) {
          final grupo = grupos[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 27,
                backgroundImage: imagenPerfilGrupo(grupo),
              ),
              title: Text(
                grupo.nombre,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('${grupo.cantidadMiembros} miembros'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(context, indicesOriginales[index]),
            ),
          );
        },
      ),
    );
  }
}

class _BuscarGrupoDelegate extends SearchDelegate<int?> {
  _BuscarGrupoDelegate(this.grupos);

  final List<Grupo> grupos;

  List<int> get _resultados {
    final texto = query.trim().toLowerCase();
    return [
      for (var i = 0; i < grupos.length; i++)
        if (texto.isEmpty || grupos[i].nombre.toLowerCase().contains(texto)) i,
    ];
  }

  @override
  String get searchFieldLabel => 'Buscar grupo por nombre';

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        tooltip: 'Limpiar',
        onPressed: () => query = '',
        icon: const Icon(Icons.close_rounded),
      ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    tooltip: 'Volver',
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back_rounded),
  );

  Widget _lista() {
    final resultados = _resultados;
    if (resultados.isEmpty) {
      return const Center(child: Text('No encontramos grupos con ese nombre'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: resultados.length,
      itemBuilder: (context, position) {
        final index = resultados[position];
        final grupo = grupos[index];
        return ListTile(
          leading: CircleAvatar(backgroundImage: imagenPerfilGrupo(grupo)),
          title: Text(
            grupo.nombre,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            grupo.esMiembro
                ? '${grupo.cantidadMiembros} miembros · Unido'
                : '${grupo.cantidadMiembros} miembros',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => close(context, index),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => _lista();

  @override
  Widget buildSuggestions(BuildContext context) => _lista();
}
