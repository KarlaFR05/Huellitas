import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../styles/constantes/app_color.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/donacion_bloc.dart';
import '../bloc/donacion_event.dart';
import '../bloc/donacion_state.dart';
import '../bloc/tarjeta/tarjeta_bloc.dart';
import '../bloc/tarjeta/tarjeta_event.dart';
import '../bloc/tarjeta/tarjeta_state.dart';
import '../widgets/tarjeta_card.dart';
import '../../data/services/procesar_pago_service.dart';
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
  final _procesarPagoService = ProcesarPagoService();
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<TarjetaBloc>().add(CargarTarjetas(authState.data.usuarioIdPk));
    }
  }

  //Diálogo de confirmación antes de procesar
  void _mostrarConfirmacionPago(Tarjeta tarjeta) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.payment, color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Text(
              'Confirmar pago',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Deseas realizar el pago con esta tarjeta?'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarjeta.numeroEnmascarado,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tarjeta.titular,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monto a pagar:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${widget.monto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Sí, pagar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarPagoConTarjeta(Tarjeta tarjeta) async {
    setState(() => _procesando = true);

    try {
      final exito = await _procesarPagoService.procesarPago(
        monto: widget.monto,
        organizacionId: widget.organizacionId,
        numeroTarjeta: tarjeta.numeroEnmascarado,
        titular: tarjeta.titular,
        fechaVencimiento: tarjeta.fechaVencimiento,
      );

      if (!mounted) return;

      context.read<DonacionBloc>().add(SeleccionarMonto(widget.monto));

      if (exito) {
        context.go('/confirmacion-donacion');
      } else {
        context.go('/donacion-error');
      }
    } catch (e) {
      if (!mounted) return;
      context.go('/donacion-error');
    } finally {
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: _procesando ? null : () => context.pop(),
        ),
        title: const Text(
          'Selecciona una tarjeta',
          style: TextStyle(
            color: AppColors.textPrimary,
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
                    // Resumen de la donación
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Monto a donar:',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '\$${widget.monto.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (state.tarjetas.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
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
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Toca para seleccionar',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.tarjetas.length,
                          itemBuilder: (context, index) {
                            final tarjeta = state.tarjetas[index];
                            return Opacity(
                              opacity: _procesando ? 0.5 : 1.0,
                              child: TarjetaCard(
                                tarjeta: tarjeta,
                                // ✅ CAMBIO: Ahora llama al diálogo de confirmación
                                onTap: _procesando
                                    ? () {}
                                    : () => _mostrarConfirmacionPago(tarjeta),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No tienes tarjetas guardadas',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _procesando
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
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
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthSuccess) {
                            context.read<TarjetaBloc>().add(
                              CargarTarjetas(authState.data.usuarioIdPk),
                            );
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

          // Overlay de procesamiento
          if (_procesando)
            Container(
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Por favor no cierres la app',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}