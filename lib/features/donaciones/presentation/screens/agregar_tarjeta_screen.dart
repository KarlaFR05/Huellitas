import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/tarjeta.dart';
import '../bloc/tarjeta/tarjeta_bloc.dart';
import '../bloc/tarjeta/tarjeta_event.dart';
import '../bloc/tarjeta/tarjeta_state.dart';
import '../bloc/donacion_bloc.dart';
import '../bloc/donacion_event.dart';
import '../bloc/donacion_state.dart';

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

  bool _tarjetaTemporal = false;
  int? _tarjetaTemporalId;

  bool get _esModoEdicion => widget.tarjeta != null;
  bool get _esFlujoDonacion =>
      widget.monto != null && widget.organizacionId != null;

  @override
  void initState() {
    super.initState();
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
      context.read<TarjetaBloc>().add(
            ActualizarTarjeta(
              tarjetaId: widget.tarjeta!.id,
              titular: _titularController.text,
              fechaVencimiento: _vencimientoController.text,
              esPredeterminada: _esPredeterminada,
            ),
          );
      return;
    }

    final esTemporal = _esFlujoDonacion && !_guardarTarjeta;
    if (esTemporal) {
      setState(() => _tarjetaTemporal = true);
    }

    context.read<TarjetaBloc>().add(
          GuardarNuevaTarjeta(
            usuarioId: usuarioId,
            numeroTarjeta: _numeroController.text.replaceAll(' ', ''),
            titular: _titularController.text,
            fechaVencimiento: _vencimientoController.text,
            cvv: _cvvController.text,
            esPredeterminada: esTemporal ? false : _esPredeterminada,
          ),
        );
  }

  void _limpiarTarjetaTemporal() {
    if (_tarjetaTemporal && _tarjetaTemporalId != null) {
      context.read<TarjetaBloc>().add(EliminarTarjeta(_tarjetaTemporalId!));
      _tarjetaTemporalId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<TarjetaBloc, TarjetaState>(
          listener: (context, state) {
            if (state is TarjetaGuardada) {
              final tarjetaGuardada = state.tarjeta;

              if (_esFlujoDonacion) {
                if (_tarjetaTemporal) {
                  _tarjetaTemporalId = tarjetaGuardada.id;
                }

                final authState = context.read<AuthBloc>().state;
                if (authState is AuthSuccess) {
                  context.read<DonacionBloc>().add(
                        ProcesarPago(
                          usuarioId: authState.data.usuarioIdPk,
                          organizacionId: widget.organizacionId!,
                          monto: widget.monto!,
                          tarjetaId: tarjetaGuardada.id,
                        ),
                      );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tarjeta guardada exitosamente')),
                );
                context.pop();
              }
            } else if (state is TarjetaActualizada) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: colorScheme.primary, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        '¡Actualizado!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'La tarjeta se ha actualizado correctamente.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              );
            } else if (state is TarjetaError) {
              setState(() {
                _tarjetaTemporal = false;
                _tarjetaTemporalId = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
        ),

        BlocListener<DonacionBloc, DonacionState>(
          listener: (context, state) {
            if (state is DonacionCompletada) {
              _limpiarTarjetaTemporal();
              context.go('/confirmacion-donacion');
            } else if (state is DonacionError) {
              _limpiarTarjetaTemporal();
              setState(() => _tarjetaTemporal = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              leading: BlocBuilder<DonacionBloc, DonacionState>(
                builder: (context, state) {
                  final procesando =
                      state is DonacionProcesando || _tarjetaTemporal;
                  return IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                    onPressed: procesando ? null : () => context.pop(),
                  );
                },
              ),
              title: Text(
                _esModoEdicion ? 'Editar tarjeta' : 'Agregar tarjeta',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: BlocBuilder<DonacionBloc, DonacionState>(
              builder: (context, state) {
                final procesando =
                    state is DonacionProcesando || _tarjetaTemporal;

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
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _esModoEdicion ? Icons.edit : Icons.credit_card,
                              size: 48,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          _esModoEdicion
                              ? 'Edita la información de tu tarjeta'
                              : 'Información de la tarjeta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (!_esModoEdicion) ...[
                          Text(
                            'Número de tarjeta',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _numeroController,
                            enabled: !procesando,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(16),
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                final text =
                                    newValue.text.replaceAll(' ', '');
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
                              suffixIcon: Icon(Icons.credit_card,
                                  color: colorScheme.primary),
                            ),
                            validator: (value) {
                              final limpio = value?.replaceAll(' ', '') ?? '';
                              if (limpio.isEmpty) {
                                return 'Ingresa el número de tarjeta';
                              }
                              if (limpio.length < 16) {
                                return 'El número debe tener 16 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'CVV',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _cvvController,
                            enabled: !procesando,
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
                              suffixIcon: Icon(Icons.lock,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa el CVV';
                              }
                              if (value.length < 3) {
                                return 'El CVV debe tener 3 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        Text(
                          'Nombre del titular',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titularController,
                          enabled: !procesando,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]')),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Como aparece en la tarjeta',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa el nombre del titular';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Fecha de vencimiento',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _vencimientoController,
                          enabled: !procesando,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              final text = newValue.text;
                              if (text.isEmpty) return newValue;
                              final cleanText = text.replaceAll('/', '');
                              if (cleanText.length <= 2) {
                                return TextEditingValue(
                                  text: cleanText,
                                  selection: TextSelection.collapsed(
                                      offset: cleanText.length),
                                );
                              }
                              final month = cleanText.substring(0, 2);
                              final year = cleanText.substring(
                                  2, cleanText.length > 4 ? 4 : cleanText.length);
                              return TextEditingValue(
                                text: '$month/$year',
                                selection: TextSelection.collapsed(
                                    offset: '$month/$year'.length),
                              );
                            }),
                          ],
                          decoration: InputDecoration(
                            hintText: 'MM/AA',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
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
                        const SizedBox(height: 24),

                        if (!_esModoEdicion && _esFlujoDonacion) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
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
                                  children: [
                                    Icon(Icons.save,
                                        color: colorScheme.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Guardar tarjeta para futuras donaciones',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: _guardarTarjeta,
                                      onChanged: procesando
                                          ? null
                                          : (value) {
                                              setState(() {
                                                _guardarTarjeta = value;
                                                if (!value) {
                                                  _esPredeterminada = false;
                                                }
                                              });
                                            },
                                      activeColor: colorScheme.primary,
                                    ),
                                  ],
                                ),
                                if (_guardarTarjeta) ...[
                                  const SizedBox(height: 12),
                                  Divider(color: colorScheme.outlineVariant),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: colorScheme.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Establecer como tarjeta predeterminada',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: _esPredeterminada,
                                        onChanged: procesando
                                            ? null
                                            : (value) {
                                                setState(() =>
                                                    _esPredeterminada = value);
                                              },
                                        activeColor: colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        if (!_esModoEdicion && !_esFlujoDonacion) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star,
                                    color: colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Establecer como tarjeta predeterminada',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _esPredeterminada,
                                  onChanged: procesando
                                      ? null
                                      : (value) {
                                          setState(
                                              () => _esPredeterminada = value);
                                        },
                                  activeColor: colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (_esModoEdicion) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star,
                                    color: colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Establecer como tarjeta predeterminada',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _esPredeterminada,
                                  onChanged: procesando
                                      ? null
                                      : (value) {
                                          setState(
                                              () => _esPredeterminada = value);
                                        },
                                  activeColor: colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: procesando ? null : _procesar,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: procesando
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    _esModoEdicion
                                        ? 'Guardar cambios'
                                        : (_esFlujoDonacion
                                            ? 'Pagar \$${widget.monto!.toStringAsFixed(2)}'
                                            : 'Guardar tarjeta'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
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
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tu información está protegida con encriptación SSL',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
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

          BlocBuilder<DonacionBloc, DonacionState>(
            builder: (context, state) {
              final procesando =
                  state is DonacionProcesando || _tarjetaTemporal;
              if (!procesando) return const SizedBox.shrink();
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