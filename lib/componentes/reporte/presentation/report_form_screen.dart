import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../styles/constantes/app_colors.dart';
import 'report_success_screen.dart';
import '../../../../componentes/home/home_screen.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _otraRazaController = TextEditingController();

  String? _tipoAnimal;
  String? _raza;
  String? _tamano;
  String? _tipoReporte;  
  String _nivelUrgencia = '';
  bool _mostrarOtraRaza = false;
  
  List<File> _evidenceImages = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _tiposAnimal = ['Gato', 'Perro'];

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
    'Otro'
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
    'Otro'
  ];

  final List<String> _tiposReporte = [
    'Mascota perdida',
    'Mascota encontrada',
    'Animal en abandono/riesgo',
    'Maltrato animal'
  ];
  
  final List<Map<String, dynamic>> _nivelesUrgencia = [
    {'label': 'Baja', 'value': 'Baja', 'color': const Color.fromARGB(255, 255, 238, 0), 'desc': 'Animal estable'},
    {'label': 'Media', 'value': 'Media', 'color': Colors.orange, 'desc': 'Requiere atención pronto'},
    {'label': 'Alta', 'value': 'Alta', 'color': Colors.red, 'desc': 'Riesgo inminente'},
    {'label': 'Crítica', 'value': 'Crítica', 'color': const Color(0xFF800020), 'desc': 'Vida en peligro'},
  ];

  List<String> _getTamanosPorAnimal(String? animal) {
    if (animal == 'Perro') {
      return ['Pequeño', 'Mediano', 'Grande'];
    } else {
      return ['Robusto/Compacto', 'Esbelto/Alargado', 'Moderado'];
    }
  }

  List<String> _getRazasPorAnimal(String? animal) {
    if (animal == 'Perro') {
      return _razasPerro;
    } else if (animal == 'Gato') {
      return _razasGato;
    }
    return [];
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _otraRazaController.dispose();
    super.dispose();
  }

  // Widget para mostrar información de ayuda
  Widget _buildInfoIcon(String title, String content) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
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
              content: Text(
                content,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
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
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.info_outline,
          color: AppColors.primary,
          size: 18,
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_evidenceImages.length >= 3) {
      _showErrorDialog('Máximo 3 imágenes permitidas');
      return;
    }

    try {
      if (source == ImageSource.gallery) {
        final int disponibles = 3 - _evidenceImages.length;
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
          limit: disponibles,
        );
        
        if (images.isNotEmpty) {
          setState(() {
            for (var image in images) {
              if (_evidenceImages.length < 3) {
                _evidenceImages.add(File(image.path));
              }
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

  Widget _buildEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _evidenceImages.length >= 3 ? null : _showImageSourceDialog,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: _evidenceImages.length >= 3 
                  ? Colors.grey.withOpacity(0.2)
                  : AppColors.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _evidenceImages.length >= 3 
                    ? Colors.grey.withOpacity(0.4)
                    : AppColors.primary.withOpacity(0.5),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _evidenceImages.length >= 3
                        ? Colors.grey.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _evidenceImages.length >= 3 ? Icons.block : Icons.add_a_photo,
                    size: 36,
                    color: _evidenceImages.length >= 3 ? Colors.grey : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _evidenceImages.length >= 3 
                      ? 'Límite alcanzado'
                      : 'Agregar más fotos',
                  style: TextStyle(
                    color: _evidenceImages.length >= 3 ? Colors.grey : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Máximo 3 imágenes',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
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
            '${_evidenceImages.length}/3 imagen${_evidenceImages.length == 1 ? '' : 'es'} agregada${_evidenceImages.length == 1 ? '' : 's'}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
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
                Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.notifications_none,
            color: Colors.white,
            size: 28,
          ),
          const Icon(
            Icons.assignment_outlined,
            color: Colors.white,
            size: 28,
          ),
          const Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 28,
          ),
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
            // TIPO DE REPORTE
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
            
            //NIVEL DE URGENCIA CON INFO
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
                  '• Baja: Animal estable, sin riesgo inmediato\n'
                  '• Media: Requiere atención pronto pero no es emergencia\n'
                  '• Alta: Riesgo inminente, necesita rescate urgente\n'
                  '• Crítica: Vida en peligro, emergencia médica inmediata',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildUrgencySelector(),
            
            const SizedBox(height: 32),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 32),
            
            // 3. DATOS DEL ANIMAL
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
              setState(() {
                _tipoAnimal = value;
                _tamano = null;
                _raza = null; 
                _mostrarOtraRaza = false;
                _otraRazaController.clear();
              });
            },
            hintText: 'Seleccione un tipo de animal',
            ),
            
            const SizedBox(height: 16),
            if (_tipoAnimal != null) ...[
              _buildDropdownField('Raza', _raza, _getRazasPorAnimal(_tipoAnimal), (value) {
                setState(() {
                  _raza = value;
                  _mostrarOtraRaza = value == 'Otro';
                  if (!_mostrarOtraRaza) {
                    _otraRazaController.clear();
                  }
                });
              },
              hintText: 'Seleccione una raza',
              ),
              if (_mostrarOtraRaza) ...[
                const SizedBox(height: 16),
                _buildTextField('Ingresar otra raza', _otraRazaController.text, (value) {
                  setState(() => _otraRazaController.text = value);
                }),
              ],
            ],
            
            const SizedBox(height: 16),
            _buildDropdownField('Tamaño', _tamano, _getTamanosPorAnimal(_tipoAnimal), (value) {
              setState(() => _tamano = value);
            }),
            
            const SizedBox(height: 24),
            
            // DESCRIPCIÓN CON INFO
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
                  'Describe características que ayuden a identificar al animal:\n\n'
                  '• Peso aproximado\n'
                  '• Color del pelaje\n'
                  '• Si usa ropa, collar u otros accesorios\n'
                  '• Señas particulares (cicatrices, manchas, etc.)\n'
                  '• Comportamiento o condición especial\n\n'
                  'Mientras más detalles proporciones, más fácil será identificarlo.',
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
            
            // 4. EVIDENCIA
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
                  ? () => _showErrorDialog('Por favor agrega al menos una evidencia fotográfica')
                  : _tipoAnimal == null || _tamano == null || _raza == null || (_mostrarOtraRaza && _otraRazaController.text.isEmpty)
                    ? () => _showErrorDialog('Por favor completa todos los campos')
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
              hintText: 'Escribe la raza del animal',
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

  Widget _buildDropdownField(
  String label, 
  String? value, 
  List<String> items, 
  Function(String?) onChanged,
  {String? hintText}
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

  void _submitReport() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportSuccessScreen(isSuccess: true),
      ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
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