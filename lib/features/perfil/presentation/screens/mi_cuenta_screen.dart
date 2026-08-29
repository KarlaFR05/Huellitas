import 'package:flutter/material.dart';

class MiCuentaScreen extends StatefulWidget {
  const MiCuentaScreen({super.key});

  @override
  State<MiCuentaScreen> createState() => _MiCuentaScreenState();
}

class _MiCuentaScreenState extends State<MiCuentaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titular = TextEditingController();
  final _cuenta = TextEditingController();

  @override
  void dispose() {
    _titular.dispose();
    _cuenta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi cuenta'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Configura la cuenta donde recibirás donaciones '
                'de los reportes que atiendas.',
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _titular,
                decoration: const InputDecoration(
                  labelText: 'Titular de la cuenta',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresa el titular';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _cuenta,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CLABE o número de cuenta',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 10) {
                    return 'Ingresa una cuenta válida';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Cuenta guardada correctamente',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Guardar cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}