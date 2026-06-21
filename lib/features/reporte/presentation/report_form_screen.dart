import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../styles/constantes/app_colors.dart';
import 'report_success_screen.dart';
import '../../home/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/reporte_bloc.dart';
import 'bloc/reporte_event.dart';
import '../domain/entities/reporte.dart';
import 'package:go_router/go_router.dart';
import 'bloc/reporte_state.dart';
import 'package:go_router/go_router.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReporteBloc>().add(LoadCatalogsEvent());
    });
  }

  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  String? _tipoAnimal;
  String _raza = '';
  String? _tamano;
  String? _tipoReporte;
  String? _urgencia;

  int _animalToId(String animal) {
    if (animal == 'Perro') return 1;
    if (animal == 'Gato') return 2;
    throw Exception('Animal no válido');
  }

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
        throw Exception('Tipo de reporte no válido');
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
        throw Exception('Urgencia no válida');
    }
  }

  List<File> _evidenceImages = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _tiposAnimal = ['Gato', 'Perro'];

  final List<String> _tiposReporte = [
    'Mascota perdida',
    'Mascota encontrada',
    'Animal en abandono/riesgo',
    'Maltrato animal',
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

  List<String> _getTamanosPorAnimal(String? animal) {
    if (animal == 'Perro') {
      return ['Pequeño', 'Mediano', 'Grande'];
    } else {
      return ['Robusto/Compacto', 'Esbelto/Alargado', 'Moderado'];
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );

        if (images.isNotEmpty) {
          setState(() {
            for (var image in images) {
              _evidenceImages.add(File(image.path));
            }
          });
        }
      } else {
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
      }
    } catch (e) {
      _showErrorDialog('Error al seleccionar la imagen');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
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
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _evidenceImages.removeAt(index);
    });
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

  Widget _buildBottomBar() {
    return Container(
      height: 75,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: _showExitConfirmationDialog,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, color: Colors.white, size: 28),
              ],
            ),
          ),
          const Icon(Icons.notifications_none, color: Colors.white, size: 28),
          const Icon(Icons.assignment_outlined, color: Colors.white, size: 28),
          const Icon(Icons.person_outline, color: Colors.white, size: 28),
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
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
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
                'Datos del animal',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdownField('Tipo de animal', _tipoAnimal, _tiposAnimal, (
                value,
              ) {
                setState(() {
                  _tipoAnimal = value;
                  _tamano = null;
                });
              }),
              const SizedBox(height: 16),
              _buildTextField('Raza', _raza, (value) {
                setState(() => _raza = value);
              }),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Tamaño',
                _tamano,
                _getTamanosPorAnimal(_tipoAnimal),
                (value) {
                  setState(() => _tamano = value);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Descripción',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
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
                _tiposReporte,
                (value) {
                  setState(() => _tipoReporte = value);
                },
                hintText: 'Seleccione una opción',
              ),
              const SizedBox(height: 24),
              const Text(
                'Nivel de urgencia',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildUrgencySelector(),
              const SizedBox(height: 24),
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
                  onPressed: _evidenceImages.isEmpty
                      ? () => _showErrorDialog(
                          'Por favor agrega al menos una evidencia fotográfica',
                        )
                      : _tipoAnimal == null || _tamano == null
                      ? () => _showErrorDialog(
                          'Por favor completa todos los campos',
                        )
                      : _submitReport,
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
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

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
              hintText: 'Ingresa $label',
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
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
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
          hintText: 'Describe los detalles del reporte...',
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
    return Container(
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
            onChanged: (value) {
              setState(() => _urgencia = value!);
            },
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

  Widget _buildEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_a_photo,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Agregar más fotos',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_evidenceImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _evidenceImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _evidenceImages[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
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
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_evidenceImages.length} imagen${_evidenceImages.length == 1 ? '' : 'es'} agregada${_evidenceImages.length == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  void _submitReport() {
    if (_tipoAnimal == null ||
        _tipoReporte == null ||
        _urgencia == null ||
        _tamano == null) {
      _showErrorDialog('Por favor completa todos los campos');
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
      raza: _raza,
      evidencia: '',
    );

    context.read<ReporteBloc>().add(SubmitReporte(reporte, _evidenceImages));
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // ✅ Renombrado a dialogContext para evitar colisiones
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                    onPressed: () =>
                        Navigator.pop(dialogContext), // Cierra solo el diálogo
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
                      Navigator.pop(dialogContext); // 1. Cierra el diálogo
                      context.go(
                        '/home',
                      ); // 2. Redirecciona usando GoRouter limpio
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
        );
      },
    );
  }
}
