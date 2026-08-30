import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CuentaBancariaScreen extends StatefulWidget {
  const CuentaBancariaScreen({super.key});

  @override
  State<CuentaBancariaScreen> createState() => _CuentaBancariaScreenState();
}

class _CuentaBancariaScreenState extends State<CuentaBancariaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cuentaController = TextEditingController();
  String? _bancoDetectado;
  bool _guardando = false;

  static const Map<String, String> _bancosPorPrefijo3 = {
    '400': 'BBVA',
    '401': 'Banorte',
    '402': 'Citibanamex',
    '403': 'HSBC',
    '404': 'BBVA',
    '405': 'Santander',
    '406': 'Scotiabank',
    '407': 'BanBajío',
    '408': 'Inbursa',
    '409': 'Banregio',
    '410': 'Afirme',
    '411': 'Banco Azteca',
    '412': 'HSBC',
    '413': 'Santander',
    '414': 'Citibanamex',
    '415': 'BBVA',
    '416': 'Banorte',
    '417': 'Scotiabank',
    '418': 'BanBajío',
    '419': 'Inbursa',
    '420': 'Banregio',
    '421': 'Citibanamex',
    '422': 'HSBC',
    '423': 'Santander',
    '424': 'BBVA',
    '425': 'Banorte',
    '426': 'Scotiabank',
    '427': 'BanBajío',
    '428': 'Inbursa',
    '429': 'Afirme',
    '430': 'Banco Azteca',
  };

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarAviso());
  }

  @override
  void dispose() {
    _cuentaController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      final cuentaGuardada = prefs.getString('org_cuenta') ?? '';
      _cuentaController.text = _formatearCuenta(cuentaGuardada);
      _detectarBanco(cuentaGuardada);
    });
  }

  // Detecta el banco basado en los primeros dígitos
  void _detectarBanco(String cuenta) {
    final soloDigitos = cuenta.replaceAll(RegExp(r'\D'), '');
    
    if (soloDigitos.length < 3) {
      setState(() => _bancoDetectado = null);
      return;
    }

    // Fallback a prefijo de 3 dígitos
    final prefijo3 = soloDigitos.substring(0, 3);
    if (_bancosPorPrefijo3.containsKey(prefijo3)) {
      setState(() => _bancoDetectado = _bancosPorPrefijo3[prefijo3]);
    } else {
      setState(() => _bancoDetectado = null);
    }
  }

  // Aviso de que todo es simulado
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

    setState(() => _guardando = true);

    try {
      final dio = context.read<Dio>();
      final cuentaLimpia = _cuentaController.text.replaceAll(' ', '');
      final response = await dio.patch(
        '/usuarios/mi-organizacion', 
        data: {
          'cuenta_bancaria': cuentaLimpia,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('org_cuenta', cuentaLimpia);
        if (_bancoDetectado != null) {
          await prefs.setString('org_banco', _bancoDetectado!);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta guardada correctamente'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      String mensajeError = 'Error al guardar la cuenta';
      if (e is DioException && e.response?.data != null) {
        mensajeError = e.response?.data['detail'] ?? mensajeError;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
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
          'Mi cuenta bancaria',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo de número de cuenta
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
                    // Detectar banco automáticamente mientras escribe
                    _detectarBanco(v);
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
                    helperText: 'Ingresa los 16 dígitos de tu cuenta',
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de banco detectado (solo lectura)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_rounded,
                        color: colors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Banco',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _bancoDetectado ?? 'No identificado',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _bancoDetectado != null
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_bancoDetectado == null)
                        Icon(
                          Icons.help_outline,
                          color: colors.onSurfaceVariant,
                          size: 20,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'El banco se detecta automáticamente según los primeros dígitos de tu cuenta.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    child: _guardando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar cuenta'),
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