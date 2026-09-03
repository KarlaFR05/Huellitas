import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/widgets/avatar_helper.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/repositories/adopciones_repository.dart';
import '../../domain/entities/adopcion.dart';
import '../adopciones_postulaciones_store.dart';

class AdopcionRespuestasScreen extends StatefulWidget {
  const AdopcionRespuestasScreen({
    super.key,
    required this.adopcion,
    required this.postulacion,
    required this.adopcionCompletada,
  });

  final Adopcion adopcion;
  final PostulacionAdopcion postulacion;
  final bool adopcionCompletada;

  @override
  State<AdopcionRespuestasScreen> createState() =>
      _AdopcionRespuestasScreenState();
}

class _AdopcionRespuestasScreenState extends State<AdopcionRespuestasScreen> {
  bool _aprobando = false;

  Future<void> _aprobar() async {
    if (widget.adopcionCompletada) return;

    if (widget.postulacion.postulacionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar la postulación.')),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aprobar adopción'),
        content: Text(
          '¿Confirmas que ${widget.postulacion.nombre} será quien adopte a '
          '${widget.adopcion.nombre}? Las demás postulaciones quedarán rechazadas. '
          'Al completar la adopción, la tarjeta dejará de estar visible; guarda '
          'el contacto del postulante antes de continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final contactoResponsable = await _pedirContactoResponsable();
    if (contactoResponsable == null || !mounted) return;

    setState(() => _aprobando = true);

    try {
      await context.read<AdopcionesRepository>().aprobarPostulacion(
        widget.adopcion.id,
        widget.postulacion.postulacionId!,
        contactoResponsable,
      );
      if (!mounted) return;

      await _mostrarAvisoGuardarContacto(_contactoDelPostulante());
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('¡Adopción aprobada!')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _aprobando = false);
      String mensaje = 'No se pudo aprobar la adopción.';
      if (e is DioException && e.response?.data is Map) {
        mensaje = (e.response!.data as Map)['detail']?.toString() ?? mensaje;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  Future<String?> _pedirContactoResponsable() async {
    final authState = context.read<AuthBloc>().state;
    final usuario = authState is AuthSuccess && authState.data is Usuario
        ? authState.data as Usuario
        : null;
    final contactoInicial = usuario?.numTelefono.trim().isNotEmpty == true
        ? usuario!.numTelefono.trim()
        : usuario?.correo.trim() ?? '';
    final controller = TextEditingController(text: contactoInicial);
    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Comparte tu medio de contacto'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Este dato solamente será visible para ${widget.postulacion.nombre}.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Teléfono, WhatsApp o correo',
                  hintText: 'Ej. 55 1234 5678',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => valor == null || valor.trim().isEmpty
                    ? 'Ingresa un medio de contacto'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: const Text('Compartir y finalizar'),
          ),
        ],
      ),
    );

    controller.dispose();
    return resultado;
  }

  String? _contactoDelPostulante() {
    for (final pregunta in widget.adopcion.preguntas) {
      if (!pregunta.esMedioContacto || pregunta.id == null) continue;
      final respuesta = widget.postulacion.respuestas[pregunta.id.toString()]
          ?.trim();
      if (respuesta != null && respuesta.isNotEmpty) return respuesta;
    }

    final contacto =
        widget.postulacion.contacto?.trim() ??
        widget.adopcion.contactoAdoptante?.trim();
    return contacto?.isNotEmpty == true ? contacto : null;
  }

  Future<void> _mostrarAvisoGuardarContacto(String? contacto) async {
    var copiado = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          icon: const Icon(Icons.contact_phone_rounded, size: 38),
          title: const Text('Guarda el contacto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'La adopción fue aprobada. Guarda el contacto de '
                '${widget.postulacion.nombre} ahora: al continuar, la tarjeta '
                'de adopción dejará de estar visible.',
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: contacto == null
                    ? const Text(
                        'No se encontró un medio de contacto del postulante.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      )
                    : SelectableText(
                        contacto,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ],
          ),
          actions: [
            if (contacto != null)
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: contacto));
                  if (!dialogContext.mounted) return;
                  setDialogState(() => copiado = true);
                },
                icon: Icon(copiado ? Icons.check_rounded : Icons.copy_rounded),
                label: Text(copiado ? 'Copiado' : 'Copiar contacto'),
              ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Ya lo guardé'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final postulacion = widget.postulacion;
    final adopcion = widget.adopcion;
    final porcentaje = postulacion.porcentajeAptitud.clamp(0, 100).toInt();

    final textoPregunta = {
      for (final p in adopcion.preguntas)
        if (p.id != null) p.id!.toString(): p.texto,
    };
    final idsContacto = {
      for (final p in adopcion.preguntas)
        if (p.id != null && p.esMedioContacto) p.id!.toString(),
    };
    final respuestasVisibles = postulacion.respuestas.entries.where((entry) {
      if (!idsContacto.contains(entry.key)) return true;
      return widget.adopcionCompletada && postulacion.fueAceptada;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Respuestas de adopción')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: .45),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: colors.primary,
                  backgroundImage: avatarProvider(postulacion.fotoPerfil),
                  child: postulacion.fotoPerfil?.isNotEmpty == true
                      ? null
                      : Text(
                          postulacion.nombre.isNotEmpty
                              ? postulacion.nombre[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postulacion.nombre,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nivel de aptitud: $porcentaje%',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _colorAptitud(porcentaje),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _textoAptitud(porcentaje),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 66,
                        height: 66,
                        child: CircularProgressIndicator(
                          value: porcentaje / 100,
                          strokeWidth: 7,
                        ),
                      ),
                      Text(
                        '$porcentaje%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                Text(
                  'Respuestas del postulante',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estas son las respuestas que ${postulacion.nombre} '
                  'proporcionó para adoptar a ${adopcion.nombre}.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < respuestasVisibles.length; i++)
                  _RespuestaCard(
                    numero: i + 1,
                    pregunta:
                        textoPregunta[respuestasVisibles[i].key] ??
                        respuestasVisibles[i].key,
                    respuesta: respuestasVisibles[i].value,
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: widget.adopcionCompletada
            ? Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.postulacion.fueAceptada
                          ? Icons.check_circle_rounded
                          : Icons.block_rounded,
                      color: widget.postulacion.fueAceptada
                          ? Colors.green
                          : colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.postulacion.fueAceptada
                          ? 'Postulación seleccionada'
                          : 'Adopción completada con otra persona',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              )
            : FilledButton(
                onPressed: _aprobando ? null : _aprobar,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: _aprobando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Aprobar adopción',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
      ),
    );
  }

  Color _colorAptitud(int porcentaje) {
    if (porcentaje >= 80) return Colors.green;
    if (porcentaje >= 60) return Colors.orange;
    return Colors.red;
  }

  String _textoAptitud(int porcentaje) {
    if (porcentaje >= 80) return 'Muy apta';
    if (porcentaje >= 60) return 'Apta';
    return 'En evaluación';
  }
}

class _RespuestaCard extends StatelessWidget {
  const _RespuestaCard({
    required this.numero,
    required this.pregunta,
    required this.respuesta,
  });

  final int numero;
  final String pregunta;
  final String respuesta;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: .45),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.help_outline_rounded, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$numero. $pregunta',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              respuesta.isEmpty ? 'Sin respuesta' : respuesta,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
