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
import '../widgets/tarjeta_card.dart';
import '../../domain/entities/tarjeta.dart';

class SeleccionTarjetaScreen extends StatefulWidget {
  final double monto;
  final int organizacionId;

  const SeleccionTarjetaScreen({
    super.key,
    required this.monto,
    required this.organizacionId,
  });

  @override
  State<SeleccionTarjetaScreen> createState() => _SeleccionTarjetaScreenState();
}

class _SeleccionTarjetaScreenState extends State<SeleccionTarjetaScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<TarjetaBloc>().add(CargarTarjetas());
    }
  }

  void _mostrarConfirmacionPago(Tarjeta tarjeta) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.payment, color: colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              'Confirmar pago',
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
              '¿Deseas realizar el pago con esta tarjeta?',
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
                  Text(
                    tarjeta.numeroEnmascarado,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tarjeta.titular,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monto a pagar:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '\$${widget.monto.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _procesarPagoConTarjeta(tarjeta);
            },
            child: const Text('Sí, pagar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _procesarPagoConTarjeta(Tarjeta tarjeta) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para donar')),
      );
      return;
    }

    context.read<DonacionBloc>().add(ProcesarPago(
      usuarioId: authState.data.usuarioIdPk,
      organizacionId: widget.organizacionId,
      monto: widget.monto,
      tarjetaId: tarjeta.id,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<DonacionBloc, DonacionState>(
      listener: (context, state) {
        if (state is DonacionProcesando) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        } else if (state is DonacionCompletada) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          context.go('/confirmacion-donacion');
        } else if (state is DonacionError) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Selecciona una tarjeta',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            BlocBuilder<TarjetaBloc, TarjetaState>(
              builder: (context, state) {
                if (state is TarjetaLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TarjetaLoaded) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Monto a donar:',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '\$${widget.monto.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (state.tarjetas.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tus tarjetas guardadas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Toca para seleccionar',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        BlocBuilder<DonacionBloc, DonacionState>(
                          builder: (context, donacionState) {
                            final procesando = donacionState is DonacionProcesando;
                            return Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: state.tarjetas.length,
                                itemBuilder: (context, index) {
                                  final tarjeta = state.tarjetas[index];
                                  return Opacity(
                                    opacity: procesando ? 0.5 : 1.0,
                                    child: TarjetaCard(
                                      tarjeta: tarjeta,
                                      onTap: procesando
                                          ? () {}
                                          : () => _mostrarConfirmacionPago(tarjeta),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  size: 64,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tienes tarjetas guardadas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: BlocBuilder<DonacionBloc, DonacionState>(
                          builder: (context, donacionState) {
                            final procesando = donacionState is DonacionProcesando;
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: procesando
                                    ? null
                                    : () => context.push('/agregar-tarjeta', extra: {
                                          'monto': widget.monto,
                                          'organizacionId': widget.organizacionId,
                                        }),
                                icon: const Icon(Icons.add, size: 24),
                                label: const Text(
                                  'Agregar nueva tarjeta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                if (state is TarjetaError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthSuccess) {
                              context.read<TarjetaBloc>().add(CargarTarjetas());
                            }
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            BlocBuilder<DonacionBloc, DonacionState>(
              builder: (context, state) {
                if (state is! DonacionProcesando) {
                  return const SizedBox.shrink();
                }
                return Material(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 24),
                        Text(
                          'Procesando pago...',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Por favor no cierres la app',
                          style: TextStyle(
                            color: Colors.white70,
                            decoration: TextDecoration.none,
                            fontSize: 14,
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
    );
  }
}