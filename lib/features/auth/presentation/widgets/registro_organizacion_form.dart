import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/success_status_badge.dart';

enum _Paso { formulario, validando, validado }

class RegistroOrganizacionForm extends StatefulWidget {
  final Map<String, dynamic> datosUsuario;

  const RegistroOrganizacionForm({super.key, required this.datosUsuario});

  @override
  State<RegistroOrganizacionForm> createState() =>
      _RegistroOrganizacionFormState();
}

class _RegistroOrganizacionFormState extends State<RegistroOrganizacionForm> {
  final _formKey = GlobalKey<FormState>();

  final nombreOrgController = TextEditingController();
  final registroLegalController = TextEditingController();
  final tiposAnimalesController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();
  final fechaController = TextEditingController();

  DateTime? fechaFundacion;
  String? _categoriaSeleccionada; 
  _Paso _paso = _Paso.formulario;

  @override
  void dispose() {
    nombreOrgController.dispose();
    registroLegalController.dispose();
    tiposAnimalesController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    fechaController.dispose();
    super.dispose();
  }

  void _mostrarAyuda(String titulo, String descripcion) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(titulo)),
          ],
        ),
        content: Text(descripcion, style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Entendido'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaFundacion ?? DateTime(2015),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        fechaFundacion = fecha;
        fechaController.text = "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
      });
    }
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _paso = _Paso.validando);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _paso = _Paso.validado);
    await Future.delayed(const Duration(milliseconds: 1600));

    if (!mounted) return;

    final fechaFormateada = fechaFundacion != null
        ? "${fechaFundacion!.year}-${fechaFundacion!.month.toString().padLeft(2, '0')}-${fechaFundacion!.day.toString().padLeft(2, '0')}"
        : null;

    context.go('/password', extra: {
      ...widget.datosUsuario,
      'organizacion': {
        'nombre': nombreOrgController.text.trim(),
        'registroLegal': registroLegalController.text.trim(),
        'tiposAnimales': tiposAnimalesController.text.trim(),
        'telefonoEmergencia': telefonoController.text.trim(),
        'correoInstitucional': correoController.text.trim(),
        'fechaFundacion': fechaFormateada,
        'categoria': _categoriaSeleccionada,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return SizedBox(
      height: screenHeight,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _paso == _Paso.validando 
                ? _buildValidando() 
                : (_paso == _Paso.validado ? _buildValidado() : _buildFormulario()),
          ),
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    final colors = Theme.of(context).colorScheme;
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registro de Rescate',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Ayúdanos a salvar más vidas',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: nombreOrgController,
              textCapitalization: TextCapitalization.words,
              maxLength: 80,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9 .,'&\-]")),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Ingresa el nombre de la organización';
                if (value.trim().length < 3) return 'Mínimo 3 caracteres';
                if (RegExp(r'^[0-9.\-]+$').hasMatch(value.trim())) return 'El nombre no puede ser solo números';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Nombre de la Organización',
                prefixIcon: Icon(Icons.pets_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: registroLegalController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 30,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-./ ]'))],
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Ingresa el registro o licencia legal';
                if (value.trim().length < 5) return 'Mínimo 5 caracteres';
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Registro/Licencia Legal',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(Icons.info_outline_rounded, color: colors.primary),
                  onPressed: () => _mostrarAyuda(
                    'Registro o Licencia Legal',
                    'Número oficial que identifica legalmente a tu organización. Puede ser:\n\n• RFC (ej. PFA123456ABC)\n• Número de acta constitutiva\n• Registro ante la institución correspondiente\n• CLUNI o folio de IAP\n\nSi tu organización está en proceso de registro, puedes usar un identificador temporal.',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: tiposAnimalesController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 150,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))],
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Indica qué tipos de animales rescatan';
                if (value.trim().length < 3) return 'Mínimo 3 caracteres';
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Tipos de Animales Rescatados',
                hintText: 'Ej. Perros, gatos...',
                prefixIcon: const Icon(Icons.emoji_nature_outlined),
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(Icons.info_outline_rounded, color: colors.primary),
                  onPressed: () => _mostrarAyuda(
                    'Tipos de Animales',
                    'Especifica qué especies recibe y atiende tu organización. Puedes listar varias separadas por comas.\n\nEjemplos:\n• Perros y gatos\n• Aves, conejos y roedores\n• Fauna silvestre local',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: telefonoController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingresa el teléfono de emergencia';
                if (value.length != 10) return 'Debe contener 10 dígitos';
                if (value.startsWith('0') || value.startsWith('1')) return 'El número no puede iniciar con 0 o 1';
                if (RegExp(r'^(\d)\1{9}$').hasMatch(value)) return 'Ingresa un número válido';
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Teléfono de Emergencia',
                prefixIcon: const Icon(Icons.phone_outlined),
                suffixIcon: IconButton(
                  icon: Icon(Icons.info_outline_rounded, color: colors.primary),
                  onPressed: () => _mostrarAyuda(
                    'Teléfono de Emergencia',
                    'Número al que rescatistas y usuarios podrán llamar en caso de emergencias con animales.\n\n• Debe ser un número activo de 10 dígitos\n• Puede ser celular o fijo\n• Se mostrará públicamente en el perfil de tu organización',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Ingresa el correo';
                if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'Correo inválido';
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Correo Electrónico Institucional',
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: IconButton(
                  icon: Icon(Icons.info_outline_rounded, color: colors.primary),
                  onPressed: () => _mostrarAyuda(
                    'Correo Electrónico',
                    'Ingresa un correo electrónico válido que se usará para comunicaciones y notificaciones.\n\nEjemplos:\n• contacto@patitasfelices.org\n• info@rescateanimal.mx\n• tucorreo@gmail.com\n\nSe recomienda usar un correo institucional, pero también puedes usar uno personal si tu organización está en proceso de formalización.',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Tipo de Organización',
                prefixIcon: const Icon(Icons.category_outlined),
                suffixIcon: IconButton(
                  icon: Icon(Icons.info_outline_rounded, color: colors.primary),
                  onPressed: () => _mostrarAyuda(
                    'Tipo de Organización',
                    'Selecciona la categoría que mejor describe a tu organización:\n\n'
                    '• Sin fines de lucro: Asociaciones civiles, fundaciones o grupos que operan sin buscar beneficio económico.\n'
                    '• Refugio: Instalaciones dedicadas principalmente a rescatar, albergar y dar en adopción animales.\n'
                    '• Gubernamental: Dependencias, direcciones o programas oficiales respaldados por el gobierno (municipal, estatal o federal).',
                  ),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Sin fines de lucro', child: Text('Sin fines de lucro')),
                DropdownMenuItem(value: 'Refugio', child: Text('Refugio')),
                DropdownMenuItem(value: 'Gubernamental', child: Text('Gubernamental')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Selecciona un tipo de organización';
                return null;
              },
              onChanged: (value) {
                setState(() => _categoriaSeleccionada = value);
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: fechaController,
              readOnly: true,
              onTap: seleccionarFecha,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Selecciona la fecha de fundación';
                if (fechaFundacion == null) return 'Selecciona una fecha válida';
                final hoy = DateTime.now();
                if (fechaFundacion!.isAfter(hoy)) return 'La fecha no puede ser futura';
                final antiguedad = hoy.year - fechaFundacion!.year;
                if (antiguedad > 150) return 'La fecha es demasiado antigua';
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Fecha de Fundación',
                prefixIcon: const Icon(Icons.calendar_month),
                suffixIcon: IconButton(
                  icon: Icon(Icons.info_outline_rounded, color: colors.primary),
                  onPressed: () => _mostrarAyuda(
                    'Fecha de Fundación',
                    'Día en que tu organización inició formalmente sus actividades de rescate o protección animal.\n\nSi no recuerdas la fecha exacta, usa el mes y año aproximado de inicio de operaciones.',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enviar,
                child: const Text('Continuar'),
              ),
            ),
            const SizedBox(height: 24), // Espacio extra al final para que el scroll no corte el botón
          ],
        ),
      ),
    );
  }

  Widget _buildValidando() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Tus datos se están validando...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esto puede tomar unos momentos',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SuccessStatusBadge(),
          const SizedBox(height: 20),
          Text(
            '¡Tus datos se han validado correctamente!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Continuando con la creación de tu cuenta...',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}