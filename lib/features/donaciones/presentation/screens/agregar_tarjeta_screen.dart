import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../styles/constantes/app_color.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/tarjeta.dart';
import '../bloc/tarjeta/tarjeta_bloc.dart';
import '../bloc/tarjeta/tarjeta_event.dart';
import '../bloc/tarjeta/tarjeta_state.dart';

class AgregarTarjetaScreen extends StatefulWidget {
  final double? monto;
  final int? organizacionId;
  final Tarjeta? tarjeta;

  const AgregarTarjetaScreen({
    super.key,
    this.monto,
    this.organizacionId,
    this.tarjeta,
  });

  @override
  State<AgregarTarjetaScreen> createState() => _AgregarTarjetaScreenState();
}

class _AgregarTarjetaScreenState extends State<AgregarTarjetaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _titularController = TextEditingController();
  final _vencimientoController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _guardarTarjeta = true;
  bool _esPredeterminada = false;

  bool get _esModoEdicion => widget.tarjeta != null;

  @override
  void initState() {
    super.initState();
    // Si es modo edición, precargar los datos
    if (_esModoEdicion && widget.tarjeta != null) {
      _titularController.text = widget.tarjeta!.titular;
      _vencimientoController.text = widget.tarjeta!.fechaVencimiento;
      _esPredeterminada = widget.tarjeta!.esPredeterminada;
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _titularController.dispose();
    _vencimientoController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _procesar() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;

    final usuarioId = authState.data.usuarioIdPk;

    if (_esModoEdicion) {
      // MODO EDICIÓN: actualizar tarjeta existente
      context.read<TarjetaBloc>().add(
        ActualizarTarjeta(
          tarjetaId: widget.tarjeta!.id,
          titular: _titularController.text,
          fechaVencimiento: _vencimientoController.text,
          esPredeterminada: _esPredeterminada,
        ),
      );
    } else {
      // MODO AGREGAR: guardar nueva tarjeta
      if (_guardarTarjeta) {
        context.read<TarjetaBloc>().add(
          GuardarNuevaTarjeta(
            usuarioId: usuarioId,
            numeroTarjeta: _numeroController.text.replaceAll(' ', ''),
            titular: _titularController.text,
            fechaVencimiento: _vencimientoController.text,
            cvv: _cvvController.text,
            esPredeterminada: _esPredeterminada,
          ),
        );
      } else {
        // Procesar pago sin guardar
        context.push('/confirmacion-pago', extra: {
          'numeroTarjeta': _numeroController.text.replaceAll(' ', ''),
          'titular': _titularController.text,
          'fechaVencimiento': _vencimientoController.text,
          'cvv': _cvvController.text,
          'monto': widget.monto,
          'organizacionId': widget.organizacionId,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TarjetaBloc, TarjetaState>(
      listener: (context, state) {
        if (state is TarjetaGuardada) {
          if (widget.monto != null) {
            context.push('/confirmacion-pago', extra: {
              'tarjetaId': state.tarjeta.id,
              'monto': widget.monto,
              'organizacionId': widget.organizacionId,
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tarjeta guardada exitosamente')),
            );
            context.pop();
          }
        } else if (state is TarjetaEliminada) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarjeta actualizada exitosamente')),
          );
          context.pop();
        } else if (state is TarjetaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
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
          title: Text(
            _esModoEdicion ? 'Editar tarjeta' : 'Agregar tarjeta',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<TarjetaBloc, TarjetaState>(
          builder: (context, state) {
            final cargando = state is TarjetaLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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
                        child: Icon(
                          _esModoEdicion ? Icons.edit : Icons.credit_card,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      _esModoEdicion
                          ? 'Edita la información de tu tarjeta'
                          : 'Información de la tarjeta',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Número de tarjeta (solo en modo agregar)
                    if (!_esModoEdicion) ...[
                      const Text(
                        'Número de tarjeta',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _numeroController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final text = newValue.text.replaceAll(' ', '');
                            final buffer = StringBuffer();
                            for (int i = 0; i < text.length; i++) {
                              if (i > 0 && i % 4 == 0) buffer.write(' ');
                              buffer.write(text[i]);
                            }
                            return TextEditingValue(
                              text: buffer.toString(),
                              selection: TextSelection.collapsed(
                                offset: buffer.toString().length,
                              ),
                            );
                          }),
                        ],
                        decoration: InputDecoration(
                          hintText: '1234 5678 9012 3456',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.secondary.withValues(alpha: 0.3),
                          suffixIcon: Icon(Icons.credit_card, color: AppColors.primary),
                        ),
                        validator: (value) {
                          final limpio = value?.replaceAll(' ', '') ?? '';
                          if (limpio.isEmpty) return 'Ingresa el número de tarjeta';
                          if (limpio.length < 16) return 'El número debe tener 16 dígitos';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

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
                        obscureText: true,
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
                          suffixIcon: const Icon(Icons.lock, size: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa el CVV';
                          if (value.length < 3) return 'El CVV debe tener 3 dígitos';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Titular
                    const Text(
                      'Nombre del titular',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titularController,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Como aparece en la tarjeta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el nombre del titular';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fecha de vencimiento
                    const Text(
                      'Fecha de vencimiento',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _vencimientoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final text = newValue.text;
                          if (text.isEmpty) return newValue;
                          final cleanText = text.replaceAll('/', '');
                          if (cleanText.length <= 2) {
                            return TextEditingValue(
                              text: cleanText,
                              selection: TextSelection.collapsed(offset: cleanText.length),
                            );
                          }
                          final month = cleanText.substring(0, 2);
                          final year = cleanText.substring(2, cleanText.length > 4 ? 4 : cleanText.length);
                          return TextEditingValue(
                            text: '$month/$year',
                            selection: TextSelection.collapsed(offset: '$month/$year'.length),
                          );
                        }),
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
                        if (value == null || value.isEmpty) return 'Ingresa la fecha';
                        final regex = RegExp(r'^(0[1-9]|1[0-2])/\d{2}$');
                        if (!regex.hasMatch(value)) return 'Mes inválido (01-12)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Opciones de guardar/predeterminada (solo en modo agregar)
                    if (!_esModoEdicion) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
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
                            Row(
                              children: [
                                Icon(Icons.save, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Guardar tarjeta para futuras donaciones',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _guardarTarjeta,
                                  onChanged: (value) {
                                    setState(() {
                                      _guardarTarjeta = value;
                                      if (!value) _esPredeterminada = false;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                            if (_guardarTarjeta) ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Establecer como tarjeta predeterminada',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: _esPredeterminada,
                                    onChanged: (value) {
                                      setState(() => _esPredeterminada = value);
                                    },
                                    activeColor: AppColors.primary,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Switch de predeterminada en modo edición
                    if (_esModoEdicion) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Establecer como tarjeta predeterminada',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Switch(
                              value: _esPredeterminada,
                              onChanged: (value) {
                                setState(() => _esPredeterminada = value);
                              },
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Botón principal
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: cargando ? null : _procesar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _esModoEdicion
                                        ? 'Guardar cambios'
                                        : (widget.monto != null
                                            ? 'Pagar \$${widget.monto!.toStringAsFixed(2)}'
                                            : 'Guardar tarjeta'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield,
                          size: 16,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tu información está protegida con encriptación SSL',
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
            );
          },
        ),
      ),
    );
  }
}