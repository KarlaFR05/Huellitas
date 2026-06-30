import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/foto_card.dart';

class VerificarReversoScreen extends StatefulWidget {
  const VerificarReversoScreen({super.key});

  @override
  State<VerificarReversoScreen> createState() =>
      _VerificarReversoScreenState();
}

class _VerificarReversoScreenState
    extends State<VerificarReversoScreen> {

  File? fotoReverso;

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
                "Identificación (Reverso)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Toma una fotografía clara del reverso de tu identificación oficial.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: FotoCard(
                titulo: "Toca para tomar la fotografía",
                onImageSelected: (file) {
                  setState(() {
                    fotoReverso = file;
                  });
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: fotoReverso == null
                    ? null
                    : () {
                        context.push(
                          '/selfie',
                          extra: fotoReverso,
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