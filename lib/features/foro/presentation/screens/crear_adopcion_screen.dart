import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/avatar_helper.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/adopcion.dart';
import '../../domain/repositories/crear_adopcion_solicitud.dart';

class CrearAdopcionScreen extends StatefulWidget {
  const CrearAdopcionScreen({
    super.key,
    this.adopcion,
  });

  final Adopcion? adopcion;

  @override
  State<CrearAdopcionScreen> createState() =>
      _CrearAdopcionScreenState();
}

class _CrearAdopcionScreenState
    extends State<CrearAdopcionScreen> {
  final _contenidoController = TextEditingController();
  final _nombreMascotaController = TextEditingController();
  final _edadController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _vacunasController = TextEditingController();
  final _preguntaController = TextEditingController();

  final _imagePicker = ImagePicker();

  File? _imagen;
  String? _imagenExistenteUrl;

  bool _publicando = false;

  String _especie = 'Perro';
  String _tamano = 'Mediano';
  String _sexo = 'Macho';

  final List<String> _preguntas = [
    '¿Tienes tiempo suficiente?',
    '¿Cuentas con un ingreso mensual para proveer alimento?',
    '¿Consideras que el espacio en tu hogar es el adecuado?',
    '¿Tienes más mascotas?',
  ];

  bool get _editando => widget.adopcion != null;

  @override
  void initState() {
    super.initState();

    final adopcion = widget.adopcion;

    if (adopcion != null) {
      _contenidoController.text = adopcion.descripcion;
      _imagenExistenteUrl = adopcion.imagenUrl;

      _nombreMascotaController.text = adopcion.nombre;
      _edadController.text = adopcion.edad;
      _ciudadController.text = adopcion.ciudad;
      _vacunasController.text = adopcion.vacunas;

      _especie =
          adopcion.especie.isEmpty
              ? _especie
              : adopcion.especie;

      _tamano =
          adopcion.tamano.isEmpty
              ? _tamano
              : adopcion.tamano;

      _sexo =
          adopcion.sexo.isEmpty
              ? _sexo
              : adopcion.sexo;

      _preguntas
        ..clear()
        ..addAll(adopcion.preguntas);
    }
  }

  @override
  void dispose() {
    _contenidoController.dispose();
    _nombreMascotaController.dispose();
    _edadController.dispose();
    _ciudadController.dispose();
    _vacunasController.dispose();
    _preguntaController.dispose();

    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors =
            Theme.of(sheetContext).colorScheme;

        return SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleccionar imagen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: colors.primary,
                  ),
                  title: const Text(
                    'Tomar fotografía',
                  ),
                  onTap: () => Navigator.pop(
                    sheetContext,
                    ImageSource.camera,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: colors.primary,
                  ),
                  title: const Text(
                    'Seleccionar de galería',
                  ),
                  onTap: () => Navigator.pop(
                    sheetContext,
                    ImageSource.gallery,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final seleccionada =
          await _imagePicker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (seleccionada != null && mounted) {
        setState(() {
          _imagen = File(seleccionada.path);
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo seleccionar la imagen',
            ),
          ),
        );
      }
    }
  }

  Future<void> _publicar() async {
    final contenido =
        _contenidoController.text.trim();

    final nombre =
        _nombreMascotaController.text.trim();

    final edad =
        _edadController.text.trim();

    final ciudad =
        _ciudadController.text.trim();

    final vacunas =
        _vacunasController.text.trim();

    if (contenido.isEmpty ||
        edad.isEmpty ||
        ciudad.isEmpty ||
        vacunas.isEmpty ||
        (_imagen == null &&
            _imagenExistenteUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa descripción, edad, ciudad, vacunas y fotografía',
          ),
        ),
      );
      return;
    }

    setState(() {
      _publicando = true;
    });

    final solicitud = CrearAdopcionSolicitud(
      nombre: nombre,
      especie: _especie,
      edad: edad,
      tamano: _tamano,
      ciudad: ciudad,
      sexo: _sexo,
      vacunas: vacunas,
      descripcion: contenido,
      imagenLocalPath: _imagen?.path,
      imagenExistenteUrl: _imagen == null ? _imagenExistenteUrl : null,
      id: widget.adopcion?.id,
      preguntas: List<String>.from(_preguntas),
    );

    if (!mounted) return;

    setState(() {
      _publicando = false;
    });

    Navigator.pop(
      context,
      solicitud,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    final authState =
        context.watch<AuthBloc>().state;

    final usuario =
        authState is AuthSuccess &&
                authState.data is Usuario
            ? authState.data as Usuario
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editando
              ? 'Editar adopción'
              : 'Crear adopción',
        ),
        actions: [
          TextButton(
            onPressed:
                _publicando ? null : _publicar,
            child: Text(
              _editando ? 'Guardar' : 'Publicar',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          32,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _CamposAdopcion(
              nombreController:
                  _nombreMascotaController,
              edadController:
                  _edadController,
              ciudadController:
                  _ciudadController,
              vacunasController:
                  _vacunasController,
              especie: _especie,
              tamano: _tamano,
              sexo: _sexo,
              habilitado: !_publicando,
              onEspecie: (valor) {
                setState(() {
                  _especie = valor;
                });
              },
              onTamano: (valor) {
                setState(() {
                  _tamano = valor;
                });
              },
              onSexo: (valor) {
                setState(() {
                  _sexo = valor;
                });
              },
            ),

            const SizedBox(height: 18),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      colors.primaryContainer,
                  backgroundImage:
                      avatarProvider(
                    usuario?.fotoPerfil,
                  ),
                  child:
                      usuario?.fotoPerfil == null
                          ? Icon(
                              Icons.person_rounded,
                              color: colors.primary,
                            )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller:
                        _contenidoController,
                    enabled: !_publicando,
                    minLines: 5,
                    maxLines: 12,
                    maxLength: 500,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration:
                        const InputDecoration(
                      hintText:
                          'Describe a la mascota y su situación',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),

            if (_imagen != null ||
                _imagenExistenteUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(18),
                child: _imagen != null
                    ? Image.file(
                        _imagen!,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        _imagenExistenteUrl!,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                Container(
                          height: 250,
                          color: colors
                              .surfaceContainerHighest,
                          child: const Center(
                            child: Icon(
                              Icons
                                  .broken_image_outlined,
                            ),
                          ),
                        ),
                      ),
              ),
            ],

            const SizedBox(height: 16),

            Text(
              'Fotografía de la mascota',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),

            const SizedBox(height: 12),

            Material(
              color:
                  colors.surfaceContainerLowest,
              borderRadius:
                  BorderRadius.circular(20),
              child: InkWell(
                onTap: _publicando
                    ? null
                    : _seleccionarImagen,
                borderRadius:
                    BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          colors.outlineVariant,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        _imagen == null &&
                                _imagenExistenteUrl ==
                                    null
                            ? Icons
                                .add_a_photo_outlined
                            : Icons
                                .change_circle_outlined,
                        size: 34,
                        color: colors.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _imagen == null &&
                                _imagenExistenteUrl ==
                                    null
                            ? 'Toca para agregar una foto'
                            : 'Toca para elegir otra foto',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cámara o galería · Máximo 1 imagen',
                        style: TextStyle(
                          color:
                              colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Preguntas para postulantes',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),

            const SizedBox(height: 8),

            for (final pregunta in _preguntas)
              ListTile(
                dense: true,
                contentPadding:
                    EdgeInsets.zero,
                leading: const Icon(
                  Icons.help_outline_rounded,
                ),
                title: Text(pregunta),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                  onPressed: _publicando
                      ? null
                      : () {
                          setState(() {
                            _preguntas
                                .remove(pregunta);
                          });
                        },
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        _preguntaController,
                    enabled: !_publicando,
                    decoration:
                        const InputDecoration(
                      hintText:
                          'Agregar pregunta',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_rounded,
                  ),
                  onPressed: _publicando
                      ? null
                      : () {
                          final pregunta =
                              _preguntaController
                                  .text
                                  .trim();

                          if (pregunta.isNotEmpty) {
                            setState(() {
                              _preguntas
                                  .add(pregunta);
                              _preguntaController
                                  .clear();
                            });
                          }
                        },
                ),
              ],
            ),

            if (_publicando) ...[
              const SizedBox(height: 24),
              const Center(
                child:
                    CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CamposAdopcion
    extends StatelessWidget {
  const _CamposAdopcion({
    required this.nombreController,
    required this.edadController,
    required this.ciudadController,
    required this.vacunasController,
    required this.especie,
    required this.tamano,
    required this.sexo,
    required this.habilitado,
    required this.onEspecie,
    required this.onTamano,
    required this.onSexo,
  });

  final TextEditingController nombreController;
  final TextEditingController edadController;
  final TextEditingController ciudadController;
  final TextEditingController vacunasController;

  final String especie;
  final String tamano;
  final String sexo;

  final bool habilitado;

  final ValueChanged<String> onEspecie;
  final ValueChanged<String> onTamano;
  final ValueChanged<String> onSexo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Datos para adopción',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: nombreController,
          enabled: habilitado,
          textCapitalization:
              TextCapitalization.words,
          decoration: const InputDecoration(
            labelText:
                'Nombre de la mascota (opcional)',
            hintText:
                'Si no tiene nombre, déjalo vacío',
            prefixIcon:
                Icon(Icons.pets_rounded),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child:
                  DropdownButtonFormField<String>(
                value: especie,
                decoration:
                    const InputDecoration(
                  labelText: 'Especie',
                ),
                items: const [
                  'Perro',
                  'Gato',
                  'Otro',
                ]
                    .map(
                      (v) =>
                          DropdownMenuItem(
                        value: v,
                        child: Text(v),
                      ),
                    )
                    .toList(),
                onChanged: habilitado
                    ? (v) {
                        if (v != null) {
                          onEspecie(v);
                        }
                      }
                    : null,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: edadController,
                enabled: habilitado,
                decoration:
                    const InputDecoration(
                  labelText: 'Edad *',
                  hintText: 'Ej. 2 años',
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child:
                  DropdownButtonFormField<String>(
                value: tamano,
                decoration:
                    const InputDecoration(
                  labelText: 'Tamaño',
                ),
                items: const [
                  'Pequeño',
                  'Mediano',
                  'Grande',
                ]
                    .map(
                      (v) =>
                          DropdownMenuItem(
                        value: v,
                        child: Text(v),
                      ),
                    )
                    .toList(),
                onChanged: habilitado
                    ? (v) {
                        if (v != null) {
                          onTamano(v);
                        }
                      }
                    : null,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: ciudadController,
                enabled: habilitado,
                textCapitalization:
                    TextCapitalization.words,
                decoration:
                    const InputDecoration(
                  labelText: 'Ciudad *',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child:
                  DropdownButtonFormField<String>(
                value: sexo,
                decoration:
                    const InputDecoration(
                  labelText: 'Sexo',
                ),
                items: const [
                  'Macho',
                  'Hembra',
                ]
                    .map(
                      (v) =>
                          DropdownMenuItem(
                        value: v,
                        child: Text(v),
                      ),
                    )
                    .toList(),
                onChanged: habilitado
                    ? (v) {
                        if (v != null) {
                          onSexo(v);
                        }
                      }
                    : null,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: vacunasController,
                enabled: habilitado,
                maxLines: 2,
                textCapitalization:
                    TextCapitalization.sentences,
                decoration:
                    const InputDecoration(
                  labelText: 'Vacunas *',
                  hintText:
                      'Ej. Rabia, parvovirus',
                  prefixIcon: Icon(
                    Icons.vaccines_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
