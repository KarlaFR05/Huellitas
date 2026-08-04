import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../styles/constantes/app_color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/mensaje_error.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../data/datasources/editar_perfil_remote_datasource.dart';
import '../../../../core/widgets/avatar_helper.dart';
import '../../../../core/widgets/success_status_badge.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final nombreUsuarioController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final calleController = TextEditingController();
  final coloniaController = TextEditingController();
  final cpController = TextEditingController();
  final ciudadController = TextEditingController();

  bool _guardando = false;

  List<TextInputFormatter> _formateadoresNombre(int maxLength) => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]')),
    TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.startsWith(' ') || newValue.text.contains('  ')) {
        return oldValue;
      }
      return newValue;
    }),
    LengthLimitingTextInputFormatter(maxLength),
  ];

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.data is Usuario) {
      final usuario = authState.data as Usuario;
      nombreController.text = usuario.nombre;
      apellidosController.text = usuario.apellidos;
      nombreUsuarioController.text = usuario.nombreUsuario ?? '';
      correoController.text = usuario.correo;
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
                      child: const SuccessStatusBadge(),
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
        nombreUsuario: nombreUsuarioController.text.trim(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeDeError(e)),
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
    nombreUsuarioController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    calleController.dispose();
    coloniaController.dispose();
    cpController.dispose();
    ciudadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil")),
      body: Theme(
        data: screenTheme.copyWith(
          inputDecorationTheme: screenTheme.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: isDarkMode
                ? AppColors.darkField
                : screenTheme.inputDecorationTheme.fillColor,
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
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
                                onTap: () =>
                                    context.push('/seleccionar-foto-perfil'),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .shadow
                                            .withValues(alpha: 0.28),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
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
                        controller: nombreUsuarioController,
                        maxLength: 20,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          LengthLimitingTextInputFormatter(20),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nombre de usuario',
                          prefixIcon: Icon(Icons.alternate_email),
                          counterText: "",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Ingresa un nombre de usuario";
                          }
                          if (value.length < 4) {
                            return 'Debe tener al menos 4 caracteres';
                          }
                          if (value.contains(RegExp(r'\s'))) {
                            return 'No puede contener espacios';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: nombreController,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: _formateadoresNombre(30),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu nombre';
                          }
                          if (value.startsWith(' ') || value.endsWith(' ')) {
                            return 'No puede iniciar o terminar con espacios';
                          }
                          if (value.contains(RegExp(r' {2,}'))) {
                            return 'Solo un espacio entre nombres';
                          }
                          if (!RegExp(
                            r'^[A-Za-zÁÉÍÓÚáéíóúÑñ]{2,}( [A-Za-zÁÉÍÓÚáéíóúÑñ]{2,})*$',
                          ).hasMatch(value)) {
                            return 'Cada nombre debe tener al menos 2 letras';
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
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: _formateadoresNombre(50),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tus apellidos';
                          }
                          if (value.startsWith(' ') || value.endsWith(' ')) {
                            return 'No puede iniciar o terminar con espacios';
                          }
                          if (value.contains(RegExp(r' {2,}'))) {
                            return 'Solo un espacio entre apellidos';
                          }
                          if (!RegExp(
                            r'^[A-Za-zÁÉÍÓÚáéíóúÑñ]{2,}( [A-Za-zÁÉÍÓÚáéíóúÑñ]{2,})*$',
                          ).hasMatch(value)) {
                            return 'Cada apellido debe tener al menos 2 letras';
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
                        controller: correoController,
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(
                          color: isDarkMode
                              ? const Color(0xFFB8B8B8)
                              : Colors.grey.shade600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Correo',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: isDarkMode
                                ? const Color(0xFFB8B8B8)
                                : Colors.grey.shade500,
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.darkDisabledField
                              : Colors.grey.shade100,
                          helperText: 'El correo no se puede modificar',
                          helperStyle: TextStyle(
                            color: isDarkMode
                                ? const Color(0xFFB8B8B8)
                                : Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: telefonoController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa un teléfono';
                          }
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Debe contener 10 dígitos';
                          }
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
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(
                          color: isDarkMode
                              ? const Color(0xFFB8B8B8)
                              : Colors.grey.shade600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Calle y número',
                          prefixIcon: Icon(
                            Icons.home_outlined,
                            color: isDarkMode
                                ? const Color(0xFFB8B8B8)
                                : Colors.grey.shade500,
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.darkDisabledField
                              : Colors.grey.shade100,
                          helperText:
                              'Los datos de dirección no se pueden modificar.',
                          helperStyle: TextStyle(
                            color: isDarkMode
                                ? const Color(0xFFB8B8B8)
                                : Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: coloniaController,
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(
                          color: isDarkMode
                              ? const Color(0xFFB8B8B8)
                              : Colors.grey.shade600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Colonia',
                          prefixIcon: Icon(
                            Icons.location_city_outlined,
                            color: isDarkMode
                                ? const Color(0xFFB8B8B8)
                                : Colors.grey.shade500,
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.darkDisabledField
                              : Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: cpController,
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(
                          color: isDarkMode
                              ? const Color(0xFFB8B8B8)
                              : Colors.grey.shade600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Código Postal',
                          prefixIcon: Icon(
                            Icons.markunread_mailbox_outlined,
                            color: isDarkMode
                                ? const Color(0xFFB8B8B8)
                                : Colors.grey.shade500,
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.darkDisabledField
                              : Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: ciudadController,
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(
                          color: isDarkMode
                              ? const Color(0xFFB8B8B8)
                              : Colors.grey.shade600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Ciudad',
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            color: isDarkMode
                                ? const Color(0xFFB8B8B8)
                                : Colors.grey.shade500,
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.darkDisabledField
                              : Colors.grey.shade100,
                        ),
                      ),

                      const SizedBox(height: 35),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _guardando ? null : _guardarCambios,
                          child: _guardando
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                )
                              : const Text("Guardar cambios"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
