import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../data/datasources/editar_perfil_remote_datasource.dart';
import '../../../../core/widgets/avatar_helper.dart';

import 'package:go_router/go_router.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final telefonoController = TextEditingController();
  final calleController = TextEditingController();
  final coloniaController = TextEditingController();
  final cpController = TextEditingController();
  final ciudadController = TextEditingController();

  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.data is Usuario) {
      final usuario = authState.data as Usuario;
      nombreController.text = usuario.nombre;
      apellidosController.text = usuario.apellidos;
      telefonoController.text = usuario.numTelefono;
      calleController.text = usuario.calle ?? '';
      coloniaController.text = usuario.colonia ?? '';
      cpController.text = usuario.cp ?? '';
      ciudadController.text = usuario.ciudad ?? '';
    }
  }

  void _mostrarExito() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );

        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: curved.value.clamp(0.0, 1.2),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 56,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Perfil actualizado\ncorrectamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      context.go('/perfil');
    });
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final dio = context.read<Dio>();
      final datasource = EditarPerfilRemoteDataSource(dio);

      final usuarioActualizado = await datasource.editarPerfil(
        nombre: nombreController.text.trim(),
        apellidos: apellidosController.text.trim(),
        numTelefono: telefonoController.text.trim(),
        calle: calleController.text.trim().isEmpty
            ? null
            : calleController.text.trim(),
        colonia: coloniaController.text.trim().isEmpty
            ? null
            : coloniaController.text.trim(),
        cp: cpController.text.trim().isEmpty ? null : cpController.text.trim(),
        ciudad: ciudadController.text.trim().isEmpty
            ? null
            : ciudadController.text.trim(),
      );

      if (!mounted) return;

      context.read<AuthBloc>().add(ActualizarUsuarioEvent(usuarioActualizado));

      _mostrarExito();
    } on DioException catch (e) {
      if (!mounted) return;
      final mensaje =
          e.response?.data?['detail'] ?? 'Error al actualizar el perfil';
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

  @override
  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    telefonoController.dispose();
    calleController.dispose();
    coloniaController.dispose();
    cpController.dispose();
    ciudadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String? fotoPerfil;
                  if (state is AuthSuccess && state.data is Usuario) {
                    fotoPerfil = (state.data as Usuario).fotoPerfil;
                  }

                  return Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: avatarProvider(fotoPerfil),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/seleccionar-foto-perfil'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF57C29A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Datos Personales',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: nombreController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Ingresa tu nombre';
                  if (!RegExp(
                    r'^[A-Za-zÁÉÍÓÚáéíóúÑñ]+(?: [A-Za-zÁÉÍÓÚáéíóúÑñ]+)*$',
                  ).hasMatch(value.trim())) {
                    return 'Solo letras';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: apellidosController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Ingresa tus apellidos';
                  if (!RegExp(
                    r'^[A-Za-zÁÉÍÓÚáéíóúÑñ]+(?: [A-Za-zÁÉÍÓÚáéíóúÑñ]+)*$',
                  ).hasMatch(value.trim())) {
                    return 'Solo letras';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ingresa un teléfono';
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value))
                    return 'Debe contener 10 dígitos';
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),

              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dirección',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: calleController,
                decoration: const InputDecoration(
                  labelText: 'Calle y número',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: coloniaController,
                decoration: const InputDecoration(
                  labelText: 'Colonia',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: cpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Código Postal',
                  prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: ciudadController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardarCambios,
                  child: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Guardar cambios"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
