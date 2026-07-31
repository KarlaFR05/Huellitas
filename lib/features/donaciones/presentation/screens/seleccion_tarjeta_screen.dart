import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../styles/constantes/app_color.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/tarjeta/tarjeta_bloc.dart';
import '../bloc/tarjeta/tarjeta_event.dart';
import '../bloc/tarjeta/tarjeta_state.dart';
import '../widgets/tarjeta_card.dart';

class SeleccionTarjetaScreen extends StatefulWidget {
  final double monto;
  final int organizacionId;

  const SeleccionTarjetaScreen({
    super.key,
    required this.monto,
    required this.organizacionId,
  });

  @override
  State<SeleccionTarjetaScreen> createState() => _SeleccionTarjetaScreenState();
}

class _SeleccionTarjetaScreenState extends State<SeleccionTarjetaScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<TarjetaBloc>().add(CargarTarjetas(authState.data.usuarioIdPk));
    }
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
          'Método de pago',
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
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monto a donar:',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '\$${widget.monto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                if (state.tarjetas.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tarjetas guardadas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${state.tarjetas.length} tarjeta(s)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
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
                            context.push('/metodo-pago', extra: {
                              'tarjeta': tarjeta,
                              'monto': widget.monto,
                              'organizacionId': widget.organizacionId,
                            });
                          },
                        );
                      },
                    ),
                  ),
                ] else ...[
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No tienes tarjetas guardadas',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/agregar-tarjeta', extra: {
                          'monto': widget.monto,
                          'organizacionId': widget.organizacionId,
                        });
                      },
                      icon: const Icon(Icons.add, size: 24),
                      label: const Text(
                        'Agregar nueva tarjeta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthSuccess) {
                        context.read<TarjetaBloc>().add(
                          CargarTarjetas(authState.data.usuarioIdPk),
                        );
                      }
                    },
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
}