import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
<<<<<<< HEAD
      context.read<TarjetaBloc>().add(CargarTarjetas());
=======
      context.read<TarjetaBloc>().add(
        CargarTarjetas(),
      );
>>>>>>> origin/Karla
    }
  }

  void _confirmarEliminarTarjeta(BuildContext context, Tarjeta tarjeta) {
    final colorScheme = Theme.of(context).colorScheme;
<<<<<<< HEAD

=======
    
>>>>>>> origin/Karla
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Eliminar tarjeta',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          '¿Estás seguro de eliminar la tarjeta ${tarjeta.numeroEnmascarado}?',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              context.read<TarjetaBloc>().add(EliminarTarjeta(tarjeta.id));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tarjeta eliminada')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<TarjetaBloc, TarjetaState>(
      listener: (context, state) {
        if (state is TarjetaEliminada) {
          _cargarTarjetas();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Mis tarjetas',
            style: TextStyle(
              color: colorScheme.onSurface,
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
<<<<<<< HEAD
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
=======
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
>>>>>>> origin/Karla
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes tarjetas guardadas',
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega una tarjeta para hacer donaciones más rápido',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/agregar-tarjeta'),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar tarjeta'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
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
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/agregar-tarjeta'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Agregar'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
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
                          onEdit: () async {
                            await context.push(
                              '/editar-tarjeta',
                              extra: tarjeta,
                            );
                            _cargarTarjetas();
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
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _cargarTarjetas,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is TarjetaEliminada) {
              return const Center(child: CircularProgressIndicator());
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _mostrarOpcionesTarjeta(BuildContext context, Tarjeta tarjeta) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tarjeta.numeroEnmascarado,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tarjeta.titular,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            if (!tarjeta.esPredeterminada)
              ListTile(
                leading: Icon(Icons.star, color: colorScheme.primary),
                title: Text(
                  'Establecer como predeterminada',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  context.read<TarjetaBloc>().add(
                    EstablecerPredeterminada(tarjeta.id),
                  );
                  await Future.delayed(const Duration(milliseconds: 600));
                  _cargarTarjetas();
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: colorScheme.primary,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '¡Listo!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tarjeta establecida como predeterminada',
<<<<<<< HEAD
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
=======
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
>>>>>>> origin/Karla
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ListTile(
              leading: Icon(Icons.edit, color: colorScheme.primary),
              title: Text(
                'Editar tarjeta',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/editar-tarjeta', extra: tarjeta);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: colorScheme.error),
              title: Text(
                'Eliminar tarjeta',
                style: TextStyle(color: colorScheme.error),
              ),
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