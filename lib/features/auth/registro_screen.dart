import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController fechaController = TextEditingController();

  DateTime? fechaNacimiento;

  Future<void> seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(
        DateTime.now().year - 18,
        DateTime.now().month,
        DateTime.now().day,
      ),
      firstDate: DateTime(1900),

      // Solo permite mayores de edad
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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

            const TextField(
              decoration: InputDecoration(
                labelText: 'Nombre(s)',
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Apellidos',
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Número Telefónico',
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Correo',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: fechaController,
              readOnly: true,
              onTap: seleccionarFecha,
              decoration: const InputDecoration(
                labelText: 'Fecha de Nacimiento',
                suffixIcon: Icon(Icons.calendar_month),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () => context.go('/password'),
              child: const Text('Crear Cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}