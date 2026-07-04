import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/foto_card.dart';

class VerificarFrenteScreen extends StatefulWidget {
  const VerificarFrenteScreen({super.key});

  @override
  State<VerificarFrenteScreen> createState() =>
      _VerificarFrenteScreenState();
}

class _VerificarFrenteScreenState
    extends State<VerificarFrenteScreen> {

  File? fotoFrente;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verifica tu identidad"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Identificación (Frente)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Toma una fotografía clara del frente de tu identificación oficial.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: FotoCard(
                titulo: "Toca para tomar la fotografía",
                onImageSelected: (file) {
                  setState(() {
                    fotoFrente = file;
                  });
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: fotoFrente == null
                    ? null
                    : () {
                        context.push(
                          '/verificar-reverso',
                          extra: fotoFrente,
                        );
                      },
                child: const Text("Continuar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}