import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../../domain/entities/categoria_organizacion.dart';
import '../bloc/donacion_bloc.dart';
import '../bloc/donacion_event.dart';
import '../bloc/donacion_state.dart';
import '../widgets/categoria_selector.dart';
import '../widgets/organizacion_card.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'donaciones_organizacion_screen.dart';

class DonacionesScreen extends StatefulWidget {
  const DonacionesScreen({super.key});

  @override
  State<DonacionesScreen> createState() => _DonacionesScreenState();
}

class _DonacionesScreenState extends State<DonacionesScreen> {
  CategoriaOrganizacion _categoriaSeleccionada =
      CategoriaOrganizacion.sinFinesLucro;

  @override
  void initState() {
    super.initState();
    context.read<DonacionBloc>().add(
      CargarOrganizaciones(_categoriaSeleccionada),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarAdvertenciaSiEsNecesario();
    });
  }

  Future<void> _mostrarAdvertenciaSiEsNecesario() async {
    final prefs = await SharedPreferences.getInstance();
    final yaMostrado = prefs.getBool('aviso_donaciones_simulado') ?? false;

    if (yaMostrado || !mounted) return;

    final colorScheme = Theme.of(context).colorScheme;
    bool noVolverAMostrar = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
          actionsPadding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD59A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 4,
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Color(0xFF4A3600),
                  size: 28,
                ),
                Text(
                  'Aviso importante',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3600),
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.priority_high_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No ingreses datos reales de tarjetas',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Este es un flujo de demostración. El sistema simula el proceso de donación, por lo que:',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              _bulletItem('No se realizará ningún cobro real', colorScheme),
              const SizedBox(height: 6),
              _bulletItem(
                'Puedes usar números de tarjeta ficticios',
                colorScheme,
              ),
              const SizedBox(height: 6),
              _bulletItem(
                'Cualquier CVV y fecha de vencimiento serán aceptados',
                colorScheme,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: noVolverAMostrar,
                    activeColor: colorScheme.primary,
                    onChanged: (value) {
                      setDialogState(() {
                        noVolverAMostrar = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'No volver a mostrar este aviso',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (noVolverAMostrar) {
                    await prefs.setBool('aviso_donaciones_simulado', true);
                  }
                  if (mounted) Navigator.pop(dialogContext);
                },
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulletItem(String texto, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ NUEVO: si es organización, redirige al panel de donaciones de organización
    if (_esOrganizacion(context)) {
      return const DonacionesOrganizacionScreen();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.volunteer_activism_rounded,
                color: colorScheme.primary,
                size: 29,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Donaciones',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(Icons.pets_rounded, color: colorScheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Apoya a organizaciones que cuidan y rescatan animales.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          CategoriaSelector(
            categoriaSeleccionada: _categoriaSeleccionada,
            onCategoriaSeleccionada: (categoria) {
              if (categoria == _categoriaSeleccionada) return;
              setState(() => _categoriaSeleccionada = categoria);
              context.read<DonacionBloc>().add(CargarOrganizaciones(categoria));
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<DonacionBloc, DonacionState>(
              builder: (context, state) {
                if (state is DonacionLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DonacionError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  );
                }
                if (state is DonacionLoaded) {
                  if (state.organizaciones.isEmpty) {
                    return const Center(
                      child: Text('No hay organizaciones en esta categoría.'),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale = MediaQuery.textScalerOf(
                        context,
                      ).scale(1);
                      final columnas = constraints.maxWidth < 330 ? 1 : 2;
                      final altura =
                          190.0 +
                          ((textScale - 1).clamp(0.0, 1.0).toDouble() * 30);
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnas,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: altura,
                        ),
                        itemCount: state.organizaciones.length,
                        itemBuilder: (context, index) {
                          final organizacion = state.organizaciones[index];
                          return OrganizacionCard(
                            organizacion: organizacion,
                            onTap: () {
                              context.read<DonacionBloc>().add(
                                SeleccionarOrganizacion(organizacion),
                              );
                              context.push('/seleccion-cantidad');
                            },
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/historial'),
          icon: const Icon(Icons.history_rounded),
          label: const Text('Historial'),
        ),
      ),
      bottomNavigationBar: const BottomBarWidget(currentIndex: 2),
    );
  }

  //detecta si el usuario es organización
  bool _esOrganizacion(BuildContext context) {
    
    final state = context.watch<AuthBloc>().state;
    return state is AuthSuccess &&
        state.data is Usuario &&
        (state.data as Usuario).esOrganizacion;
  }
}