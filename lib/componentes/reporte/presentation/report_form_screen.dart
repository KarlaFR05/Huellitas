import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../styles/constantes/app_colors.dart';
import 'report_success_screen.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _estadoSaludController = TextEditingController();

  String _tipoAnimal = 'Gato';
  String _raza = '';
  String _tamano = 'Pequeño';
  String _tipoReporte = 'Mascota Perdida';
  String _nivelUrgencia = 'Media';
  
  File? _evidenceImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _tiposAnimal = ['Gato', 'Perro', 'Otro'];
  final List<String> _tamanos = ['Pequeño', 'Mediano', 'Grande'];
  final List<String> _tiposReporte = [
    'Mascota Perdida',
    'Mascota Encontrada',
    'Animal en abandono/riesgo',
    'Maltrato animal'
  ];
  
  final List<Map<String, dynamic>> _nivelesUrgencia = [
    {'label': 'Baja', 'value': 'Baja', 'color': Colors.green, 'desc': 'Animal estable'},
    {'label': 'Media', 'value': 'Media', 'color': Colors.orange, 'desc': 'Requiere atención pronto'},
    {'label': 'Alta', 'value': 'Alta', 'color': Colors.red, 'desc': 'Riesgo inminente'},
    {'label': 'Crítica', 'value': 'Crítica', 'color': const Color(0xFF800020), 'desc': 'Vida en peligro'},
  ];

  @override
  void dispose() {
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _estadoSaludController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _evidenceImage = File(image.path);
        });
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
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home_outlined, color: Colors.white),
          Icon(Icons.notifications_none, color: Colors.white),
          Icon(Icons.assignment_outlined, color: Colors.white),
          Icon(Icons.person_outline, color: Colors.white),
        ],
      ),
    );
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
          onPressed: () => Navigator.pop(context),
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
            
            _buildDropdownField('Tipo de animal', _tipoAnimal, _tiposAnimal, (value) {
              setState(() => _tipoAnimal = value!);
            }),
            
            const SizedBox(height: 16),
            _buildTextField('Raza', _raza, (value) {
              setState(() => _raza = value);
            }),
            
            const SizedBox(height: 16),
            _buildDropdownField('Tamaño', _tamano, _tamanos, (value) {
              setState(() => _tamano = value!);
            }),
            
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
            
            const SizedBox(height: 24),
            _buildTextField('Estado de salud', _estadoSaludController.text, (value) {
              setState(() => _estadoSaludController.text = value);
            }),
            
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
            _buildDropdownField('Tipo de reporte', _tipoReporte, _tiposReporte, (value) {
              setState(() => _tipoReporte = value!);
            }),
            
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
                onPressed: _evidenceImage == null 
                  ? () => _showErrorDialog('Por favor agrega una evidencia fotográfica')
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
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged) {
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
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged) {
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
          final isSelected = _nivelUrgencia == nivel['value'];
          return RadioListTile<String>(
            value: nivel['value'],
            groupValue: _nivelUrgencia,
            onChanged: (value) {
              setState(() => _nivelUrgencia = value!);
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
              style: TextStyle(
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
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _evidenceImage != null ? AppColors.primary : Colors.grey.shade400,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _evidenceImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _evidenceImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _evidenceImage = null);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Agregar evidencia',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca para tomar foto o seleccionar de galería',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  void _submitReport() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportSuccessScreen(isSuccess: true),
      ),
    );
  }
}