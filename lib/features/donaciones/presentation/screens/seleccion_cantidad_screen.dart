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
import '../../domain/entities/tarjeta.dart';
import '../../data/services/procesar_pago_service.dart'; 

class SeleccionCantidadScreen extends StatefulWidget { 
  const SeleccionCantidadScreen({super.key});

  @override
  State<SeleccionCantidadScreen> createState() => _SeleccionCantidadScreenState();
}

class _SeleccionCantidadScreenState extends State<SeleccionCantidadScreen> {
  final _procesarPagoService = ProcesarPagoService();
  bool _procesando = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: _procesando ? null : () => context.pop(),
            ),
            title: const Text(
              'Tu ayuda puede \n salvar vidas',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<DonacionBloc, DonacionState>(
            builder: (context, state) {
              if (state is! DonacionLoaded || state.organizacionSeleccionada == null) {
                return const Center(child: Text('No hay organización seleccionada'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Apoyando a',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.organizacionSeleccionada!.nombre,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Selecciona un monto',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Elige una cantidad o ingresa una personalizada',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
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
                          onTap: () => _verificarTarjetasYContinuar(context, 5),
                        ),
                        _MontoCard(
                          monto: 15,
                          onTap: () => _verificarTarjetasYContinuar(context, 15),
                        ),
                        _MontoCard(
                          monto: 20,
                          onTap: () => _verificarTarjetasYContinuar(context, 20),
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
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tu donación ayuda a proporcionar alimento, refugio y atención médica',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
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
        
        if (_procesando)
          DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontFamily: 'Roboto',
            ),
            child: Container(
              color: Colors.black87, 
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Procesando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
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
            ),
          ),
      ],
    );
  }

  // FUNCIÓN GLOBAL DE VERIFICACIÓN DE TARJETAS
  Future<void> _verificarTarjetasYContinuar(
    BuildContext context,
    double monto,
  ) async {
    final donacionState = context.read<DonacionBloc>().state;
    int? organizacionId;
    if (donacionState is DonacionLoaded && donacionState.organizacionSeleccionada != null) {
      organizacionId = donacionState.organizacionSeleccionada!.id;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      context.read<DonacionBloc>().add(SeleccionarMonto(monto));
      context.push('/agregar-tarjeta', extra: {'monto': monto, 'organizacionId': organizacionId});
      return;
    }

    final usuarioId = authState.data.usuarioIdPk;
    final tarjetaState = context.read<TarjetaBloc>().state;
    
    if (tarjetaState is! TarjetaLoaded) {
      context.read<TarjetaBloc>().add(CargarTarjetas(usuarioId));
      await Future.delayed(const Duration(milliseconds: 800));
    }

    final estadoTarjetas = context.read<TarjetaBloc>().state;
    
    if (estadoTarjetas is TarjetaLoaded) {
      final tarjetas = estadoTarjetas.tarjetas;
      final predeterminada = estadoTarjetas.tarjetaPredeterminada;

      if (tarjetas.isEmpty) {
        context.read<DonacionBloc>().add(SeleccionarMonto(monto));
        context.push('/agregar-tarjeta', extra: {'monto': monto, 'organizacionId': organizacionId});
      } else if (predeterminada != null) {
        _mostrarDialogoPagoRapido(context, monto, organizacionId, predeterminada);
      } else {
        _mostrarDialogoElegirTarjeta(context, monto, organizacionId, tarjetas);
      }
    } else {
      context.read<DonacionBloc>().add(SeleccionarMonto(monto));
      context.push('/agregar-tarjeta', extra: {'monto': monto, 'organizacionId': organizacionId});
    }
  }

  Future<void> _procesarPagoDirecto(
    BuildContext context,
    double monto,
    int? organizacionId,
    Tarjeta tarjeta,
  ) async {
    Navigator.pop(context); // Cerrar el diálogo
    setState(() => _procesando = true);

    try {
      final exito = await _procesarPagoService.procesarPago(
        monto: monto,
        organizacionId: organizacionId ?? 0,
        numeroTarjeta: tarjeta.numeroEnmascarado,
        titular: tarjeta.titular,
        fechaVencimiento: tarjeta.fechaVencimiento,
      );

      if (!mounted) return;

      context.read<DonacionBloc>().add(SeleccionarMonto(monto));

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

  void _mostrarDialogoPagoRapido(
    BuildContext context,
    double monto,
    int? organizacionId,
    Tarjeta predeterminada,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !_procesando,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            SizedBox(width: 12),
            Text('Pago Rápido', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Se cobrará a tu tarjeta predeterminada:'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monto a donar:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '\$${monto.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Text(
                    predeterminada.numeroEnmascarado,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(predeterminada.titular, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: _procesando ? null : () => _procesarPagoDirecto(context, monto, organizacionId, predeterminada),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Donar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: _procesando ? null : () {
              Navigator.pop(dialogContext);
              context.push('/seleccion-tarjeta', extra: {'monto': monto, 'organizacionId': organizacionId});
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
    List<Tarjeta> tarjetas,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Tarjetas Guardadas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tienes ${tarjetas.length} tarjeta(s) guardada(s). ¿Cómo deseas pagar?'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push('/seleccion-tarjeta', extra: {
                'monto': monto,
                'organizacionId': organizacionId,
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Elegir guardada',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DonacionBloc>().add(SeleccionarMonto(monto));
              context.push('/agregar-tarjeta', extra: {
                'monto': monto,
                'organizacionId': organizacionId,
              });
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
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
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 28, color: AppColors.primary),
            SizedBox(height: 8),
            Text(
              'Otra Cantidad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}