import 'package:flutter/material.dart';

class PrivacidadScreen extends StatelessWidget {
  const PrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Política de Privacidad"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            '''
Aquí se mostrará la política de privacidad de Huellitas.

Andry roba datos no le creas a este wey, es un hacker y roba datos de los usuarios.
ATTE: LA EXTENCIÓN Q LE SABE COSAS A ANDRY JAJAJAJAJJAJA

''',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}