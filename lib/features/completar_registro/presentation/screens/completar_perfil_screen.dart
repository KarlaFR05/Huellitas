import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text("Completar Información")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _calleController,
              decoration: const InputDecoration(labelText: "Calle y Número"),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _coloniaController,
              decoration: const InputDecoration(labelText: "Colonia"),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _cpController,
              decoration: const InputDecoration(labelText: "Código Postal"),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _ciudadController,
              decoration: const InputDecoration(labelText: "Ciudad"),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _estadoController,
              decoration: const InputDecoration(labelText: "Estado"),
              onChanged: (_) => setState(() {}),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !_camposLlenos
                    ? null
                    : () {
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
                      },
                child: const Text("Siguiente"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
