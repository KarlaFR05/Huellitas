import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../styles/constantes/app_color.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/donacion_bloc.dart';
import '../bloc/donacion_event.dart';
import '../bloc/donacion_state.dart';

class MetodoPagoScreen extends StatefulWidget {
  const MetodoPagoScreen({super.key});

  @override
  State<MetodoPagoScreen> createState() => _MetodoPagoScreenState();
}

class _MetodoPagoScreenState extends State<MetodoPagoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroTarjetaController = TextEditingController();
  final _titularController = TextEditingController();
  final _cvvController = TextEditingController();
  final _fechaVencimientoController = TextEditingController();

  @override
  void dispose() {
    _numeroTarjetaController.dispose();
    _titularController.dispose();
    _cvvController.dispose();
    _fechaVencimientoController.dispose();
    super.dispose();
  }

  void _procesarPago() {
    if (_formKey.currentState!.validate()) {
      final state = context.read<DonacionBloc>().state;
      if (state is DonacionLoaded && state.organizacionSeleccionada != null && state.montoSeleccionado != null) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthSuccess) {
          context.read<DonacionBloc>().add(
            ProcesarPago(
              usuarioId: authState.data.usuarioIdPk,
              organizacionId: state.organizacionSeleccionada!.id,
              monto: state.montoSeleccionado!,
              numeroTarjeta: _numeroTarjetaController.text,
              titularTarjeta: _titularController.text,
              cvv: _cvvController.text,
              fechaVencimiento: _fechaVencimientoController.text,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DonacionBloc, DonacionState>(
      listener: (context, state) {
        if (state is DonacionCompletada) {
          context.go('/confirmacion-donacion');
        } else if (state is DonacionError) {
          context.go('/donacion-error');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Metodo de pago',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<DonacionBloc, DonacionState>(
          builder: (context, state) {
            if (state is DonacionProcesando) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Número De Tarjeta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _numeroTarjetaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Ingresa los 16 numeros de tu tarjeta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el número de tarjeta';
                        }
                        if (value.length < 16) {
                          return 'El número debe tener 16 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Titular De La Tarjeta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titularController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]*')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Nombre como aparece en la tarjeta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el nombre del titular';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CVV',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                decoration: InputDecoration(
                                  hintText: '123',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.secondary.withValues(alpha: 0.3),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa el CVV';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fecha De Vencimiento',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _fechaVencimientoController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}/?\d{0,2}$')),
                                  LengthLimitingTextInputFormatter(5),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'MM/AA',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.secondary.withValues(alpha: 0.3),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa la fecha';
                                  }
                                  final regex = RegExp(r'^(0[1-9]|1[0-2])/\d{2}$');
                                  if (!regex.hasMatch(value)) {
                                    return 'Mes inválido (01-12)';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _procesarPago,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Donar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}