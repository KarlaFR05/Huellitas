import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../styles/constantes/app_colors.dart';
import 'report_success_screen.dart';
import '../../home/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/reporte_bloc.dart';
import 'bloc/reporte_event.dart';
import 'bloc/reporte_state.dart';
import '../domain/entities/reporte.dart';
import 'package:go_router/go_router.dart';
import 'widgets/bottom_bar.dart';
import 'location_service.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
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

  final LocationService _locationService = LocationService();

  // Evidencia (Límite de 1 imagen)
  List<File> _evidenceImages = [];
  final ImagePicker _picker = ImagePicker();

  // Listas locales (Mantenidas para que tu UI funcione perfectamente)
  final List<String> _razasPerro = [
    'Mestizos',
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
      'color': const Color.fromARGB(255, 255, 238, 0),
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
      'color': const Color(0xFF800020),
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
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _obteniendoUbicacion = false);
    }
  }

  // --- IMÁGENES ---

  Future<void> _pickImage(ImageSource source) async {
    if (_evidenceImages.length >= 1) {
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
      _showErrorDialog('Error al seleccionar la imagen: ${e.toString()}');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar imagen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Tomar fotografía'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) =>
      setState(() => _evidenceImages.removeAt(index));

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
              Icon(Icons.info_outline, color: AppColors.primary, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: content, // Ahora recibe un Widget
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Entendido',
                style: TextStyle(
                  color: AppColors.primary,
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
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.info_outline, color: AppColors.primary, size: 18),
      ),
    );
  }

  Widget _buildEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _evidenceImages.length >= 1 ? null : _showImageSourceDialog,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: _evidenceImages.length >= 1
                  ? Colors.grey.withOpacity(0.2)
                  : AppColors.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _evidenceImages.length >= 1
                    ? Colors.grey.withOpacity(0.4)
                    : AppColors.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _evidenceImages.length >= 1
                        ? Colors.grey.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _evidenceImages.length >= 1
                        ? Icons.block
                        : Icons.add_a_photo,
                    size: 36,
                    color: _evidenceImages.length >= 1
                        ? Colors.grey
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _evidenceImages.length >= 1
                      ? 'Límite alcanzado'
                      : 'Agregar foto',
                  style: TextStyle(
                    color: _evidenceImages.length >= 1
                        ? Colors.grey
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Máximo 1 imagen',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        if (_evidenceImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _evidenceImages[0],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_evidenceImages.length}/1 imagen agregada',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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

    final reporte = Reporte(
      tipoAnimalId: _animalToId(_tipoAnimal!),
      tamano: _tamano!,
      tipoReporteId: _tipoReporteToId(_tipoReporte!),
      urgenciaId: _urgenciaToId(_urgencia!),
      descripcion: _descripcionController.text,
      ubicacion: _ubicacionController.text,
      usuarioId: 1,
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
        title: const Text(
          '¿Estás seguro(a) que quieres salir?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'No se guardará la información del formulario',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.secondary.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      color: AppColors.primary,
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
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Salir',
                    style: TextStyle(
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
        if (state is ReporteSuccess) {
          context.go('/report-success');
        } else if (state is ReporteError) {
          _showErrorDialog(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: _showExitConfirmationDialog,
          ),
          title: const Text(
            'Reporte',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tipo de reporte',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Text(
                    'Nivel de urgencia',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildInfoIcon(
                    'Niveles de Urgencia',
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Baja: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Animal consciente, camina bien, sin heridas visibles. Solo necesita alimento o refugio.\n\n',
                          ),

                          TextSpan(
                            text: '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Media: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Heridas leves, cojea, deshidratación o desnutrición evidente. Requiere atención en las próximas horas.\n\n',
                          ),

                          TextSpan(
                            text: '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Alta: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text:
                                'No puede moverse, sangrado visible, heridas graves o signos de maltrato. Riesgo de empeorar pronto.\n\n',
                          ),

                          TextSpan(
                            text: '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Crítica: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Inconsciente, hemorragia severa, respiración muy difícil o convulsiones. Necesita veterinario YA!',
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
              const Text(
                'Datos del animal',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                    if (!_mostrarOtraRaza) _otraRazaController.clear();
                  }),
                  hintText: 'Seleccione una raza',
                ),
                if (_mostrarOtraRaza) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Ingresar otra raza',
                    _otraRazaController.text,
                    (value) => setState(() => _otraRazaController.text = value),
                  ),
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
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildInfoIcon(
                    'Información Importante',
                    const Text(
                      'Describe características que ayuden a identificar al animal:\n\n'
                      '• Peso aproximado\n'
                      '• Color del pelaje\n'
                      '• Si usa ropa, collar u otros accesorios\n'
                      '• Señas particulares (cicatrices, manchas, etc.)\n'
                      '• Comportamiento o condición especial',
                      style: TextStyle(
                        color: AppColors.textSecondary,
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
              const Text(
                'Ubicación',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildLocationField(_ubicacionController),
              const SizedBox(height: 32),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 32),
              const Text(
                'Evidencia',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildEvidenceSection(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Enviar Reporte',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: BottomBarWidget(
          onHomePressed: _showExitConfirmationDialog,
        ),
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondary),
          ),
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Escribe la raza del animal',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
            ),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondary),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text(
              hintText ?? 'Seleccione $label',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: 'Describe los detalles sobre el animal a reportar...',
          hintStyle: TextStyle(color: AppColors.textSecondary),
        ),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildLocationField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Calle #98',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                    color: _latitud != null ? Colors.green : AppColors.primary,
                    size: 18,
                  ),
            label: Text(
              _obteniendoUbicacion
                  ? 'Obteniendo ubicación...'
                  : _latitud != null
                  ? 'Ubicación capturada — Volver a capturar'
                  : 'Usar mi ubicación actual',
              style: TextStyle(
                color: _latitud != null ? Colors.green : AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: _latitud != null ? Colors.green : AppColors.primary,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: _nivelesUrgencia.map((nivel) {
          final isSelected = _urgencia == nivel['value'];
          return RadioListTile<String>(
            value: nivel['value'],
            groupValue: _urgencia,
            onChanged: (value) => setState(() => _urgencia = value!),
            activeColor: nivel['color'] as Color,
            title: Text(
              nivel['label'],
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              nivel['desc'],
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      ),
    );
  }
}
