import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CuentaBancariaScreen extends StatefulWidget {
  const CuentaBancariaScreen({super.key});

  @override
  State<CuentaBancariaScreen> createState() => _CuentaBancariaScreenState();
}

class _CuentaBancariaScreenState extends State<CuentaBancariaScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _bancoSeleccionado;
  final _cuentaController = TextEditingController();
  final _titularController = TextEditingController();

  //Lista de bancos comunes en México
  static const List<String> _bancos = [
    'BBVA',
    'Banorte',
    'Santander',
    'Citibanamex',
    'HSBC',
    'Scotiabank',
    'BanBajío',
    'Inbursa',
    'Banregio',
    'Afirme',
    'Banco Azteca',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarAviso());
  }

  @override
  void dispose() {
    _cuentaController.dispose();
    _titularController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _bancoSeleccionado = prefs.getString('org_banco');
      _cuentaController.text =
          _formatearCuenta(prefs.getString('org_cuenta') ?? '');
      _titularController.text = prefs.getString('org_titular') ?? '';
    });
  }

  //Aviso de que todo es simulado
  Future<void> _mostrarAviso() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('aviso_cuenta_simulada') ?? false) return;
    if (!mounted) return;

    bool noVolverAMostrar = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD59A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 4,
              children: [
                Icon(Icons.warning_rounded, color: Color(0xFF4A3600), size: 28),
                Text(
                  'Aviso importante',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3600),
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Este registro es solo para demostración. No ingreses datos bancarios reales.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 12),
              _bullet('El flujo de donaciones es simulado'),
              const SizedBox(height: 6),
              _bullet('Puedes usar números de cuenta ficticios'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: noVolverAMostrar,
                    onChanged: (v) =>
                        setDialogState(() => noVolverAMostrar = v ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'No volver a mostrar este aviso',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (noVolverAMostrar) {
                    await prefs.setBool('aviso_cuenta_simulada', true);
                  }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  // Agrupa en bloques de 4: 1234 5678 1234 5678
  String _formatearCuenta(String valor) {
    final solo = valor.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < solo.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(solo[i]);
    }
    return buffer.toString();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('org_banco', _bancoSeleccionado ?? '');
    await prefs.setString(
      'org_cuenta',
      _cuentaController.text.replaceAll(' ', ''),
    );
    await prefs.setString('org_titular', _titularController.text.trim());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cuenta guardada correctamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Mi cuenta',
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner permanente de flujo simulado
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD59A).withValues(alpha: .35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD59A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF4A3600)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Flujo simulado: no uses datos bancarios reales.',
                    style: TextStyle(
                      color: Color(0xFF4A3600),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // DROPDOWN DE BANCOS
                DropdownButtonFormField<String>(
                  value: _bancoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Banco',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                    hintText: 'Selecciona tu banco',
                  ),
                  items: _bancos.map((banco) {
                    return DropdownMenuItem<String>(
                      value: banco,
                      child: Text(banco),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _bancoSeleccionado = value;
                    });
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Selecciona un banco' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cuentaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [LengthLimitingTextInputFormatter(19)],
                  onChanged: (v) {
                    final f = _formatearCuenta(v);
                    if (f != v) {
                      _cuentaController.value = TextEditingValue(
                        text: f,
                        selection: TextSelection.collapsed(offset: f.length),
                      );
                    }
                  },
                  validator: (v) {
                    final solo = v?.replaceAll(' ', '') ?? '';
                    if (solo.isEmpty) return 'Ingresa el número de cuenta';
                    if (solo.length != 16) return 'Debe tener 16 dígitos';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Número de cuenta',
                    prefixIcon: Icon(Icons.credit_card_outlined),
                    hintText: '1234 5678 1234 5678',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titularController,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Ingresa el titular'
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Titular de la cuenta',
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'Nombre tal como aparece en la cuenta',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardar,
                    child: const Text('Guardar cuenta'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}