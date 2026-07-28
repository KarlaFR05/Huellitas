import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class RegistroForm extends StatefulWidget {
  const RegistroForm({super.key});

  @override
  State<RegistroForm> createState() => _RegistroFormState();
}

class _RegistroFormState extends State<RegistroForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController apellidosController =
      TextEditingController();

  final TextEditingController nombreUsuarioController =
    TextEditingController();

  final TextEditingController telefonoController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController fechaController =
      TextEditingController();

  DateTime? fechaNacimiento;

  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(
        DateTime.now().year - 18,
      ),
      firstDate: DateTime(1900),
      lastDate: DateTime(
        DateTime.now().year - 18,
        DateTime.now().month,
        DateTime.now().day,
      ),
    );

    if (fecha != null) {
      setState(() {
        fechaNacimiento = fecha;
        fechaController.text =
            "${fecha.day}/${fecha.month}/${fecha.year}";
      });
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    nombreUsuarioController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Nueva Cuenta',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),

          TextFormField(
            controller: nombreController,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]'),
              ),
              LengthLimitingTextInputFormatter(30),
            ],
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
              labelText: 'Nombre(s)',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: apellidosController,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]'),
              ),
              LengthLimitingTextInputFormatter(50),
            ],
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
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: nombreUsuarioController,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9._]'),
              ),
              LengthLimitingTextInputFormatter(20),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa un nombre de usuario';
              }

              if (value.length < 4) {
                return 'Debe tener mínimo 4 caracteres';
              }

              if (!RegExp(r'^[a-zA-Z0-9._]{4,20}$').hasMatch(value)) {
                return 'Solo letras, números, punto y guion bajo';
              }

              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Nombre de Usuario',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: telefonoController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu teléfono';
              }

              if (value.length != 10) {
                return 'Debe contener 10 dígitos';
              }

              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Número Telefónico',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: correoController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu correo';
              }

              if (!RegExp(
                r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Correo inválido';
              }

              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Correo',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: fechaController,
            readOnly: true,
            onTap: seleccionarFecha,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecciona una fecha';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Fecha de Nacimiento',
              prefixIcon: Icon(Icons.calendar_month),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                context.go(
                  '/password',
                  extra: {
                    'nombre': nombreController.text.trim(),
                    'apellidos': apellidosController.text.trim(),
                    'nombreUsuario': nombreUsuarioController.text.trim(),
                    'usuario': nombreUsuarioController.text.trim(),
                    'telefono': telefonoController.text.trim(),
                    'correo': correoController.text.trim(),
                    'fechaNacimiento': fechaNacimiento,
                  },
                );
              },
              child: const Text(
                'Continuar',
              ),
            ),
          ),
        ],
      ),
    );
  }
}