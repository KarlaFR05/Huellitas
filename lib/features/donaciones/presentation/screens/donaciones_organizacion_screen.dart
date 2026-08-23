import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../home/presentation/widgets/bottom_bar.dart';

class DonacionesOrganizacionScreen extends StatefulWidget {
  const DonacionesOrganizacionScreen({super.key});

  @override
  State<DonacionesOrganizacionScreen> createState() =>
      _DonacionesOrganizacionScreenState();
}

class _DonacionesOrganizacionScreenState
    extends State<DonacionesOrganizacionScreen> {
  // MOCK
  double _metaMensual = 20000;
  double _recaudadoMensual = 15850;

  // editar la meta 
  bool _editandoMeta = false;
  final TextEditingController _metaController = TextEditingController();

  @override
  void dispose() {
    _metaController.dispose();
    super.dispose();
  }
  void _iniciarEdicion() {
    _metaController.text = _metaMensual.toStringAsFixed(0);
    setState(() => _editandoMeta = true);
  }

    void _guardarMeta() {
    final valor = double.tryParse(_metaController.text);
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una meta válida mayor a 0')),
      );
      return;
    }
    
    setState(() {
      _metaMensual = valor;
      _editandoMeta = false;
    });

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 45,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¡Meta actualizada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tu meta mensual se actualizó correctamente a \$${valor.toStringAsFixed(2)}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cancelarEdicion() {
    setState(() => _editandoMeta = false);
  }

  final List<_DonacionRecibida> _donacionesRecibidas = const [
    _DonacionRecibida(nombre: 'María García', fecha: '15 ago 2026', monto: 15),
    _DonacionRecibida(nombre: 'Juan Pérez', fecha: '14 ago 2026', monto: 15),
    _DonacionRecibida(nombre: 'Ana López', fecha: '12 ago 2026', monto: 20),
    _DonacionRecibida(nombre: 'Carlos Ruiz', fecha: '10 ago 2026', monto: 500),
    _DonacionRecibida(nombre: 'Lucía Hernández', fecha: '08 ago 2026', monto: 5),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avance = _metaMensual > 0
        ? (_recaudadoMensual / _metaMensual).clamp(0.0, 1.0)
        : 0.0;
    final porcentaje = (avance * 100).toStringAsFixed(0);
    final faltante = _metaMensual - _recaudadoMensual;
    final metaAlcanzada = faltante <= 0;

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.surface,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            BottomBarWidget.contentClearance(context) + 16,
          ),
          children: [
            // ===== HEADER =====
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.volunteer_activism,
                    color: colors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Donaciones',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // META MENSUAL Y PROGRESO  
            Container(
              key: ValueKey('meta-$_metaMensual-$_editandoMeta'),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: .45),
                ),
              ),
              child: Column(
                children: [
                  if (_editandoMeta) ...[
                    TextField(
                      controller: _metaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                      decoration: InputDecoration(
                        prefixText: r'$ ',
                        labelText: 'Nueva meta mensual',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _cancelarEdicion,
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _guardarMeta,
                            child: const Text('Guardar'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$${_recaudadoMensual.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Editar meta mensual',
                          onPressed: _iniciarEdicion,
                          icon: Icon(
                            Icons.edit_outlined,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'de \$${_metaMensual.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: avance,
                      minHeight: 10,
                      backgroundColor: colors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        metaAlcanzada ? Colors.green : colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Porcentaje
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: metaAlcanzada
                              ? Colors.green.withValues(alpha: 0.1)
                              : colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              metaAlcanzada
                                  ? Icons.check_circle_outline
                                  : Icons.trending_up,
                              size: 14,
                              color: metaAlcanzada
                                  ? Colors.green
                                  : colors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$porcentaje% completado',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: metaAlcanzada
                                    ? Colors.green
                                    : colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Faltante o mensaje de meta alcanzada
                      if (metaAlcanzada)
                        Text(
                          '¡Meta alcanzada!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        )
                      else
                        Text(
                          'Faltan \$${faltante.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Text(
                    'META DEL MES DE DONACIONES',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // HISTORIAL DE DONACIONES RECIBIDAS
            Text(
              'Donaciones recibidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            if (_donacionesRecibidas.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: Text('Aún no has recibido donaciones.')),
              )
            else
              for (final donacion in _donacionesRecibidas)
                _DonacionRecibidaCard(donacion: donacion),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBarWidget(currentIndex: 2),
    );
  }
}

class _DonacionRecibida {
  final String nombre;
  final String fecha;
  final double monto;

  const _DonacionRecibida({
    required this.nombre,
    required this.fecha,
    required this.monto,
  });
}

class _DonacionRecibidaCard extends StatelessWidget {
  final _DonacionRecibida donacion;

  const _DonacionRecibidaCard({super.key, required this.donacion});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .45),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.primaryContainer,
            child: Icon(Icons.person_rounded, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donacion.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  donacion.fecha,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${donacion.monto.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'completada',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}