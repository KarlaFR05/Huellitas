import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistroForm extends StatefulWidget {
  const RegistroForm({super.key});

  @override
  State<RegistroForm> createState() => _RegistroFormState();
}

class _RegistroFormState extends State<RegistroForm> {
  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController apellidosController =
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
  Widget build(BuildContext context) {
    return Column(
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

        TextField(
          controller: nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre(s)',
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: apellidosController,
          decoration: const InputDecoration(
            labelText: 'Apellidos',
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: telefonoController,
          decoration: const InputDecoration(
            labelText: 'Número Telefónico',
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: correoController,
          decoration: const InputDecoration(
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
            suffixIcon: Icon(
              Icons.calendar_month,
            ),
          ),
        ),

        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () {
            if (fechaNacimiento == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selecciona tu fecha de nacimiento'),
                ),
              );
              return;
            }

            context.go(
              '/password',
              extra: {
                'nombre': nombreController.text,
                'apellidos': apellidosController.text,
                'telefono': telefonoController.text,
                'correo': correoController.text,
                'fechaNacimiento': fechaNacimiento,
              },
            );
          },
          child: const Text(
            'Continuar',
          ),
        ),
      ],
    );
  }
}