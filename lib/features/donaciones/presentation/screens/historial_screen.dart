import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/historial_bloc.dart';
import '../bloc/historial_event.dart';
import '../bloc/historial_state.dart';
import '../widgets/historial_donacion_card.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistorialBloc>().add(CargarHistorial(TipoHistorial.donaciones));
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
          'Historial de Donaciones',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HistorialBloc, HistorialState>(
        builder: (context, state) {
          if (state is HistorialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistorialError) {
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
                    onPressed: () => context
                        .read<HistorialBloc>()
                        .add(CargarHistorial(TipoHistorial.donaciones)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is HistorialLoaded) {
            if (state.donaciones.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aún no tienes donaciones',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Cuando realices una donación, aquí aparecerá tu historial',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.donaciones.length,
              itemBuilder: (context, index) {
                final donacion = state.donaciones[index];
                final organizacion = context
                    .read<HistorialBloc>()
                    .organizacionPorId(donacion.organizacionId);

                return HistorialDonacionCard(
                  donacion: donacion,
                  organizacion: organizacion,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}