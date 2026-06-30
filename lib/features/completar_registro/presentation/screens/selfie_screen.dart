import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/foto_card.dart';

class SelfieScreen extends StatefulWidget {
  const SelfieScreen({super.key});

  @override
  State<SelfieScreen> createState() =>
      _SelfieScreenState();
}

class _SelfieScreenState
    extends State<SelfieScreen> {

  File? fotoSelfie;

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
                "Selfie",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Toma una fotografía clara de tu rostro para verificar tu identidad.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: FotoCard(
                titulo: "Toca para tomar la fotografía",
                onImageSelected: (file) {
                  setState(() {
                    fotoSelfie = file;
                  });
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: fotoSelfie == null
                    ? null
                    : () {
                        context.push(
                          '/perfil_completo',
                          extra: fotoSelfie,
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