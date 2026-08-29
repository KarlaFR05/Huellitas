import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../foro/data/datasources/organizacion_foro_datasource.dart';
import '../../../foro/data/repositories/organizacion_foro_repository_impl.dart';
import '../../../foro/domain/entities/organizacion_foro.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';

class DonacionesOrganizacionScreen extends StatefulWidget {
  const DonacionesOrganizacionScreen({super.key});

  @override
  State<DonacionesOrganizacionScreen> createState() =>
      _DonacionesOrganizacionScreenState();
}

class _DonacionesOrganizacionScreenState
    extends State<DonacionesOrganizacionScreen> {
  late final Future<OrganizacionForo?> _futureOrg;
  late final Future<List<_DonacionRecibida>> _futureDonaciones;

  double _metaMensual = 0;
  double _recaudadoMensual = 0;
  int? _organizacionId; 

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
    final dio = Dio(); 

    _futureOrg = OrganizacionForoRepositoryImpl(
      OrganizacionForoRemoteDataSourceImpl(dio),
    ).obtenerMiOrganizacion().then((org) {
      // 🔍 DEBUG: Ver exactamente qué devuelve el repositorio
      print('🔍 [DEBUG] ORG RECIBIDA DEL REPOSITORIO: $org');
      
      if (org != null) {
        print('✅ [DEBUG] ORG.ID: ${org.id}');
        print('✅ [DEBUG] META: ${org.metaMensual}');
        print('✅ [DEBUG] RECAUDADO: ${org.recaudadoMensual}');
        
        if (mounted) {
          setState(() {
            _organizacionId = org.id; 
            _metaMensual = org.metaMensual; 
            _recaudadoMensual = org.recaudadoMensual;
            print('✅ [DEBUG] _organizacionId guardado exitosamente en setState');
          });
        }
      } else {
        print('❌ [DEBUG] El repositorio devolvió NULL. Revisa tu DataSource o el endpoint del backend.');
      }
      return org;
    }).catchError((error) {
      print('❌ [DEBUG] ERROR al obtener organización: $error');
      if (error is DioException) {
        print('❌ [DEBUG] STATUS CODE: ${error.response?.statusCode}');
        print('❌ [DEBUG] DETALLE DEL ERROR: ${error.response?.data}');
      }
      return null;
    });

    _futureDonaciones = _obtenerDonaciones(dio);
  }

  @override
  void dispose() {
    _metaController.dispose();
    super.dispose();
  }

  Future<List<_DonacionRecibida>> _obtenerDonaciones(Dio dio) async {
    try {
      // Asegúrate de que esta ruta sea la correcta para obtener las donaciones de la organización
      final response = await dio.get('/donaciones/organizacion/mis-donaciones'); 
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((d) {
        final fecha = DateTime.tryParse(d['fecha_donacion']?.toString() ?? '');
        return _DonacionRecibida(
          nombre: d['nombre_donante']?.toString() ?? 'Donante anónimo',
          fecha: fecha != null
              ? '${fecha.day.toString().padLeft(2, '0')} ${_meses[fecha.month - 1]} ${fecha.year}'
              : '',
          monto: (d['monto'] as num?)?.toDouble() ?? 0,
        );
      }).toList();
    } catch (e) {
      print('⚠️ [DEBUG] No se pudo cargar el historial: $e');
      return [];
    }
  }

  void _iniciarEdicion() {
    _metaController.text = _metaMensual > 0 ? _metaMensual.toStringAsFixed(0) : '';
    setState(() => _editandoMeta = true);
  }

  void _cancelarEdicion() {
    setState(() => _editandoMeta = false);
  }

  Future<void> _guardarMeta() async {
    // ⏳ DEBUG: Si por alguna razón aún es null, esperamos a que la Future termine
    if (_organizacionId == null) {
      print('⏳ [DEBUG] Esperando a que cargue la organización...');
      await _futureOrg;
      
      if (_organizacionId == null) {
        print('❌ [DEBUG] Después de esperar, _organizacionId sigue siendo null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo identificar tu organización. Verifica tu sesión.')),
        );
        return;
      }
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
      final dio = Dio(); 
      
      print('📡 [DEBUG] ENVIANDO PATCH A: /donaciones/organizacion/$_organizacionId/meta');
      print('📦 [DEBUG] DATOS: {"meta_mensual": $valor}');
      
      final response = await dio.patch(
        '/donaciones/organizacion/$_organizacionId/meta',
        data: {'meta_mensual': valor},
      );
      
      print('✅ [DEBUG] RESPUESTA DEL SERVIDOR: ${response.statusCode}');

      if (!mounted) return;
      setState(() {
        _metaMensual = valor;
        _guardandoMeta = false;
      });
      _mostrarDialogoExito(valor);
    } catch (e) {
      print('❌ [DEBUG] ERROR AL GUARDAR META: $e');
      if (e is DioException) {
        print('❌ [DEBUG] STATUS CODE DEL ERROR: ${e.response?.statusCode}');
        print('❌ [DEBUG] DETALLE DEL ERROR: ${e.response?.data}');
      }
      if (!mounted) return;
      setState(() => _guardandoMeta = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avance = _metaMensual > 0 ? (_recaudadoMensual / _metaMensual).clamp(0.0, 1.0) : 0.0;
    final porcentaje = (avance * 100).toStringAsFixed(0);
    final faltante = _metaMensual - _recaudadoMensual;
    final metaAlcanzada = faltante <= 0 && _metaMensual > 0;

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
                          onPressed: _iniciarEdicion,
                          icon: Icon(Icons.edit_outlined, color: colors.primary),
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
                      valueColor: AlwaysStoppedAnimation(
                        metaAlcanzada ? Colors.green : colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        Text(
                          '¡Meta alcanzada!',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green),
                        )
                      else if (_metaMensual > 0)
                        Text(
                          'Faltan \$${faltante.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant),
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

            Text(
              'Donaciones recibidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<_DonacionRecibida>>(
              future: _futureDonaciones,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final donaciones = snapshot.data ?? [];
                if (donaciones.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: Text('Aún no has recibido donaciones.')),
                  );
                }
                return Column(
                  children: [for (final donacion in donaciones) _DonacionRecibidaCard(donacion: donacion)],
                );
              },
            ),
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
  const _DonacionRecibida({required this.nombre, required this.fecha, required this.monto});
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
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
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
                Text(donacion.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(donacion.fecha, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${donacion.monto.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w800, color: colors.primary)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'completada',
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