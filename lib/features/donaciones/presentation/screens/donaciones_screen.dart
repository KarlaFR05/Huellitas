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

class DonacionesScreen extends StatefulWidget {
  const DonacionesScreen({super.key});

  @override
  State<DonacionesScreen> createState() => _DonacionesScreenState();
}

class _DonacionesScreenState extends State<DonacionesScreen> {
  CategoriaOrganizacion _categoriaSeleccionada = CategoriaOrganizacion.sinFinesLucro;

  @override
  void initState() {
    super.initState();
    context.read<DonacionBloc>().add(CargarOrganizaciones(_categoriaSeleccionada));
    

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aviso importante',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
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
                    Icon(Icons.warning_amber_rounded, color: colorScheme.primary, size: 24),
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
              _bulletItem('Puedes usar números de tarjeta ficticios', colorScheme),
              const SizedBox(height: 6),
              _bulletItem('Cualquier CVV y fecha de vencimiento serán aceptados', colorScheme),
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
            ElevatedButton(
              onPressed: () async {
                if (noVolverAMostrar) {
                  await prefs.setBool('aviso_donaciones_simulado', true);
                }
                if (mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Entendido'),
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
        Icon(
          Icons.check_circle_outline,
          size: 18,
          color: colorScheme.primary,
        ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Donar',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<DonacionBloc, DonacionState>(
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
            return Column(
              children: [
                CategoriaSelector(
                  categoriaSeleccionada: _categoriaSeleccionada,
                  onCategoriaSeleccionada: (categoria) {
                    setState(() => _categoriaSeleccionada = categoria);
                    context.read<DonacionBloc>().add(CargarOrganizaciones(categoria));
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: state.organizaciones.length,
                    itemBuilder: (context, index) {
                      final organizacion = state.organizaciones[index];
                      return OrganizacionCard(
                        organizacion: organizacion,
                        onTap: () {
                          context.read<DonacionBloc>().add(SeleccionarOrganizacion(organizacion));
                          context.push('/seleccion-cantidad');
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
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
}