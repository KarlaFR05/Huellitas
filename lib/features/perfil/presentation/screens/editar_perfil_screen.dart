import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../styles/constantes/app_colors.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() =>
      _EditarPerfilScreenState();
}

class _EditarPerfilScreenState
    extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final nombreUsuarioController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? imagenPerfil;


  Future<void> _seleccionarImagen() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar imagen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Tomar fotografía'),
              onTap: () async {
                Navigator.pop(context);

                final foto = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );

                if (foto != null) {
                  setState(() {
                    imagenPerfil = File(foto.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Elegir de galería'),
              onTap: () async {
                Navigator.pop(context);

                final foto = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );

                if (foto != null) {
                  setState(() {
                    imagenPerfil = File(foto.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    nombreUsuarioController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    nombreUsuarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    if (state is AuthSuccess && state.data is Usuario) {
      final usuario = state.data as Usuario;

      if (nombreController.text.isEmpty) {
        nombreController.text = usuario.nombre ?? '';
        apellidosController.text = usuario.apellidos ?? '';
        nombreUsuarioController.text = usuario.nombreUsuario ?? '';
        correoController.text = usuario.correo ?? '';
        telefonoController.text = usuario.numTelefono ?? '';
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: imagenPerfil != null
                        ? FileImage(imagenPerfil!)
                        : const AssetImage(
                                'assets/images/perfil.png')
                            as ImageProvider,
                  ),

                  GestureDetector(
                    onTap: _seleccionarImagen,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF57C29A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller:
                nombreUsuarioController,
                maxLength:20,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  prefixIcon: Icon(Icons.alternate_email),
                  counterText:"",
                ),
                validator:(value){
                  if(value==null||value.isEmpty){
                    return "Ingresa un nombre de usuario";
                  }

                  if(!RegExp(
                    r'^(?=.{4,20}$)(?!.*[_.]{2})[a-zA-Z0-9]+([._]?[a-zA-Z0-9]+)*$'
                  ).hasMatch(value)){

                  return "Nombre de usuario inválido";
                  }

                  return null;

                },

              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: nombreController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu nombre';
                  }

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
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tus apellidos';
                  }

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
                controller: correoController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
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

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Perfil actualizado correctamente",
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Guardar cambios",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}