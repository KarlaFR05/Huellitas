import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../styles/constantes/app_color.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Donar',
          style: TextStyle(
            color: AppColors.textPrimary,
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
            return Center(child: Text(state.message));
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
      bottomNavigationBar: const BottomBarWidget(currentIndex: 3),
    );
  }
}