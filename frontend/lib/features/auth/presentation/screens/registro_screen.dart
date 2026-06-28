import 'package:flutter/material.dart';

import '../widgets/registro_form.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: RegistroForm(),
      ),
    );
  }
}