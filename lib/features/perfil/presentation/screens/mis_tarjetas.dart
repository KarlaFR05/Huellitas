import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../styles/constantes/app_color.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../donaciones/presentation/bloc/tarjeta/tarjeta_bloc.dart';
import '../../../donaciones/presentation/bloc/tarjeta/tarjeta_event.dart';
import '../../../donaciones/presentation/bloc/tarjeta/tarjeta_state.dart';
import '../../../donaciones/presentation/widgets/tarjeta_card.dart';
import '../../../donaciones/domain/entities/tarjeta.dart';

class MisTarjetasScreen extends StatefulWidget {
  const MisTarjetasScreen({super.key});

  @override
  State<MisTarjetasScreen> createState() => _MisTarjetasScreenState();
}

class _MisTarjetasScreenState extends State<MisTarjetasScreen> {
  @override
  void initState() {
    super.initState();
    _cargarTarjetas();
  }

  void _cargarTarjetas() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<TarjetaBloc>().add(CargarTarjetas(authState.data.usuarioIdPk));
    }
  }

  void _confirmarEliminarTarjeta(BuildContext context, Tarjeta tarjeta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarjeta'),
        content: Text('¿Estás seguro de eliminar la tarjeta ${tarjeta.numeroEnmascarado}?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              context.read<TarjetaBloc>().add(EliminarTarjeta(tarjeta.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tarjeta eliminada')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
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
          'Mis tarjetas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TarjetaBloc, TarjetaState>(
        builder: (context, state) {
          if (state is TarjetaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TarjetaLoaded) {
            if (state.tarjetas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card,
                      size: 80,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tienes tarjetas guardadas',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Agrega una tarjeta para hacer donaciones más rápido',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/agregar-tarjeta'),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar tarjeta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.tarjetas.length} tarjeta(s) guardada(s)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/agregar-tarjeta'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.tarjetas.length,
                    itemBuilder: (context, index) {
                      final tarjeta = state.tarjetas[index];
                      return TarjetaCard(
                        tarjeta: tarjeta,
                        onTap: () {
                          _mostrarOpcionesTarjeta(context, tarjeta);
                        },
                        onEdit: () {
                          context.push('/editar-tarjeta', extra: tarjeta);
                        },
                        onDelete: () {
                          _confirmarEliminarTarjeta(context, tarjeta);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          if (state is TarjetaError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarTarjetas,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _mostrarOpcionesTarjeta(BuildContext context, Tarjeta tarjeta) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tarjeta.numeroEnmascarado,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(tarjeta.titular),
            const SizedBox(height: 20),
            if (!tarjeta.esPredeterminada)
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Establecer como predeterminada'),
                onTap: () {
                  context.read<TarjetaBloc>().add(EstablecerPredeterminada(tarjeta.id));
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar tarjeta'),
              onTap: () {
                Navigator.pop(context);
                context.push('/editar-tarjeta', extra: tarjeta);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar tarjeta', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminarTarjeta(context, tarjeta);
              },
            ),
          ],
        ),
      ),
    );
  }
}