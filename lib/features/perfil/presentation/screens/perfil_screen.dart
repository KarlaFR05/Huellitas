import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:huellitas/features/auth/domain/entities/usuario.dart';
import 'package:huellitas/features/auth/presentation/bloc/auth_state.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../widgets/perfil_option.dart';
import '../widgets/perfil_header.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../completar_registro/presentation/widgets/completar_perfil_dialog.dart';
import '../../../../core/verificacion/verificacion_cubit.dart';
import '../../../../core/widgets/verificado_badge.dart';
import '../../../donaciones/presentation/bloc/tarjeta/tarjeta_bloc.dart';
import '../../../donaciones/presentation/bloc/tarjeta/tarjeta_event.dart';
import '../../../donaciones/presentation/bloc/tarjeta/tarjeta_state.dart';
import 'perfil_organizacion_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool forzarVistaOrganizacion = false;

  @override
  void initState() {
    super.initState();
    _cargarTarjetas();
  }

  void _cargarTarjetas() {
    final authState = context.read<AuthBloc>().state;
    // Solo carga tarjetas si NO es organización
    final esOrganizacion = authState is AuthSuccess &&
        authState.data is Usuario &&
        (authState.data as Usuario).esOrganizacion;
    if (authState is AuthSuccess && !esOrganizacion) {
      context.read<TarjetaBloc>().add(CargarTarjetas());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si es organización (o está forzado), muestra su propio perfil
    final authState = context.watch<AuthBloc>().state;
    final esOrganizacion = forzarVistaOrganizacion ||
        (authState is AuthSuccess &&
            authState.data is Usuario &&
            (authState.data as Usuario).esOrganizacion);

    if (esOrganizacion) {
      return const PerfilOrganizacionScreen();
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text("Perfil"), centerTitle: true),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            BottomBarWidget.contentClearance(context) + 28,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
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
                      final deshabilitado =
                          estaVerificado || enRevisionSimulada;

                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: deshabilitado
                                  ? null
                                  : () async {
                                      final aceptar = await showDialog<bool>(
                                        context: context,
                                        builder: (_) =>
                                            const CompletarPerfilDialog(),
                                      );

                                      if (!context.mounted) return;
                                      if (aceptar == true) {
                                        context.push('/completar-perfil');
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                                disabledBackgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                                disabledForegroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                estaVerificado
                                    ? 'Perfil verificado'
                                    : enRevisionSimulada
                                    ? 'Verificación en revisión'
                                    : 'Completar perfil',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          if (enRevisionSimulada && !yaVerificadoReal) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.55),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.amber.shade700,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Tu información está siendo evaluada. Pronto te daremos una respuesta sobre tu estatus.',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const VerificadoBadge(size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Ahora eres usuario verificado de Huellitas',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
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

              const SizedBox(height: 30),

              PerfilOption(
                icon: Icons.person_outline,
                titulo: 'Mi Perfil',
                onTap: () {
                  context.push('/mi-perfil');
                },
              ),

              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) => BlocBuilder<VerificacionCubit, EstadoVerificacion>(
                  builder: (context, estado) {
                    final verificadoEnCuenta = authState is AuthSuccess && authState.data is Usuario && (authState.data as Usuario).verificado;
                    final estaVerificado = verificadoEnCuenta || estado == EstadoVerificacion.verificado;
                    if (!estaVerificado) return const SizedBox.shrink();
                    return PerfilOption(
                      icon: Icons.account_balance_wallet_outlined,
                      titulo: 'Mi cuenta',
                      subtitulo: 'Recibe donaciones en tus reportes',
                      onTap: () => context.push('/mi-cuenta'),
                    );
                  },
                ),
              ),

              BlocBuilder<TarjetaBloc, TarjetaState>(
                builder: (context, tarjetaState) {
                  int cantidadTarjetas = 0;
                  if (tarjetaState is TarjetaLoaded) {
                    cantidadTarjetas = tarjetaState.tarjetas.length;
                  }

                  return PerfilOption(
                    icon: Icons.credit_card,
                    titulo: 'Mis tarjetas',
                    subtitulo: cantidadTarjetas > 0
                        ? '$cantidadTarjetas tarjeta(s) guardada(s)'
                        : null,
                    trailing: cantidadTarjetas > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cantidadTarjetas.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        : null,
                    onTap: () {
                      context.push('/mis-tarjetas');
                    },
                  );
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