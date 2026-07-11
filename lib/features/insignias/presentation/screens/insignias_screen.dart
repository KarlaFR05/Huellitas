import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../styles/constantes/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../bloc/insignia_bloc.dart';
import '../bloc/insignia_event.dart';
import '../bloc/insignia_state.dart';
import '../widgets/insignia_card.dart';
import '../widgets/categoria_selector.dart';
import 'insignia_detalle_screen.dart';

class InsigniasScreen extends StatefulWidget {
  const InsigniasScreen({super.key});

  @override
  State<InsigniasScreen> createState() => _InsigniasScreenState();
}

class _InsigniasScreenState extends State<InsigniasScreen> {
  @override
  void initState() {
    super.initState();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      final authBloc = context.read<AuthBloc>();
      int? usuarioId;

      if (authBloc.state is AuthSuccess) {
        final usuario = (authBloc.state as AuthSuccess).data;
        usuarioId = usuario.usuarioIdPk;
        print(' Usuario ID obtenido: $usuarioId');
      } else {
        print(' Usuario NO autenticado');
      }

      if (usuarioId != null && mounted) {
        print(' Disparando CargarInsignias($usuarioId)');
        context.read<InsigniaBloc>().add(CargarInsignias(usuarioId));
      } else if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: No hay usuario autenticado'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Insignias',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<InsigniaBloc, InsigniaState>(
        listener: (context, state) {
          if (state is InsigniaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Reintentar',
                  textColor: Colors.white,
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthSuccess) {
                      context.read<InsigniaBloc>().add(
                        CargarInsignias((authState).data.usuarioIdPk),
                      );
                    }
                  },
                ),
              ),
            );
          }
        },
        child: BlocBuilder<InsigniaBloc, InsigniaState>(
          builder: (context, state) {
            if (state is InsigniaLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is InsigniaError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar insignias',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthSuccess) {
                          context.read<InsigniaBloc>().add(
                            CargarInsignias((authState).data.usuarioIdPk),
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is InsigniaLoaded) {
              return _buildContenido(context, state);
            }
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudieron cargar las insignias',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Verifica tu conexión o inicia sesión nuevamente',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthSuccess) {
                        context.read<InsigniaBloc>().add(
                          CargarInsignias((authState).data.usuarioIdPk),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Intentar de nuevo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomBarWidget(currentIndex: 3),
    );
  }

  Widget _buildContenido(BuildContext context, InsigniaLoaded state) {
    return Column(
      children: [
        _buildTabs(context, state),
        const SizedBox(height: 16),
        CategoriaSelector(
          categoriaSeleccionada: state.categoriaFiltro,
          onCategoriaSeleccionada: (categoria) {
            context.read<InsigniaBloc>().add(CambiarFiltroCategoria(categoria));
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: state.insigniasFiltradas.isEmpty
              ? _buildEmptyState(state.mostrarObtenidas)
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: state.insigniasFiltradas.length,
                  itemBuilder: (context, index) {
                    final insignia = state.insigniasFiltradas[index];
                    return InsigniaCard(
                      insignia: insignia,
                      obtenida: insignia.obtenida, 
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context, InsigniaLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<InsigniaBloc>().add(CambiarTab(true));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: state.mostrarObtenidas
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Obtenidas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: state.mostrarObtenidas
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: state.mostrarObtenidas
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<InsigniaBloc>().add(CambiarTab(false));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !state.mostrarObtenidas
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Por Obtener',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !state.mostrarObtenidas
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: !state.mostrarObtenidas
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool mostrarObtenidas) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            mostrarObtenidas
                ? Icons.workspace_premium_outlined
                : Icons.lock_outline,
            size: 90,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            mostrarObtenidas
                ? 'Aún no tienes insignias'
                : '¡Sigue así! Obtendrás más insignias',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}