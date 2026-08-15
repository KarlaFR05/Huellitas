import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerificacionForm extends StatefulWidget {
  final String correo;
  final Map<String, dynamic> datosRegistro;

  const VerificacionForm({
    super.key,
    required this.correo,
    required this.datosRegistro,
  });

  @override
  State<VerificacionForm> createState() => _VerificacionFormState();
}

class _VerificacionFormState extends State<VerificacionForm> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  int segundosParaReenviar = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(EnviarCodigoEvent(correo: widget.correo));
    _iniciarCooldown();
  }

  void _iniciarCooldown() {
    segundosParaReenviar = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (segundosParaReenviar == 0) {
        timer.cancel();
      } else {
        setState(() => segundosParaReenviar--);
      }
    });
  }

  String get codigoCompleto => controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    if (codigoCompleto.length == 6) {
      FocusScope.of(context).unfocus();
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess && state.message == 'Código confirmado') {
          context.go('/password', extra: widget.datosRegistro);
        }

        if (state is AuthSuccess && state.message == 'Código enviado') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código enviado a tu correo')),
          );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          for (final c in controllers) {
            c.clear();
          }
          setState(() {});
          focusNodes[0].requestFocus();
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Verifica tu correo',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enviamos un código de 6 dígitos a\n${widget.correo}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _onDigitChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading || codigoCompleto.length < 6
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                            ConfirmarCodigoEvent(
                              correo: widget.correo,
                              codigo: codigoCompleto,
                            ),
                          );
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirmar'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: segundosParaReenviar == 0
                    ? () {
                        context.read<AuthBloc>().add(
                          EnviarCodigoEvent(correo: widget.correo),
                        );
                        _iniciarCooldown();
                      }
                    : null,
                child: Text(
                  segundosParaReenviar == 0
                      ? 'Reenviar código'
                      : 'Reenviar código en ${segundosParaReenviar}s',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
