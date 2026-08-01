import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class MontoPersonalizadoScreen extends StatefulWidget {
  const MontoPersonalizadoScreen({super.key});

  @override
  State<MontoPersonalizadoScreen> createState() => _MontoPersonalizadoScreenState();
}

class _MontoPersonalizadoScreenState extends State<MontoPersonalizadoScreen> {
  final TextEditingController _montoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  final _procesarPagoService = ProcesarPagoService();
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _montoController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _mostrarConfirmacion() {
    if (_formKey.currentState!.validate()) {
      final monto = double.tryParse(_montoController.text) ?? 0;
      if (monto > 0) {
        _verificarTarjetasYContinuar(monto);
      }
    }
  }

  Future<void> _verificarTarjetasYContinuar(double monto) async {
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
        _mostrarDialogoPagoRapido(monto, organizacionId, predeterminada);
      } else {
        _mostrarDialogoElegirTarjeta(monto, organizacionId, tarjetas);
      }
    } else {
      context.read<DonacionBloc>().add(SeleccionarMonto(monto));
      context.push('/agregar-tarjeta', extra: {'monto': monto, 'organizacionId': organizacionId});
    }
  }

  
  Future<void> _procesarPagoDirecto(double monto, int? organizacionId, Tarjeta tarjeta) async {
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

  void _mostrarDialogoPagoRapido(double monto, int? organizacionId, Tarjeta predeterminada) {
    showDialog(
      context: context,
      barrierDismissible: !_procesando, // No permitir cerrar si se está procesando
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
            onPressed: _procesando ? null : () => _procesarPagoDirecto(monto, organizacionId, predeterminada),
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

  void _mostrarDialogoElegirTarjeta(double monto, int? organizacionId, List<Tarjeta> tarjetas) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tarjetas Guardadas', style: TextStyle(fontWeight: FontWeight.bold)),
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
              context.push('/seleccion-tarjeta', extra: {'monto': monto, 'organizacionId': organizacionId});
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Elegir guardada', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DonacionBloc>().add(SeleccionarMonto(monto));
              context.push('/agregar-tarjeta', extra: {'monto': monto, 'organizacionId': organizacionId});
            },
            child: const Text('Agregar nueva'),
          ),
        ],
      ),
    );
  }

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
              'Tu ayuda puede salvar vidas',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volunteer_activism,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ingresa el monto',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cualquier cantidad ayuda',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _montoController,
                      focusNode: _focusNode,
                      enabled: !_procesando,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        hintText: '0.00',
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa un monto';
                        }
                        final monto = double.tryParse(value);
                        if (monto == null || monto <= 0) {
                          return 'Ingresa un monto válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _procesando ? null : _mostrarConfirmacion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 12),
                          Text(
                            'Continuar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.security,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pago seguro',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        //Overlay de procesamiento
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
}