import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../data/datasources/editar_perfil_remote_datasource.dart';
import '../../../../core/widgets/avatar_helper.dart';

const List<String> catalogoAvatares = [
  'avatar_01.png',
  'avatar_02.png',
  'avatar_03.png',
  'avatar_04.png',
  'avatar_05.png',
  'avatar_06.png',
];

class SeleccionarFotoPerfilScreen extends StatefulWidget {
  const SeleccionarFotoPerfilScreen({super.key});

  @override
  State<SeleccionarFotoPerfilScreen> createState() =>
      _SeleccionarFotoPerfilScreenState();
}

class _SeleccionarFotoPerfilScreenState
    extends State<SeleccionarFotoPerfilScreen> {
  bool _guardando = false;
  final ImagePicker _picker = ImagePicker();
  String? _avatarSeleccionado;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.data is Usuario) {
      final usuario = authState.data as Usuario;
      if (usuario.fotoPerfil != null &&
          !usuario.fotoPerfil!.startsWith('http')) {
        _avatarSeleccionado = usuario.fotoPerfil;
      }
    }
  }

  Future<void> _seleccionarDelCatalogo(String nombreAvatar) async {
    setState(() {
      _guardando = true;
      _avatarSeleccionado = nombreAvatar;
    });
    try {
      final dio = context.read<Dio>();
      final datasource = EditarPerfilRemoteDataSource(dio);
      final usuarioActualizado = await datasource.actualizarFotoPerfilCatalogo(
        nombreAvatar,
      );

      if (!mounted) return;
      context.read<AuthBloc>().add(ActualizarUsuarioEvent(usuarioActualizado));
      context.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final mensaje =
          e.response?.data?['detail'] ?? 'Error al actualizar la foto';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  // TODO: reactivar cuando se vuelva a habilitar la subida de fotos propias
  // Future<void> _elegirDeGaleria(ImageSource source) async {
  //   final foto = await _picker.pickImage(source: source, imageQuality: 80);
  //   if (foto == null) return;
  //
  //   setState(() => _guardando = true);
  //   try {
  //     final dio = context.read<Dio>();
  //     final datasource = EditarPerfilRemoteDataSource(dio);
  //
  //     final usuarioActualizado = await datasource.subirFotoPerfilPersonalizada(
  //       File(foto.path),
  //     );
  //
  //     if (!mounted) return;
  //     context.read<AuthBloc>().add(ActualizarUsuarioEvent(usuarioActualizado));
  //     context.pop();
  //   } on DioException catch (e) {
  //     if (!mounted) return;
  //     final mensaje = e.response?.data?['detail'] ?? 'Error al subir la foto';
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(mensaje.toString()),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _guardando = false);
  //   }
  // }

  // TODO: reactivar junto con _elegirDeGaleria
  // void _mostrarOpcionesGaleria() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (_) => SafeArea(
  //       child: Wrap(
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.camera_alt),
  //             title: const Text("Tomar fotografía"),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _elegirDeGaleria(ImageSource.camera);
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.photo_library),
  //             title: const Text("Elegir de galería"),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _elegirDeGaleria(ImageSource.gallery);
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Elegir foto de perfil")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO: reactivar el botón de "Subir una foto propia" cuando
                // se vuelva a habilitar (descomentar junto con _mostrarOpcionesGaleria)
                // InkWell(
                //   onTap: _mostrarOpcionesGaleria,
                //   borderRadius: BorderRadius.circular(12),
                //   child: Container(
                //     padding: const EdgeInsets.all(16),
                //     decoration: BoxDecoration(
                //       color: const Color(0xFF57C29A).withValues(alpha: 0.1),
                //       borderRadius: BorderRadius.circular(12),
                //       border: Border.all(color: const Color(0xFF57C29A)),
                //     ),
                //     child: Row(
                //       children: const [
                //         Icon(
                //           Icons.add_photo_alternate_outlined,
                //           color: Color(0xFF57C29A),
                //         ),
                //         SizedBox(width: 12),
                //         Text(
                //           "Subir una foto propia",
                //           style: TextStyle(
                //             fontWeight: FontWeight.w600,
                //             color: Color(0xFF57C29A),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 28),
                const Text(
                  "Elige un avatar",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: catalogoAvatares.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemBuilder: (context, index) {
                    final nombre = catalogoAvatares[index];
                    final seleccionado = nombre == _avatarSeleccionado;

                    return GestureDetector(
                      onTap: () => _seleccionarDelCatalogo(nombre),
                      child: Center(
                        child: SizedBox(
                          width: 135,
                          height: 135,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 85,
                                backgroundImage: AssetImage(
                                  'assets/images/avatares/$nombre',
                                ),
                              ),
                              if (seleccionado)
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF57C29A),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: Theme.of(context).colorScheme.onSurface,
                                      size: 23,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          if (_guardando)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
