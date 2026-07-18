import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/completar_perfil_bloc.dart';
import '../bloc/completar_perfil_event.dart';

class CompletarPerfilScreen extends StatefulWidget {
  const CompletarPerfilScreen({super.key});

  @override
  State<CompletarPerfilScreen> createState() => _CompletarPerfilScreenState();
}

class _CompletarPerfilScreenState extends State<CompletarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _calleController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _cpController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _estadoController = TextEditingController();

  @override
  void dispose() {
    _calleController.dispose();
    _coloniaController.dispose();
    _cpController.dispose();
    _ciudadController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  bool get _camposLlenos =>
      _calleController.text.trim().isNotEmpty &&
      _coloniaController.text.trim().isNotEmpty &&
      _cpController.text.trim().isNotEmpty &&
      _ciudadController.text.trim().isNotEmpty &&
      _estadoController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completar Información')),
      body: SafeArea(
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Información de domicilio',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Completa los datos de tu domicilio para continuar con la verificación.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _calleController,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ .,#/\-]'),
                        ),
                        _sinEspaciosInvalidos,
                        LengthLimitingTextInputFormatter(80),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Calle y Número',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa la calle y número';
                        }
                        return _validarEspacios(value);
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _coloniaController,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ ]'),
                        ),
                        _sinEspaciosInvalidos,
                        LengthLimitingTextInputFormatter(60),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Colonia',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: _validarTextoDireccion,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _cpController,
                      decoration: const InputDecoration(
                        labelText: 'Código Postal',
                        prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el código postal';
                        }
                        if (value.length != 5) return 'Debe contener 5 dígitos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _ciudadController,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: _formattersSoloTexto(50),
                      decoration: const InputDecoration(
                        labelText: 'Ciudad',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: _validarTextoDireccion,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _estadoController,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: _formattersSoloTexto(50),
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: _validarTextoDireccion,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: !_camposLlenos ? null : _guardarDireccion,
                        child: const Text('Siguiente'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<TextInputFormatter> _formattersSoloTexto(int maxLength) => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]')),
    _sinEspaciosInvalidos,
    LengthLimitingTextInputFormatter(maxLength),
  ];

  final TextInputFormatter _sinEspaciosInvalidos =
      TextInputFormatter.withFunction((oldValue, newValue) {
        if (newValue.text.startsWith(' ') || newValue.text.contains('  ')) {
          return oldValue;
        }
        return newValue;
      });

  String? _validarEspacios(String value) {
    if (value.startsWith(' ') || value.endsWith(' ')) {
      return 'No puede iniciar o terminar con espacios';
    }
    if (value.contains(RegExp(r' {2,}'))) {
      return 'Usa solo un espacio entre palabras';
    }
    return null;
  }

  String? _validarTextoDireccion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    final errorEspacios = _validarEspacios(value);
    if (errorEspacios != null) return errorEspacios;
    if (value.split(' ').any((palabra) => palabra.length < 2)) {
      return 'Cada palabra debe tener al menos 2 caracteres';
    }
    return null;
  }

  void _guardarDireccion() {
    if (!_formKey.currentState!.validate()) return;

    context.read<CompletarPerfilBloc>().add(
      GuardarDireccionEvent(
        estado: _estadoController.text.trim(),
        ciudad: _ciudadController.text.trim(),
        cp: _cpController.text.trim(),
        colonia: _coloniaController.text.trim(),
        calle: _calleController.text.trim(),
      ),
    );
    context.push('/verificar-frente');
  }
}
