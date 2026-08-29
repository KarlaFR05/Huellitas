import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/donacion_bloc.dart';
import '../bloc/donacion_event.dart';
import '../bloc/donacion_state.dart';
import '../bloc/tarjeta/tarjeta_bloc.dart';
import '../bloc/tarjeta/tarjeta_event.dart';
import '../bloc/tarjeta/tarjeta_state.dart';
import '../../domain/entities/tarjeta.dart';

class SeleccionCantidadScreen extends StatefulWidget {
  const SeleccionCantidadScreen({super.key});

  @override
  State<SeleccionCantidadScreen> createState() =>
      _SeleccionCantidadScreenState();
}

class _SeleccionCantidadScreenState extends State<SeleccionCantidadScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<DonacionBloc, DonacionState>(
      listener: (context, state) {
        if (state is DonacionCompletada) {
          context.go('/confirmacion-donacion');
        } else if (state is DonacionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              leading: BlocBuilder<DonacionBloc, DonacionState>(
                builder: (context, state) {
                  final procesando = state is DonacionProcesando;
                  return IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                    onPressed: procesando ? null : () => context.pop(),
                  );
                },
              ),
              title: Text(
                'Tu ayuda puede \n salvar vidas',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
            ),
            body: BlocBuilder<DonacionBloc, DonacionState>(
              builder: (context, state) {
                if (state is! DonacionLoaded ||
                    state.organizacionSeleccionada == null) {
                  return Center(
                    child: Text(
                      'No hay organización seleccionada',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    24 + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite,
                                size: 48,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Apoyando a',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.organizacionSeleccionada!.nombre,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Selecciona un monto',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elige una cantidad o ingresa una personalizada',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                        children: [
                          _MontoCard(
                            monto: 5,
                            onTap: () =>
                                _verificarTarjetasYContinuar(context, 5),
                          ),
                          _MontoCard(
                            monto: 15,
                            onTap: () =>
                                _verificarTarjetasYContinuar(context, 15),
                          ),
                          _MontoCard(
                            monto: 20,
                            onTap: () =>
                                _verificarTarjetasYContinuar(context, 20),
                          ),
                          _MontoPersonalizadoCard(
                            onTap: () => context.push('/monto-personalizado'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tu donación ayuda a proporcionar alimento, refugio y atención médica',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          BlocBuilder<DonacionBloc, DonacionState>(
            builder: (context, state) {
              if (state is! DonacionProcesando) {
                return const SizedBox.shrink();
              }
              return Material(
                color: Colors.black87,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Procesando...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Por favor no cierres la aplicación',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          decoration: TextDecoration.none,
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
    );
  }

  Future<void> _verificarTarjetasYContinuar(
    BuildContext context,
    double monto,
  ) async {
    final donacionState = context.read<DonacionBloc>().state;
    int? organizacionId;
    if (donacionState is DonacionLoaded &&
        donacionState.organizacionSeleccionada != null) {
      organizacionId = donacionState.organizacionSeleccionada!.id;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      context.read<DonacionBloc>().add(SeleccionarMonto(monto));
      context.push(
        '/agregar-tarjeta',
        extra: {'monto': monto, 'organizacionId': organizacionId},
      );
      return;
    }

    final tarjetaState = context.read<TarjetaBloc>().state;

    if (tarjetaState is! TarjetaLoaded) {
      context.read<TarjetaBloc>().add(CargarTarjetas());
      await Future.delayed(const Duration(milliseconds: 800));
    }

    final estadoTarjetas = context.read<TarjetaBloc>().state;

    if (estadoTarjetas is TarjetaLoaded) {
      final tarjetas = estadoTarjetas.tarjetas;
      final predeterminada = estadoTarjetas.tarjetaPredeterminada;

      if (tarjetas.isEmpty) {
        context.read<DonacionBloc>().add(SeleccionarMonto(monto));
        context.push(
          '/agregar-tarjeta',
          extra: {'monto': monto, 'organizacionId': organizacionId},
        );
      } else if (predeterminada != null) {
        _mostrarDialogoPagoRapido(
          context,
          monto,
          organizacionId,
          predeterminada,
        );
      } else {
        _mostrarDialogoElegirTarjeta(context, monto, organizacionId);
      }
    } else {
      context.read<DonacionBloc>().add(SeleccionarMonto(monto));
      context.push(
        '/agregar-tarjeta',
        extra: {'monto': monto, 'organizacionId': organizacionId},
      );
    }
  }

  void _procesarPagoDirecto(
    BuildContext context,
    double monto,
    int? organizacionId,
    Tarjeta tarjeta,
  ) {
    Navigator.pop(context);

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;

    context.read<DonacionBloc>().add(
      ProcesarPago(
        usuarioId: authState.data.usuarioIdPk,
        organizacionId: organizacionId ?? 0,
        monto: monto,
        tarjetaId: tarjeta.id,
      ),
    );
  }

  void _mostrarDialogoPagoRapido(
    BuildContext context,
    double monto,
    int? organizacionId,
    Tarjeta predeterminada,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const SizedBox(width: 12),
            Text(
              'Pago Rápido',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Se cobrará a tu tarjeta predeterminada:',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monto a donar:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '\$${monto.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Text(
                    predeterminada.numeroEnmascarado,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    predeterminada.titular,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => _procesarPagoDirecto(
              context,
              monto,
              organizacionId,
              predeterminada,
            ),
            child: const Text('Donar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push(
                '/seleccion-tarjeta',
                extra: {'monto': monto, 'organizacionId': organizacionId},
              );
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoElegirTarjeta(
    BuildContext context,
    double monto,
    int? organizacionId,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Tarjetas Guardadas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          '¿Cómo deseas pagar?',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push(
                '/seleccion-tarjeta',
                extra: {'monto': monto, 'organizacionId': organizacionId},
              );
            },
            child: const Text('Elegir guardada'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DonacionBloc>().add(SeleccionarMonto(monto));
              context.push(
                '/agregar-tarjeta',
                extra: {'monto': monto, 'organizacionId': organizacionId},
              );
            },
            child: const Text('Agregar nueva'),
          ),
        ],
      ),
    );
  }
}

class _MontoCard extends StatelessWidget {
  final double monto;
  final VoidCallback onTap;

  const _MontoCard({required this.monto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              '\$${monto.toInt()}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MontoPersonalizadoCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MontoPersonalizadoCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 28, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              'Otra Cantidad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
