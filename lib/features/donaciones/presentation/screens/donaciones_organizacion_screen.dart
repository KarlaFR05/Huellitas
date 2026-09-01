import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../foro/data/datasources/organizacion_foro_datasource.dart';
import '../../../foro/data/repositories/organizacion_foro_repository_impl.dart';
import '../../../foro/domain/entities/organizacion_foro.dart';
import '../../data/datasources/donacion_organizacion_remote_datasource.dart';
import '../../data/repositories/donacion_organizacion_repository_impl.dart';
import '../../domain/entities/donacion_recibida_entity.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';

class DonacionesOrganizacionScreen extends StatefulWidget {
  const DonacionesOrganizacionScreen({super.key});

  @override
  State<DonacionesOrganizacionScreen> createState() =>
      _DonacionesOrganizacionScreenState();
}

class _DonacionesOrganizacionScreenState
    extends State<DonacionesOrganizacionScreen> {
  
  double _metaMensual = 0;
  double _recaudadoMensual = 0;
  int? _organizacionId;
  List<DonacionRecibidaEntity> _donaciones = [];
  bool _cargandoInicial = true;

  bool _editandoMeta = false;
  bool _guardandoMeta = false;
  final TextEditingController _metaController = TextEditingController();

  static const _meses = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _cargandoInicial = true);
    
    try {
      final dio = context.read<Dio>();
      final org = await OrganizacionForoRepositoryImpl(
        OrganizacionForoRemoteDataSourceImpl(dio),
      ).obtenerMiOrganizacion();

      if (org == null) {
        throw Exception('No tienes una organización registrada');
      }

      if (!mounted) return;

      setState(() {
        _organizacionId = org.id;
        _metaMensual = org.metaMensual;
        _recaudadoMensual = org.recaudadoMensual;
      });
      final repository = DonacionOrganizacionRepositoryImpl(
        DonacionOrganizacionRemoteDataSourceImpl(dio),
      );

      final estadisticas = await repository.obtenerEstadisticas(org.id);

      if (!mounted) return;

      setState(() {
        if (estadisticas.metaMensual > 0) {
          _metaMensual = estadisticas.metaMensual;
        }
        _recaudadoMensual = estadisticas.recaudadoMensual;
        _donaciones = estadisticas.donacionesRecientes;
        _cargandoInicial = false;
      });
      
    } catch (e) {
      print('Error al cargar datos: $e');
      if (mounted) {
        setState(() => _cargandoInicial = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _metaController.dispose();
    super.dispose();
  }

  void _iniciarEdicion() {
    if (_organizacionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargando datos de organización...')),
      );
      return;
    }
    _metaController.text = _metaMensual > 0 ? _metaMensual.toStringAsFixed(0) : '';
    setState(() => _editandoMeta = true);
  }

  void _cancelarEdicion() {
    setState(() => _editandoMeta = false);
  }

  Future<void> _guardarMeta() async {
    if (_organizacionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar tu organización')),
      );
      return;
    }

    final valor = double.tryParse(_metaController.text);
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una meta válida mayor a 0')),
      );
      return;
    }

    setState(() {
      _editandoMeta = false;
      _guardandoMeta = true;
    });

    try {
      final dio = context.read<Dio>();
      final repository = DonacionOrganizacionRepositoryImpl(
        DonacionOrganizacionRemoteDataSourceImpl(dio),
      );

      await repository.actualizarMeta(_organizacionId!, valor);

      if (!mounted) return;

      setState(() {
        _metaMensual = valor;
        _guardandoMeta = false;
      });

      _mostrarDialogoExito(valor);
    } catch (e) {
      print('Error al guardar meta: $e');
      if (!mounted) return;
      setState(() => _guardandoMeta = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoExito(double valor) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 45),
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Meta actualizada!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Tu meta mensual se actualizó a \$${valor.toStringAsFixed(2)}.',
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
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')} ${_meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avance = _metaMensual > 0 ? (_recaudadoMensual / _metaMensual).clamp(0.0, 1.0) : 0.0;
    final porcentaje = (avance * 100).toStringAsFixed(0);
    final faltante = _metaMensual - _recaudadoMensual;
    final metaAlcanzada = faltante <= 0 && _metaMensual > 0;

    if (_cargandoInicial) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.surface,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.volunteer_activism, color: colors.primary, size: 28),
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

            if (_metaMensual == 0 && !_editandoMeta) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Colors.orange.shade700, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No olvides establecer tu meta mensual de donaciones para que la comunidad pueda apoyarte.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_guardandoMeta)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Center(child: CircularProgressIndicator()),
              ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
              ),
              child: Column(
                children: [
                  if (_editandoMeta) ...[
                    TextField(
                      controller: _metaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      decoration: InputDecoration(
                        prefixText: r'$ ',
                        labelText: 'Nueva meta mensual',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(onPressed: _cancelarEdicion, child: const Text('Cancelar')),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _guardandoMeta ? null : _guardarMeta,
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
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: colors.onSurface),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Editar meta mensual',
                          onPressed: _organizacionId != null ? _iniciarEdicion : null,
                          icon: Icon(
                            _organizacionId != null ? Icons.edit_outlined : Icons.error_outline,
                            color: _organizacionId != null ? colors.primary : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _metaMensual > 0 ? 'de \$${_metaMensual.toStringAsFixed(2)}' : 'Meta no establecida',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: avance,
                      minHeight: 10,
                      backgroundColor: colors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(metaAlcanzada ? Colors.green : colors.primary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: metaAlcanzada ? Colors.green.withValues(alpha: 0.1) : colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              metaAlcanzada ? Icons.check_circle_outline : Icons.trending_up,
                              size: 14,
                              color: metaAlcanzada ? Colors.green : colors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _metaMensual > 0 ? '$porcentaje% completado' : '0% completado',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: metaAlcanzada ? Colors.green : colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (metaAlcanzada)
                        Text('¡Meta alcanzada!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green))
                      else if (_metaMensual > 0)
                        Text('Faltan \$${faltante.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'META DEL MES DE DONACIONES',
                    style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Donaciones recibidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            
            if (_donaciones.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: Text('Aún no has recibido donaciones.')),
              )
            else
              Column(
                children: [
                  for (final donacion in _donaciones)
                    _DonacionRecibidaCard(
                      nombre: donacion.nombreDonante,
                      fecha: _formatearFecha(donacion.fechaDonacion),
                      monto: donacion.monto,
                    ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBarWidget(currentIndex: 2),
    );
  }
}
class _DonacionRecibidaCard extends StatelessWidget {
  final String nombre;
  final String fecha;
  final double monto;

  const _DonacionRecibidaCard({
    required this.nombre,
    required this.fecha,
    required this.monto,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  fecha, 
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${monto.toStringAsFixed(2)}', 
                style: TextStyle(fontWeight: FontWeight.w800, color: colors.primary, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Completada', 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}