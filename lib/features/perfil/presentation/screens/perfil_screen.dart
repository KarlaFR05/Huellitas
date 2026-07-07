import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../../../../styles/constantes/app_colors.dart';
import '../widgets/perfil_option.dart';
import '../widgets/perfil_header.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../completar_registro/presentation/widgets/completar_perfil_dialog.dart';


class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Mi Perfil"),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const PerfilHeader(),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final aceptar = await showDialog<bool>(
                    context: context,
                    builder: (_) => const CompletarPerfilDialog(),
                  );

                  if (aceptar == true) {
                    context.push('/completar-perfil');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Completar perfil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 35),

            PerfilOption(
              icon: Icons.person_outline,
              titulo: 'Mi Perfil',
              onTap: () {
                context.push('/mi-perfil');
              },
            ),

            PerfilOption(
              icon: Icons.workspace_premium_outlined,
              titulo: 'Insignias',
              onTap: () {
                context.push('/insignias');
              },
            ),

            PerfilOption(
              icon: Icons.privacy_tip_outlined,
              titulo: 'Política de privacidad',
              onTap: () {
                context.push('/privacidad');
              },
            ),

            PerfilOption(
              icon: Icons.settings_outlined,
              titulo: 'Configuración',
              onTap: () {
                context.push('/configuracion');
              },
            ),

            PerfilOption(
              icon: Icons.help_outline,
              titulo: 'Ayuda',
              onTap: () {
                context.push('/ayuda');
              },
            ),

            PerfilOption(
              icon: Icons.logout,
              titulo: 'Cerrar sesión',
              mostrarFlecha: false,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text(
                      '¿Deseas cerrar tu sesión?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          context.read<AuthBloc>().add(
                            LogoutEvent(),
                          );

                          context.go('/login');
                        },
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),

      bottomNavigationBar: const BottomBarWidget(
        currentIndex: 3,
      ),
    );
  }
}