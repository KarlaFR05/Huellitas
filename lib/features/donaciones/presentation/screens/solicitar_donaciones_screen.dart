import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/solicitud_donacion.dart';

class SolicitarDonacionesScreen extends StatefulWidget {
  const SolicitarDonacionesScreen({
    super.key,
    required this.reporteId,
  });

  final int reporteId;

  @override
  State<SolicitarDonacionesScreen> createState() =>
      _SolicitarDonacionesScreenState();
}

class _SolicitarDonacionesScreenState
    extends State<SolicitarDonacionesScreen> {
  final _formKey = GlobalKey<FormState>();

  final _metaController = TextEditingController();
  final _descripcionController = TextEditingController();

  final List<_GastoForm> _gastos = [];

  @override
  void initState() {
    super.initState();

    final solicitud =
        SolicitudesDonacionStore.obtener(widget.reporteId);

    if (solicitud != null) {
      _metaController.text = solicitud.meta.toStringAsFixed(2);
      _descripcionController.text = solicitud.descripcion;

      _gastos.addAll(
        solicitud.gastos.map(_GastoForm.desdeGasto),
      );
    } else {
      _gastos.add(_GastoForm());
    }
  }

  @override
  void dispose() {
    _metaController.dispose();
    _descripcionController.dispose();

    for (final gasto in _gastos) {
      gasto.dispose();
    }

    super.dispose();
  }

  Future<void> _elegirEvidencia(_GastoForm gasto) async {
    final imagen = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (imagen != null && mounted) {
      setState(() {
        gasto.evidencia = File(imagen.path);
      });
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_gastos.any((gasto) => gasto.evidencia == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Adjunta el ticket o recibo de cada gasto',
          ),
        ),
      );
      return;
    }

    final gastos = _gastos
        .map(
          (gasto) => GastoRescate(
            descripcion: gasto.descripcion.text.trim(),
            monto: double.parse(gasto.monto.text.trim()),
            evidencia: gasto.evidencia,
          ),
        )
        .toList();

    final totalDonadoActual =
        SolicitudesDonacionStore.obtener(widget.reporteId)?.totalDonado ?? 0;
    SolicitudesDonacionStore.guardar(
      widget.reporteId,
      SolicitudDonacion(
        meta: double.parse(_metaController.text.trim()),
        descripcion: _descripcionController.text.trim(),
        gastos: gastos,
        totalDonado: totalDonadoActual,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitud de donaciones publicada'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar donaciones'),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: FilledButton(
          onPressed: _guardar,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Publicar / Actualizar meta'),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '1. Establecer meta',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _metaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Meta de donación (MXN)',
                border: OutlineInputBorder(),
              ),
              validator: _montoValido,
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(
                      alpha: 0.2,
                    ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'El monto total de la meta debe coincidir con los tickets o recibos adjuntos. Esta información será verificada por un administrador.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Justifica la meta solicitada',
                border: OutlineInputBorder(),
              ),
              validator: _requerido,
            ),

            const SizedBox(height: 28),

            Text(
              '2. Gastos y evidencia',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Registra cada gasto realizado y adjunta su ticket o recibo.',
            ),

            ..._gastos.asMap().entries.map(
                  (entrada) => _gastoCard(
                    entrada.key,
                    entrada.value,
                    color,
                  ),
                ),

            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _gastos.add(_GastoForm());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo gasto'),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _gastoCard(
    int indice,
    _GastoForm gasto,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        top: 16,
        bottom: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Gasto ${indice + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                if (_gastos.length > 1)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        gasto.dispose();
                        _gastos.removeAt(indice);
                      });
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                  ),
              ],
            ),

            TextFormField(
              controller: gasto.descripcion,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej. Alimento',
                border: OutlineInputBorder(),
              ),
              validator: _requerido,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: gasto.monto,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Monto (MXN)',
                border: OutlineInputBorder(),
              ),
              validator: _montoValido,
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => _elegirEvidencia(gasto),
              icon: Icon(
                gasto.evidencia == null
                    ? Icons.receipt_long_outlined
                    : Icons.edit,
                color: color,
              ),
              label: Text(
                gasto.evidencia == null
                    ? 'Adjuntar ticket / recibo'
                    : 'Cambiar ticket / recibo',
              ),
            ),

            if (gasto.evidencia != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    gasto.evidencia!,
                    height: 130,
                    width: 130,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    return null;
  }

  String? _montoValido(String? value) {
    final monto = double.tryParse(value?.trim() ?? '');

    if (monto == null || monto <= 0) {
      return 'Ingresa un monto válido';
    }

    return null;
  }
}

class _GastoForm {
  _GastoForm()
      : descripcion = TextEditingController(),
        monto = TextEditingController();

  _GastoForm.desdeGasto(GastoRescate gasto)
      : descripcion = TextEditingController(
          text: gasto.descripcion,
        ),
        monto = TextEditingController(
          text: gasto.monto.toStringAsFixed(2),
        ),
        evidencia = gasto.evidencia;

  final TextEditingController descripcion;
  final TextEditingController monto;

  File? evidencia;

  void dispose() {
    descripcion.dispose();
    monto.dispose();
  }
}
