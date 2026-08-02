import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/candidato_duplicado.dart';

// Colores de acento fijos para los badges (no dependen del theme, igual
// que en la referencia de diseño). Si luego quieres que se adapten a
// modo oscuro, se pueden mover a ColorScheme.extension.
const _colorBadgeTitulo = Color(0xFFF7E4B8);
const _colorTextoBadgeTitulo = Color(0xFF5C4A1E);
const _colorBadgeBorde = Color(0xFFE8C87A);
const _colorVerReporteBg = Color(0xFFFCE4EC);
const _colorVerReporteTexto = Color(0xFFC2185B);
const _colorTarjetaA = Color(0xFFF6F3EE);
const _colorTarjetaB = Color(0xFFEAF3FB);
const _colorTextoTarjeta = Color(0xFF2E2E2E);
const _colorTextoTarjetaSecundario = Color(0xFF5C5C5C);

enum _PasoDialogo { inicial, seleccionarCandidato }

class DialogoDuplicado extends StatefulWidget {
  final List<CandidatoDuplicado> candidatos;

  /// El usuario confirmó que es un animal diferente: continuar con la
  /// creación forzada del reporte.
  final VoidCallback onEsDiferente;

  /// El usuario seleccionó cuál de los candidatos es su reporte y quiere
  /// ir a verlo en el mapa. Recibe el reporte_id elegido.
  final void Function(int reporteId) onVerEnMapa;

  const DialogoDuplicado({
    super.key,
    required this.candidatos,
    required this.onEsDiferente,
    required this.onVerEnMapa,
  });

  @override
  State<DialogoDuplicado> createState() => _DialogoDuplicadoState();
}

class _DialogoDuplicadoState extends State<DialogoDuplicado> {
  _PasoDialogo _paso = _PasoDialogo.inicial;
  int? _candidatoSeleccionado;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: _paso == _PasoDialogo.inicial
            ? _buildPasoInicial(context, primary)
            : _buildPasoSeleccion(context, primary),
      ),
    );
  }

  // --- PASO 1: mensaje inicial + lista informativa ---

  Widget _buildPasoInicial(BuildContext context, Color primary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildBadgeTitulo(),
        const SizedBox(height: 14),
        Text(
          'Encontramos reportes muy parecidos cerca de esta ubicación. '
          '¿Se trata del mismo animal?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        _buildListaCandidatos(seleccionable: false),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => setState(() {
              _paso = _PasoDialogo.seleccionarCandidato;
            }),
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: BorderSide(color: primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Sí, es el mismo animal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onEsDiferente,
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'No, es diferente, continuar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // --- PASO 2: elegir cuál candidato es el reporte del usuario ---

  Widget _buildPasoSeleccion(BuildContext context, Color primary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                _paso = _PasoDialogo.inicial;
                _candidatoSeleccionado = null;
              }),
              icon: Icon(Icons.arrow_back, color: primary),
              visualDensity: VisualDensity.compact,
              tooltip: 'Volver',
            ),
            Expanded(
              child: Text(
                '¿Cuál de estos es tu reporte?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 40), // balancea el IconButton de la izquierda
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Selecciónalo y te llevaremos a su ubicación en el mapa.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 14),
        _buildListaCandidatos(seleccionable: true),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _candidatoSeleccionado == null
                ? null
                : () => widget.onVerEnMapa(_candidatoSeleccionado!),
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Ir a este reporte',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeTitulo() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _colorBadgeTitulo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorBadgeBorde),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: _colorTextoBadgeTitulo,
            size: 18,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Posible reporte duplicado',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _colorTextoBadgeTitulo,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaCandidatos({required bool seleccionable}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: widget.candidatos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final candidato = widget.candidatos[index];
          final colorTarjeta = index.isEven ? _colorTarjetaA : _colorTarjetaB;
          return _TarjetaCandidato(
            candidato: candidato,
            colorFondo: colorTarjeta,
            seleccionable: seleccionable,
            seleccionado: _candidatoSeleccionado == candidato.reporteId,
            onSelect: seleccionable
                ? () => setState(() {
                    _candidatoSeleccionado = candidato.reporteId;
                  })
                : null,
          );
        },
      ),
    );
  }
}

class _TarjetaCandidato extends StatelessWidget {
  final CandidatoDuplicado candidato;
  final Color colorFondo;
  final bool seleccionable;
  final bool seleccionado;
  final VoidCallback? onSelect;

  const _TarjetaCandidato({
    required this.candidato,
    required this.colorFondo,
    this.seleccionable = false,
    this.seleccionado = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tarjeta = Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorFondo,
            borderRadius: BorderRadius.circular(16),
            border: seleccionable
                ? Border.all(
                    color: seleccionado
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (seleccionable) ...[
                Icon(
                  seleccionado
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: seleccionado
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    candidato.evidenciaUrl != null &&
                        candidato.evidenciaUrl!.isNotEmpty
                    ? Image.network(
                        candidato.evidenciaUrl!,
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 72, top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidato.descripcion?.isNotEmpty == true
                            ? candidato.descripcion!
                            : 'Sin descripción',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _colorTextoTarjeta,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 13,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${candidato.distanciaKm.toStringAsFixed(2)} km de distancia',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _colorTextoTarjetaSecundario,
                            ),
                          ),
                        ],
                      ),
                      if (candidato.scoreImagen != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatearCoincidencia(candidato),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _colorTextoTarjetaSecundario,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => context.push('/reporte-estado/${candidato.reporteId}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _colorVerReporteBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: _colorVerReporteTexto,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Ver reporte',
                    style: TextStyle(
                      color: _colorVerReporteTexto,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (!seleccionable) return tarjeta;

    return GestureDetector(onTap: onSelect, child: tarjeta);
  }

  Widget _placeholder() {
    return Container(
      width: 84,
      height: 84,
      color: Colors.grey[300],
      child: const Icon(Icons.pets, color: Colors.grey, size: 32),
    );
  }

  String _formatearCoincidencia(CandidatoDuplicado c) {
    if (c.scoreImagen == null) return '';
    return 'Coincidencia: imagen ${(c.scoreImagen! * 100).toStringAsFixed(0)}%';
  }
}
