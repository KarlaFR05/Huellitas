import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/completar_perfil_bloc.dart';
import '../bloc/completar_perfil_event.dart';
import '../bloc/completar_perfil_state.dart';
import '../widgets/foto_card.dart';

class VerificarReversoScreen extends StatelessWidget {
  const VerificarReversoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifica tu identidad")),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
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
                  Text(
                    "Toma una fotografía clara del reverso de tu identificación oficial.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FotoCard(
                      titulo: "Toca para tomar la fotografía",
                      imageQuarterTurns: 1,
                      onImageSelected: (file) {
                        context.read<CompletarPerfilBloc>().add(
                          SubirReversoEvent(file),
                        );
                      },
                    ),
                  ),
                  BlocBuilder<CompletarPerfilBloc, CompletarPerfilState>(
                    builder: (context, state) {
                      final hayFoto =
                          state is CompletarPerfilLoaded &&
                          state.reverso != null;
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: hayFoto
                              ? () => context.push('/selfie')
                              : null,
                          child: const Text("Continuar"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
