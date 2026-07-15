import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/avatar_helper.dart';

class PerfilHeader extends StatelessWidget {
  const PerfilHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String nombre = "Usuario";
        String nombreUsuario = "";
        Usuario? usuario;

        if (state is AuthSuccess && state.data is Usuario) {
          usuario = state.data as Usuario;
          nombre = "${usuario.nombre} ${usuario.apellidos}";
          nombreUsuario = usuario.nombreUsuario ?? "";
        }

        return Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: avatarProvider(usuario?.fotoPerfil),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      context.push('/editar-perfil');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF57C29A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              nombreUsuario.isEmpty ? '' : '@$nombreUsuario',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}
