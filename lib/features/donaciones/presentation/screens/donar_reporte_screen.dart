import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/tarjeta/tarjeta_bloc.dart';
import '../bloc/tarjeta/tarjeta_event.dart';
import '../bloc/tarjeta/tarjeta_state.dart';
import '../models/solicitud_donacion.dart';

class DonarReporteScreen extends StatefulWidget {
  const DonarReporteScreen({
    super.key,
    required this.reporteId,
  });

  final int reporteId;

  @override
  State<DonarReporteScreen> createState() => _DonarReporteScreenState();
}

class _DonarReporteScreenState extends State<DonarReporteScreen> {
  final _monto = TextEditingController();

  @override
  void initState() {
    super.initState();

    context.read<TarjetaBloc>().add(CargarTarjetas());
  }

  @override
  void dispose() {
    _monto.dispose();
    super.dispose();
  }

  void _donar(double monto) {
    if (monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un monto válido'),
        ),
      );
      return;
    }

    final state = context.read<TarjetaBloc>().state;

    if (state is TarjetaLoaded && state.tarjetas.isNotEmpty) {
      showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¿Cómo deseas pagar?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...state.tarjetas.map(
                    (tarjeta) => ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: Text(tarjeta.numeroEnmascarado),
                      subtitle: Text(tarjeta.titular),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _confirmar(monto);
                      },
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.add_card),
                    title: const Text('Agregar otra tarjeta'),
                    onTap: () {
                      Navigator.pop(sheetContext);

                      context.push(
                        '/agregar-tarjeta',
                        extra: {
                          'monto': monto,
                          'organizacionId': 0,
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );

      return;
    }

    context.push(
      '/agregar-tarjeta',
      extra: {
        'monto': monto,
        'organizacionId': 0,
      },
    );
  }

  void _confirmar(double monto) {
    SolicitudesDonacionStore.registrarDonacion(
      widget.reporteId,
      monto,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Gracias por tu donación al rescate!'),
      ),
    );

    context.pop();
  }

  void _mostrarMontoPersonalizado() {
    _monto.clear();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Monto personalizado'),
          content: TextField(
            controller: _monto,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Monto a donar',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),

            FilledButton(
              onPressed: () {
                final monto =
                    double.tryParse(_monto.text.trim()) ?? 0;

                Navigator.pop(dialogContext);

                _donar(monto);
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final solicitud =
        SolicitudesDonacionStore.obtener(widget.reporteId);

    final colorScheme = Theme.of(context).colorScheme;

    if (solicitud == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Donar al rescate'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Este rescate no tiene una solicitud de donaciones.',
          ),
        ),
      );
    }

    final faltante = (solicitud.meta - solicitud.totalDonado)
        .clamp(0, solicitud.meta)
        .toDouble();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.primary,
          ),
          onPressed: () => context.pop(),
        ),

        title: Text(
          'Tu ayuda puede\nsalvar vidas',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
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
                      Icons.volunteer_activism,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Apoyando un rescate',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Meta: \$${solicitud.meta.toStringAsFixed(2)} MXN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Faltan \$${faltante.toStringAsFixed(2)} '
                    'para completar la meta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
                  onTap: () => _donar(5),
                ),

                _MontoCard(
                  monto: 15,
                  onTap: () => _donar(15),
                ),

                _MontoCard(
                  monto: 20,
                  onTap: () => _donar(20),
                ),

                _MontoPersonalizadoCard(
                  onTap: _mostrarMontoPersonalizado,
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(
                  alpha: 0.2,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(
                    alpha: 0.2,
                  ),
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
                      'Tu donación se destinará exclusivamente '
                      'a los gastos de este rescate.',
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
      ),
    );
  }
}

class _MontoCard extends StatelessWidget {
  const _MontoCard({
    required this.monto,
    required this.onTap,
  });

  final double monto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primary.withValues(
        alpha: 0.1,
      ),
      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${monto.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),

            Text(
              'MXN',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MontoPersonalizadoCard extends StatelessWidget {
  const _MontoPersonalizadoCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),

        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary,
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_outlined,
                color: colorScheme.primary,
              ),

              const SizedBox(height: 8),

              Text(
                'Otro monto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
