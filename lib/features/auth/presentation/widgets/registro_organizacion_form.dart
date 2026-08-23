import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/success_status_badge.dart';

enum _Paso { formulario, validando, validado }

class RegistroOrganizacionForm extends StatefulWidget {
  final Map<String, dynamic> datosUsuario;

  const RegistroOrganizacionForm({super.key, required this.datosUsuario});

  @override
  State<RegistroOrganizacionForm> createState() =>
      _RegistroOrganizacionFormState();
}

class _RegistroOrganizacionFormState extends State<RegistroOrganizacionForm> {
  final _formKey = GlobalKey<FormState>();

  final nombreOrgController = TextEditingController();
  final registroLegalController = TextEditingController();
  final tiposAnimalesController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();
  final fechaController = TextEditingController();

  DateTime? fechaFundacion;
  _Paso _paso = _Paso.formulario;

  @override
  void dispose() {
    nombreOrgController.dispose();
    registroLegalController.dispose();
    tiposAnimalesController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    fechaController.dispose();
    super.dispose();
  }

  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(2015),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        fechaFundacion = fecha;
        fechaController.text = "${fecha.day}/${fecha.month}/${fecha.year}";
      });
    }
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // Paso 1: validando
    setState(() => _paso = _Paso.validando);
    await Future.delayed(const Duration(seconds: 2)); // ⏳ simulado (luego backend)

    if (!mounted) return;

    // Paso 2: validado
    setState(() => _paso = _Paso.validado);
    await Future.delayed(const Duration(milliseconds: 1600));

    if (!mounted) return;

    // Paso 3: ir a contraseña con todos los datos
    context.go('/password', extra: {
      ...widget.datosUsuario,
      'organizacion': {
        'nombre': nombreOrgController.text.trim(),
        'registroLegal': registroLegalController.text.trim(),
        'tiposAnimales': tiposAnimalesController.text.trim(),
        'telefonoEmergencia': telefonoController.text.trim(),
        'correoInstitucional': correoController.text.trim(),
        'fechaFundacion': fechaFundacion,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_paso == _Paso.validando) return _buildValidando();
    if (_paso == _Paso.validado) return _buildValidado();
    return _buildFormulario();
  }

  // ========== FORMULARIO ==========
  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Registro de Rescate',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ayudanos a salvar más vidas',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: nombreOrgController,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa el nombre de la organización';
              }
              if (value.trim().length < 3) {
                return 'Mínimo 3 caracteres';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Nombre de la Organización',
              prefixIcon: Icon(Icons.pets_outlined),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: registroLegalController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa el registro o licencia legal';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Registro/Licencia Legal',
              prefixIcon: Icon(Icons.verified_user_outlined),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: tiposAnimalesController,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Indica qué tipos de animales rescatan';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Tipos de Animales Rescatados',
              hintText: 'Ej. Perros, gatos, aves...',
              prefixIcon: Icon(Icons.emoji_nature_outlined),
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
                return 'Ingresa el teléfono de emergencia';
              }
              if (value.length != 10) {
                return 'Debe contener 10 dígitos';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Teléfono de Emergencia',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: correoController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa el correo institucional';
              }
              if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Correo inválido';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico Institucional',
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
                return 'Selecciona la fecha de fundación';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Fecha de Fundación',
              prefixIcon: Icon(Icons.calendar_month),
            ),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _enviar,
              child: const Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }

  // ========== VALIDANDO ==========
  Widget _buildValidando() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Tus datos se están validando...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esto puede tomar unos momentos',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ========== VALIDADO ==========
  Widget _buildValidado() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SuccessStatusBadge(),
          const SizedBox(height: 20),
          Text(
            '¡Tus datos se han validado correctamente!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Continuando con la creación de tu cuenta...',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}