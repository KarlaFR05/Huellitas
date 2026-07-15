import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:huellitas/features/auth/domain/entities/usuario.dart';
import 'package:huellitas/features/auth/presentation/bloc/auth_state.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../../../../styles/constantes/app_colors.dart';
import '../widgets/perfil_option.dart';
import '../widgets/perfil_header.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../completar_registro/presentation/widgets/completar_perfil_dialog.dart';
import '../../../../core/verificacion/verificacion_cubit.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(title: const Text("Mi Perfil"), centerTitle: true),

      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const PerfilHeader(),

            const SizedBox(height: 24),

            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                bool yaVerificadoReal = false;
                if (authState is AuthSuccess && authState.data is Usuario) {
                  yaVerificadoReal = (authState.data as Usuario).verificado;
                }

                return BlocBuilder<VerificacionCubit, EstadoVerificacion>(
                  builder: (context, estado) {
                    final enRevisionSimulada =
                        estado == EstadoVerificacion.enRevision;
                    final verificadoSimulado =
                        estado == EstadoVerificacion.verificado;

                    final estaVerificado =
                        yaVerificadoReal || verificadoSimulado;
                    final deshabilitado = estaVerificado || enRevisionSimulada;

                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: deshabilitado
                                ? null
                                : () async {
                                    final aceptar = await showDialog<bool>(
                                      context: context,
                                      builder: (_) =>
                                          const CompletarPerfilDialog(),
                                    );

                                    if (aceptar == true) {
                                      context.push('/completar-perfil');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
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

                        if (enRevisionSimulada && !yaVerificadoReal) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber.shade800,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Tu información está siendo evaluada. Pronto te daremos una respuesta sobre tu estatus.',
                                    style: TextStyle(
                                      color: Colors.amber.shade900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (estaVerificado) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.deepPurple.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: Colors.deepPurple.shade400,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Ahora eres usuario verificado de Huellitas',
                                    style: TextStyle(
                                      color: Colors.deepPurple.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),

            SizedBox(height: 30),

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
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('¿Deseas cerrar tu sesión?'),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);

                              context.read<AuthBloc>().add(LogoutEvent());
                              context.read<VerificacionCubit>().resetear();

                              context.go('/login');
                            },
                            child: const Text('Cerrar sesión'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),

      bottomNavigationBar: const BottomBarWidget(currentIndex: 3),
    );
  }
}
