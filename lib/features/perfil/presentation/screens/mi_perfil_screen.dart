import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/avatar_helper.dart';

class MiPerfilScreen extends StatelessWidget {
  const MiPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Perfil"), centerTitle: true),

      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          Usuario? usuario;

          if (state is AuthSuccess && state.data is Usuario) {
            usuario = state.data as Usuario;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: avatarProvider(usuario?.fotoPerfil),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Información personal",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Nombre"),
                    subtitle: Text(
                      "${usuario?.nombre ?? ''} ${usuario?.apellidos ?? ''}",
                    ),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text("Correo"),
                    subtitle: Text(usuario?.correo ?? ""),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Teléfono"),
                    subtitle: Text(usuario?.numTelefono ?? ""),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.cake),
                    title: const Text("Fecha de nacimiento"),
                    subtitle: Text(
                      usuario?.fechaNacimiento?.toString().split(' ').first ??
                          "",
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Insignias",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    Chip(
                      avatar: Icon(Icons.workspace_premium),
                      label: Text("Usuario nuevo"),
                    ),
                    Chip(
                      avatar: Icon(Icons.verified),
                      label: Text("Verificado"),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Mis reportes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.pets),
                    title: const Text("Perrito lesionado"),
                    subtitle: const Text("En proceso"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.pets),
                    title: const Text("Gatito perdido"),
                    subtitle: const Text("Resuelto"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
