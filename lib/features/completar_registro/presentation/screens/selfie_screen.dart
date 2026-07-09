import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/completar_perfil_bloc.dart';
import '../bloc/completar_perfil_event.dart';
import '../bloc/completar_perfil_state.dart';
import '../widgets/foto_card.dart';
import '../../../../core/verificacion/verificacion_cubit.dart';

class SelfieScreen extends StatelessWidget {
  const SelfieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifica tu identidad")),
      body: BlocConsumer<CompletarPerfilBloc, CompletarPerfilState>(
        listener: (context, state) {
          if (state is CompletarPerfilSuccess) {
            context.read<VerificacionCubit>().iniciarRevision();
            context.go('/perfil_completo');
          } else if (state is CompletarPerfilError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.mensaje)));
          }
        },
        builder: (context, state) {
          final cargando = state is CompletarPerfilLoading;
          final haySelfie =
              state is CompletarPerfilLoaded && state.selfie != null;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Selfie",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      context.read<CompletarPerfilBloc>().add(
                        SubirSelfieEvent(file),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (!haySelfie || cargando)
                        ? null
                        : () {
                            context.read<CompletarPerfilBloc>().add(
                              EnviarPerfilEvent(),
                            );
                          },
                    child: cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Enviar"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
