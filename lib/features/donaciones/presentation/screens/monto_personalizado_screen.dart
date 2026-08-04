import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class MontoPersonalizadoScreen extends StatefulWidget {
  const MontoPersonalizadoScreen({super.key});

  @override
  State<MontoPersonalizadoScreen> createState() => _MontoPersonalizadoScreenState();
}

class _MontoPersonalizadoScreenState extends State<MontoPersonalizadoScreen> {
  final TextEditingController _montoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();

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
        context.push('/agregar-tarjeta', extra: {'monto': monto, 'organizacionId': organizacionId});
      } else if (predeterminada != null) {
        _mostrarDialogoPagoRapido(monto, organizacionId, predeterminada);
      } else {
        _mostrarDialogoElegirTarjeta(monto, organizacionId);
      }
    } else {
      context.read<DonacionBloc>().add(SeleccionarMonto(monto));
      context.push('/agregar-tarjeta', extra: {'monto': monto, 'organizacionId': organizacionId});
    }
  }

  void _procesarPagoDirecto(double monto, int? organizacionId, Tarjeta tarjeta) {
    Navigator.pop(context);

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;

    context.read<DonacionBloc>().add(ProcesarPago(
      usuarioId: authState.data.usuarioIdPk,
      organizacionId: organizacionId ?? 0,
      monto: monto,
      tarjetaId: tarjeta.id,
    ));
  }

  void _mostrarDialogoPagoRapido(double monto, int? organizacionId, Tarjeta predeterminada) {
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
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
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
            onPressed: () => _procesarPagoDirecto(monto, organizacionId, predeterminada),
            child: const Text('Donar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push('/seleccion-tarjeta', extra: {'monto': monto, 'organizacionId': organizacionId});
            },
            child: const Text('Cambiar'),
          ),          
        ],
      ),
    );
  }

  void _mostrarDialogoElegirTarjeta(double monto, int? organizacionId) {
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
              context.push('/seleccion-tarjeta', extra: {'monto': monto, 'organizacionId': organizacionId});
            },
            child: const Text('Elegir guardada'),
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
                'Tu ayuda puede salvar vidas',
                style: TextStyle(
                  color: colorScheme.onSurface,
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
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.volunteer_activism,
                          size: 60,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ingresa el monto',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cualquier cantidad ayuda',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    BlocBuilder<DonacionBloc, DonacionState>(
                      builder: (context, state) {
                        final procesando = state is DonacionProcesando;
                        return Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.onSurface.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _montoController,
                            focusNode: _focusNode,
                            enabled: !procesando,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 40,
                                horizontal: 20,
                              ),
                              hintText: '0.00',
                              prefixText: '\$ ',
                              prefixStyle: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
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
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    BlocBuilder<DonacionBloc, DonacionState>(
                      builder: (context, state) {
                        final procesando = state is DonacionProcesando;
                        return SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: procesando ? null : _mostrarConfirmacion,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              procesando ? 'Procesando...' : 'Continuar',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pago seguro',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
}