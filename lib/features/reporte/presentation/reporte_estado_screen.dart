import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../home/presentation/widgets/bottom_bar.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../auth/domain/entities/usuario.dart';
import '../domain/entities/fase_reporte.dart';
import '../domain/entities/reporte_estado.dart';
import 'bloc/reporte_estado_bloc.dart';
import 'bloc/reporte_estado_state.dart';
import 'bloc/reporte_estado_event.dart';
import 'reporte_detalle_screen.dart';
import 'actualizar_estado_screen.dart';

class ReporteEstadoScreen extends StatelessWidget {
  final int reporteId;

  const ReporteEstadoScreen({super.key, required this.reporteId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          context.read<ReporteEstadoBloc>()
            ..add(CargarEstadoReporte(reporteId)),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Reporte',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocListener<ReporteEstadoBloc, ReporteEstadoState>(
          listener: (context, state) {
            if (state is ReporteTomarError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (state is ReporteTomadoExito) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  icon: Icon(
                    Icons.volunteer_activism,
                    color: Theme.of(dialogContext).colorScheme.primary,
                    size: 40,
                  ),
                  title: const Text(
                    '¡Caso tomado!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    'Ahora eres el encargado de realizar el rescate.',
                    textAlign: TextAlign.center,
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          dialogContext,
                        ).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Entendido',
                        style: TextStyle(
                          color: Theme.of(dialogContext).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
          child: BlocBuilder<ReporteEstadoBloc, ReporteEstadoState>(
            builder: (context, state) {
              if (state is ReporteEstadoLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ReporteEstadoError) {
                return Center(child: Text(state.message));
              }
              if (state is ReporteEstadoLoaded) {
                return _buildContenido(context, state.reporte, tomando: false);
              }
              if (state is ReporteTomando) {
                return _buildContenido(context, state.reporte, tomando: true);
              }
              if (state is ReporteTomadoExito) {
                return _buildContenido(context, state.reporte, tomando: false);
              }
              if (state is ReporteTomarError) {
                return _buildContenido(context, state.reporte, tomando: false);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        bottomNavigationBar: const BottomBarWidget(currentIndex: 0),
      ),
    );
  }

  int? _obtenerUsuarioActualId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.data is Usuario) {
      return (authState.data as Usuario).usuarioIdPk;
    }
    return null;
  }

  Widget _buildContenido(
    BuildContext context,
    ReporteEstado reporte, {
    required bool tomando,
  }) {
    final fases = FaseReporte.values;
    final faseActualIndex = fases.indexOf(reporte.faseActual);
    final bool esFaseFinal =
        reporte.faseActual == FaseReporte.seEncuentraASalvo;

    final usuarioActualId = _obtenerUsuarioActualId(context);
    final bool nadieLoAtiende = reporte.usuarioRescateId == null;
    final bool yoLoAtiendo =
        !nadieLoAtiende && reporte.usuarioRescateId == usuarioActualId;
    final bool otroLoAtiende = !nadieLoAtiende && !yoLoAtiendo;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFasesIndicator(fases, faseActualIndex),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nivel de urgencia',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reporte.nivelUrgencia,
                      style: TextStyle(
                        color: _getColorUrgencia(reporte.nivelUrgencia),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildInfoRow(
            context,
            'Tipo de reporte',
            reporte.tipoReporte,
            icon: Icons.category_outlined,
          ),

          const SizedBox(height: 16),

          _buildInfoRow(
            context,
            'Descripción',
            reporte.descripcion,
            icon: Icons.description_outlined,
          ),

          const SizedBox(height: 16),

          _buildUbicacionCopiable(context, reporte.ubicacion),

          // Estado de asignación del rescate
          if (otroLoAtiende) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Atendido por',
              reporte.usuarioRescateNombre ?? 'Otro usuario',
              icon: Icons.person_outline,
            ),
          ],

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                context.push('/reporte-detalle', extra: reporte);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(55),
                ),
              ),
              child: Text(
                'Ver más sobre el reporte',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Botón principal: cambia según quién atiende el reporte
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _onPressedPrincipal(
                context: context,
                reporte: reporte,
                esFaseFinal: esFaseFinal,
                nadieLoAtiende: nadieLoAtiende,
                yoLoAtiendo: yoLoAtiendo,
                otroLoAtiende: otroLoAtiende,
                tomando: tomando,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorBotonPrincipal(
                  context: context,
                  esFaseFinal: esFaseFinal,
                  nadieLoAtiende: nadieLoAtiende,
                  otroLoAtiende: otroLoAtiende,
                ),
                foregroundColor: (esFaseFinal || otroLoAtiende)
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(55),
                ),
              ),
              child: tomando
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      _textoBotonPrincipal(
                        esFaseFinal: esFaseFinal,
                        nadieLoAtiende: nadieLoAtiende,
                        yoLoAtiendo: yoLoAtiendo,
                        otroLoAtiende: otroLoAtiende,
                        reporte: reporte,
                      ),
                      style: TextStyle(
                        color: (esFaseFinal || otroLoAtiende)
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback? _onPressedPrincipal({
    required BuildContext context,
    required ReporteEstado reporte,
    required bool esFaseFinal,
    required bool nadieLoAtiende,
    required bool yoLoAtiendo,
    required bool otroLoAtiende,
    required bool tomando,
  }) {
    if (esFaseFinal || otroLoAtiende || tomando) return null;

    if (nadieLoAtiende) {
      return () {
        context.read<ReporteEstadoBloc>().add(TomarReporte(reporte.reporteId));
      };
    }

    // yoLoAtiendo == true
    return () {
      context.push('/actualizar-estado', extra: reporte);
    };
  }

  static const Color _colorTomarCaso = Color(0xFF2E86AB);

  Color _colorBotonPrincipal({
    required BuildContext context,
    required bool esFaseFinal,
    required bool nadieLoAtiende,
    required bool otroLoAtiende,
  }) {
    if (esFaseFinal || otroLoAtiende) {
      return Theme.of(context).colorScheme.surfaceContainer;
    }
    if (nadieLoAtiende) return _colorTomarCaso;
    return Theme.of(context).colorScheme.primary;
  }

  String _textoBotonPrincipal({
    required bool esFaseFinal,
    required bool nadieLoAtiende,
    required bool yoLoAtiendo,
    required bool otroLoAtiende,
    required ReporteEstado reporte,
  }) {
    if (esFaseFinal) return 'Reporte finalizado';
    if (otroLoAtiende) {
      return 'Atendido por ${reporte.usuarioRescateNombre ?? "otro usuario"}';
    }
    if (nadieLoAtiende) return 'Tomar caso';
    return 'Actualizar estado del rescate';
  }

  Widget _buildUbicacionCopiable(BuildContext context, String ubicacion) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: ubicacion));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ubicación copiada al portapapeles'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubicación',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ubicacion,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.copy,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildFasesIndicator(List<FaseReporte> fases, int faseActualIndex) {
    return SizedBox(
      height: 60,
      child: Row(
        children: fases.asMap().entries.map((entry) {
          final index = entry.key;
          final fase = entry.value;
          final esActual = index == faseActualIndex;
          final esAnterior = index < faseActualIndex;

          Color colorFondo;
          if (esActual) {
            if (index == 0) {
              colorFondo = Colors.red;
            } else if (index == 1) {
              colorFondo = const Color.fromARGB(255, 255, 196, 0);
            } else {
              colorFondo = Colors.green;
            }
          } else if (esAnterior) {
            colorFondo = Colors.grey.shade500;
          } else {
            colorFondo = Colors.grey.shade300;
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _ChevronStep(
                label: fase.label,
                color: colorFondo,
                isActive: esActual || esAnterior,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: iconColor ?? Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorUrgencia(String urgencia) {
    switch (urgencia.toLowerCase()) {
      case 'baja':
        return Colors.yellow.shade700;
      case 'media':
        return Colors.orange.shade700;
      case 'alta':
        return Colors.red.shade700;
      case 'crítica':
        return const Color.fromARGB(255, 128, 0, 0);
      default:
        return Colors.grey;
    }
  }
}

class _ChevronStep extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;

  const _ChevronStep({
    required this.label,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final activeTextColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return ClipPath(
      clipper: const _ChevronClipper(),
      child: Container(
        color: isActive
            ? color
            : Theme.of(context).colorScheme.surfaceContainer,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive
                    ? activeTextColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 15,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChevronClipper extends CustomClipper<Path> {
  const _ChevronClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final chevronWidth = 12.0;
    final cornerRadius = 6.0;

    path.moveTo(cornerRadius, 0);
    path.lineTo(size.width - chevronWidth, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - chevronWidth, size.height);
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    path.lineTo(0, size.height / 2);
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
