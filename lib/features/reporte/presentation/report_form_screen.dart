import 'package:flutter/material.dart';
import '../../../core/errors/mensaje_error.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../styles/constantes/app_color.dart';
import 'report_success_screen.dart';
import '../../home/presentation/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/reporte_bloc.dart';
import 'bloc/reporte_event.dart';
import 'bloc/reporte_state.dart';
import '../domain/entities/reporte.dart';
import 'package:go_router/go_router.dart';
import '../../home/presentation/widgets/bottom_bar.dart';
import 'location_service.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../auth/domain/entities/usuario.dart';
import 'package:flutter/services.dart';
import 'widgets/dialogo_duplicado.dart';
import 'widgets/loading_dialog.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _EtiquetaUrgenciaInfo extends StatelessWidget {
  const _EtiquetaUrgenciaInfo({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  Color get _fieldBackground =>
      Theme.of(context).inputDecorationTheme.fillColor ??
      Theme.of(context).colorScheme.surfaceContainer;

  Color get _accent => Theme.of(context).colorScheme.primary;

  // Controladores
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _otraRazaController = TextEditingController();

  // Variables de estado del formulario
  String? _tipoAnimal;
  String? _raza;
  String? _tamano;
  String? _tipoReporte;
  String? _urgencia;
  bool _mostrarOtraRaza = false;
  double? _latitud;
  double? _longitud;
  bool _obteniendoUbicacion = false;
  String? _otraRazaError;

  final LocationService _locationService = LocationService();

  bool _loadingDialogVisible = false;

  // Evidencia (Límite de 1 imagen)
  final List<File> _evidenceImages = [];
  final ImagePicker _picker = ImagePicker();

  // Listas locales
  final List<String> _razasPerro = [
    'Mestizo',
    'Chihuahua',
    'Schnauzer',
    'Poodle (Caniche)',
    'Yorkshire Terrier',
    'Pug',
    'Husky',
    'Labrador',
    'Pitbull',
    'Salchicha',
    'Pastor Aleman',
    'Raza desconocida',
    'Otro',
  ];

  final List<String> _razasGato = [
    'Mestizo',
    'Ragdoll',
    'Americano de pelo corto',
    'Bombay',
    'Persa',
    'Azul Ruso',
    'Maine Coon',
    'Raza desconocida',
    'Otro',
  ];

  final List<Map<String, dynamic>> _nivelesUrgencia = [
    {
      'label': 'Baja',
      'value': 'Baja',
      'color': Colors.yellow.shade700,
      'desc': 'Animal estable',
    },
    {
      'label': 'Media',
      'value': 'Media',
      'color': Colors.orange,
      'desc': 'Requiere atención pronto',
    },
    {
      'label': 'Alta',
      'value': 'Alta',
      'color': Colors.red,
      'desc': 'Riesgo inminente',
    },
    {
      'label': 'Crítica',
      'value': 'Crítica',
      'color': const Color.fromARGB(255, 128, 0, 0),
      'desc': 'Vida en peligro',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _otraRazaController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE UI ---

  List<String> _getTamanosPorAnimal(String? animal) {
    if (animal == 'Perro') return ['Pequeño', 'Mediano', 'Grande'];
    return ['Robusto/Compacto', 'Esbelto/Alargado', 'Moderado'];
  }

  List<String> _getRazasPorAnimal(String? animal) {
    if (animal == 'Perro') return _razasPerro;
    if (animal == 'Gato') return _razasGato;
    return [];
  }

  Future<void> _obtenerUbicacionActual() async {
    setState(() => _obteniendoUbicacion = true);
    try {
      final posicion = await _locationService.obtenerUbicacionActual();
      if (posicion != null) {
        setState(() {
          _latitud = posicion.latitude;
          _longitud = posicion.longitude;
        });
        final direccion = await _locationService
            .obtenerDireccionDesdeCoordenadas(
              posicion.latitude,
              posicion.longitude,
            );
        setState(() {
          _ubicacionController.text = direccion;
        });
      }
    } catch (e) {
      _showErrorDialog(mensajeDeError(e));
    } finally {
      setState(() => _obteniendoUbicacion = false);
    }
  }

  void _validarOtraRaza(String value) {
    setState(() {
      // Verificar si contiene números (0-9) o caracteres especiales
      if (RegExp(r'[0-9!@#$%^&=*(),._¿;-/+¡\?":{}|<>]').hasMatch(value)) {
        _otraRazaError = 'No puede contener números ni caracteres especiales';
      } else {
        _otraRazaError = null;
      }
    });
  }

  // --- IMÁGENES ---

  Future<void> _pickImage(ImageSource source) async {
    if (_evidenceImages.isNotEmpty) {
      _showErrorDialog('Solo puedes subir 1 imagen');
      return;
    }
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _evidenceImages.add(File(image.path));
        });
      }
    } catch (e) {
      _showErrorDialog('No se pudo seleccionar la imagen. Inténtalo de nuevo.');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Container(
          decoration: BoxDecoration(
            color: _fieldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccionar imagen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(sheetContext).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(sheetContext).colorScheme.primary,
                ),
                title: const Text('Tomar fotografía'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: Theme.of(sheetContext).colorScheme.primary,
                ),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage(int index) =>
      setState(() => _evidenceImages.removeAt(index));

  void _showFullImage(File image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(image, fit: BoxFit.fitWidth),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE UI ---

  Widget _buildInfoIcon(String title, Widget content) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: content,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Entendido',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.info_outline,
          color: Theme.of(context).colorScheme.primary,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adjuntar evidencia',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        Center(
          child: GestureDetector(
            onTap: _evidenceImages.isNotEmpty
                ? () => _showFullImage(_evidenceImages[0])
                : _showImageSourceDialog,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: _fieldBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _evidenceImages.isNotEmpty
                      ? _accent
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: _evidenceImages.isNotEmpty ? 2 : 1,
                ),
              ),
              child: _evidenceImages.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _evidenceImages[0],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Ver',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca para agregar foto',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Máximo 1 imagen',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (_evidenceImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1/1 imagen agregada',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: () => _removeImage(0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // --- CONVERSIÓN A IDs (Para el BLoC) ---

  int _animalToId(String animal) => animal == 'Perro' ? 1 : 2;

  int _tipoReporteToId(String tipo) {
    switch (tipo) {
      case 'Mascota perdida':
        return 1;
      case 'Mascota encontrada':
        return 2;
      case 'Animal en abandono/riesgo':
        return 3;
      case 'Maltrato animal':
        return 4;
      default:
        return 0;
    }
  }

  int _urgenciaToId(String urgencia) {
    switch (urgencia) {
      case 'Baja':
        return 1;
      case 'Media':
        return 2;
      case 'Alta':
        return 3;
      case 'Crítica':
        return 4;
      default:
        return 0;
    }
  }

  void _submitReport() {
    if (_evidenceImages.isEmpty) {
      _showErrorDialog('Por favor agrega al menos una evidencia fotográfica');
      return;
    }
    if (_mostrarOtraRaza && _otraRazaError != null) {
      _showErrorDialog(
        'La raza no puede contener números ni caracteres especiales',
      );
      return;
    }

    if (_tipoAnimal == null ||
        _tamano == null ||
        _raza == null ||
        (_mostrarOtraRaza && _otraRazaController.text.isEmpty) ||
        _tipoReporte == null ||
        _urgencia == null) {
      _showErrorDialog('Por favor completa todos los campos');
      return;
    }
    if (_latitud == null || _longitud == null) {
      _showErrorDialog('Por favor captura tu ubicación actual');
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess || authState.data is! Usuario) {
      _showErrorDialog(
        'No se pudo identificar tu sesión. Vuelve a iniciar sesión.',
      );
      return;
    }
    final usuarioActual = authState.data as Usuario;

    final reporte = Reporte(
      tipoAnimalId: _animalToId(_tipoAnimal!),
      tamano: _tamano!,
      tipoReporteId: _tipoReporteToId(_tipoReporte!),
      urgenciaId: _urgenciaToId(_urgencia!),
      descripcion: _descripcionController.text,
      ubicacion: _ubicacionController.text,
      usuarioId: usuarioActual.usuarioIdPk,
      raza: _mostrarOtraRaza ? _otraRazaController.text : (_raza ?? ''),
      evidencia: '',
      latitud: _latitud!,
      longitud: _longitud!,
    );

    context.read<ReporteBloc>().add(SubmitReporte(reporte, _evidenceImages));
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Estás seguro(a) que quieres salir?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'No se guardará la información del formulario',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainer,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.go('/home');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Salir',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReporteBloc, ReporteState>(
      listener: (context, state) {
        final estaCargando = state is ReporteSubmitting;

        if (estaCargando && !_loadingDialogVisible) {
          _loadingDialogVisible = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const LoadingDialog(),
          );
        } else if (!estaCargando && _loadingDialogVisible) {
          _loadingDialogVisible = false;
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is ReporteSuccess) {
          context.go('/report-success');
        } else if (state is ReporteError) {
          _showErrorDialog(state.message);
        } else if (state is ReporteDuplicadoDetectado) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => DialogoDuplicado(
              candidatos: state.candidatos,
              onEsDiferente: () {
                Navigator.of(dialogContext).pop();
                context.read<ReporteBloc>().add(ConfirmarCreacionForzada());
              },
              onVerEnMapa: (reporteId) {
                Navigator.of(dialogContext).pop();
                context.read<ReporteBloc>().add(CancelarCreacionPorDuplicado());
                context.go('/home?reporteId=$reporteId');
              },
            ),
          );
        }
      },
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
            onPressed: _showExitConfirmationDialog,
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
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accent, _accent.withValues(alpha: .72)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: .2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ayúdanos a ayudar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Completa los datos para que la comunidad pueda actuar rápidamente.',
                            style: TextStyle(color: Colors.white, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Clasificación de reporte',
                style: TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Tipo de reporte',
                _tipoReporte,
                [
                  'Mascota perdida',
                  'Mascota encontrada',
                  'Animal en abandono/riesgo',
                  'Maltrato animal',
                ],
                (value) => setState(() => _tipoReporte = value),
                hintText: 'Seleccione una opción',
                infoTitle: 'Tipos de reporte',
                infoContent: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(
                        text: '• ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'Mascota perdida: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            'El animal es tuyo o de alguien conocido y no saben su paradero actual.\n\n',
                      ),
                      TextSpan(
                        text: '• ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'Mascota encontrada: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            'Encontraste un animal con dueño (collar, arnés, señales de estar acostumbrado a un hogar) y buscas ayudar a reunirlo con su familia.\n\n',
                      ),
                      TextSpan(
                        text: '• ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'Animal en abandono/riesgo: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            'Animal callejero, sin hogar aparente, en situación de calle, enfermo, herido o en peligro por su entorno (clima, tráfico, falta de alimento).\n\n',
                      ),
                      TextSpan(
                        text: '• ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'Maltrato animal: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            'El animal está sufriendo maltrato, negligencia o abuso por parte de una persona, incluyendo casos dentro de un domicilio privado. Este tipo de reporte solo es visible para usuarios verificados.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Text(
                    'Nivel de urgencia',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildInfoIcon(
                    'Niveles de Urgencia',
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: _EtiquetaUrgenciaInfo(
                              texto: 'Baja',
                              color: Colors.yellow.shade700,
                            ),
                          ),
                          TextSpan(
                            text:
                                '  Animal consciente, camina bien, sin heridas visibles. Solo necesita alimento o refugio.\n\n',
                          ),
                          TextSpan(
                            text: '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: _EtiquetaUrgenciaInfo(
                              texto: 'Media',
                              color: Colors.orange,
                            ),
                          ),
                          TextSpan(
                            text:
                                '  Heridas leves, cojea, deshidratación o desnutrición evidente. Requiere atención en las próximas horas.\n\n',
                          ),
                          TextSpan(
                            text: '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: _EtiquetaUrgenciaInfo(
                              texto: 'Alta',
                              color: Colors.red,
                            ),
                          ),
                          TextSpan(
                            text:
                                '  No puede moverse, sangrado visible, heridas graves o signos de maltrato. Riesgo de empeorar pronto.\n\n',
                          ),
                          TextSpan(
                            text: '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: _EtiquetaUrgenciaInfo(
                              texto: 'Crítica',
                              color: Color.fromARGB(255, 128, 0, 0),
                            ),
                          ),
                          TextSpan(
                            text:
                                '  Inconsciente, hemorragia severa, respiración muy difícil o convulsiones. Necesita inmediata YA!',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _buildUrgencySelector(),
              const SizedBox(height: 32),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 32),
              Text(
                'Datos del animal',
                style: TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Tipo de animal',
                _tipoAnimal,
                ['Gato', 'Perro'],
                (value) => setState(() {
                  _tipoAnimal = value;
                  _tamano = null;
                  _raza = null;
                  _mostrarOtraRaza = false;
                  _otraRazaController.clear();
                  _otraRazaError = null;
                }),
                hintText: 'Seleccione un tipo de animal',
              ),
              const SizedBox(height: 16),
              if (_tipoAnimal != null) ...[
                _buildDropdownField(
                  'Raza',
                  _raza,
                  _getRazasPorAnimal(_tipoAnimal),
                  (value) => setState(() {
                    _raza = value;
                    _mostrarOtraRaza = value == 'Otro';
                    if (!_mostrarOtraRaza) {
                      _otraRazaController.clear();
                      _otraRazaError = null;
                    }
                  }),
                  hintText: 'Seleccione una raza',
                ),
                if (_mostrarOtraRaza) ...[
                  const SizedBox(height: 16),
                  _buildOtraRazaField(),
                ],
              ],
              const SizedBox(height: 16),
              _buildDropdownField(
                'Tamaño',
                _tamano,
                _getTamanosPorAnimal(_tipoAnimal),
                (value) => setState(() => _tamano = value),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Text(
                    'Descripción',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildInfoIcon(
                    'Información Importante',
                    Text(
                      'Describe características que ayuden a identificar al animal:\n\n'
                      '• Peso aproximado\n'
                      '• Color del pelaje\n'
                      '• Si usa ropa, collar u otros accesorios\n'
                      '• Señas particulares (cicatrices, manchas, etc.)\n'
                      '• Comportamiento o condición especial',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              _buildTextArea(_descripcionController),
              const SizedBox(height: 24),
              Text(
                'Ubicación',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Divider(color: Colors.grey, height: 1),

              const SizedBox(height: 12),
              _buildLocationField(_ubicacionController),
              const SizedBox(height: 24),

              _buildEvidenceSection(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Enviar reporte',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: const BottomBarWidget(currentIndex: 0),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildTextField(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _fieldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Escribe aquí',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtraRazaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingresar otra raza',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _fieldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _otraRazaError != null
                  ? Colors.red
                  : Theme.of(context).colorScheme.outline,
              width: _otraRazaError != null ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _otraRazaController,
            onChanged: _validarOtraRaza,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Escribe la raza del animal',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            style: TextStyle(
              color: _otraRazaError != null
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
        if (_otraRazaError != null) ...[
          const SizedBox(height: 4),
          Text(
            _otraRazaError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    String? hintText,
    String? infoTitle,
    Widget? infoContent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            if (infoContent != null && infoTitle != null)
              _buildInfoIcon(infoTitle, infoContent),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) => DropdownMenu<String>(
            key: ValueKey('$label-$value'),
            initialSelection: value,
            width: constraints.maxWidth,
            menuHeight: 390,
            enableFilter: false,
            enableSearch: false,
            requestFocusOnTap: false,
            hintText: hintText ?? 'Selecciona $label',
            trailingIcon: const Icon(Icons.keyboard_arrow_down_rounded),
            selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up_rounded),
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              constraints: const BoxConstraints(minHeight: 62),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _accent, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _accent, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _accent, width: 2),
              ),
            ),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.surface,
              ),
              elevation: const WidgetStatePropertyAll(8),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(vertical: 10),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            dropdownMenuEntries: [
              DropdownMenuEntry<String>(
                value: '__hint__$label',
                label: hintText ?? 'Selecciona $label',
                enabled: false,
                style: MenuItemButton.styleFrom(
                  minimumSize: const Size(0, 58),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  textStyle: const TextStyle(fontSize: 17),
                ),
              ),
              for (final item in items)
                DropdownMenuEntry<String>(
                  value: item,
                  label: item,
                  style: MenuItemButton.styleFrom(
                    minimumSize: const Size(0, 58),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    textStyle: const TextStyle(fontSize: 17),
                  ),
                ),
            ],
            onSelected: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(TextEditingController controller) {
    return TextField(
      controller: controller,
      minLines: 5,
      maxLines: 7,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        filled: true,
        fillColor: _fieldBackground,
        hintText: 'Describe el color, tamaño, condición y señas particulares...',
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.all(18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _accent, width: 2),
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        height: 1.45,
      ),
    );
  }

  Widget _buildLocationField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_latitud != null && _longitud != null) ...[
          GestureDetector(
            onTap: () {
              // Copiar al portapapeles
              Clipboard.setData(ClipboardData(text: controller.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ubicación copiada al portapapeles'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _fieldBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.text,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.copy,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _obteniendoUbicacion ? null : _obtenerUbicacionActual,
            icon: _obteniendoUbicacion
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _latitud != null ? Icons.check_circle : Icons.my_location,
                    color: _latitud != null
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
            label: Text(
              _obteniendoUbicacion
                  ? 'Obteniendo ubicación...'
                  : _latitud != null
                  ? 'Ubicación capturada — Volver a capturar'
                  : 'Usar mi ubicación actual',
              style: TextStyle(
                color: _latitud != null
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: _latitud != null
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencySelector() {
    final colors = Theme.of(context).colorScheme;
    Map<String, dynamic>? seleccionada;
    for (final nivel in _nivelesUrgencia) {
      if (nivel['value'] == _urgencia) {
        seleccionada = nivel;
        break;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final ancho = (constraints.maxWidth - 8) / 2;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _nivelesUrgencia.map((nivel) {
          final isSelected = _urgencia == nivel['value'];
          final color = nivel['color'] as Color;
                return SizedBox(
                  width: ancho,
                  height: 44,
            child: Material(
              color: isSelected
                        ? color.withValues(alpha: .16)
                        : colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: isSelected
                            ? color
                            : colors.outlineVariant.withValues(alpha: .6),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
              child: InkWell(
                onTap: () => setState(() => _urgencia = nivel['value']),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Row(
                    children: [
                      Container(
                              width: 11,
                              height: 11,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                            const SizedBox(width: 8),
                      Expanded(
                              child: Text(
                              nivel['label'],
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                  color: isSelected ? color : colors.onSurface,
                              ),
                            ),
                      ),
                            if (isSelected)
                              Icon(Icons.check_rounded, color: color, size: 19),
                    ],
                  ),
                ),
              ),
            ),
          );
              }).toList(),
            );
          },
        ),
        if (seleccionada != null) ...[
          const SizedBox(height: 10),
          Text(
            seleccionada['desc'] as String,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
