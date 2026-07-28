import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../styles/constantes/app_color.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';

class DonacionErrorScreen extends StatefulWidget {
  const DonacionErrorScreen({super.key});

  @override
  State<DonacionErrorScreen> createState() => _DonacionErrorScreenState();
}

class _DonacionErrorScreenState extends State<DonacionErrorScreen> {
  int _secondsRemaining = 5;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        // Redirige de vuelta al método de pago para que pueda corregir sus datos
        context.go('/metodo-pago');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => context.go('/metodo-pago'),
        ),
        title: const Text(
          'Error',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de X roja
              const Icon(
                Icons.cancel,
                size: 120,
                color: Colors.red,
              ),
              const SizedBox(height: 32),
              
              // Título de error
              const Text(
                '¡Ups! Algo salió mal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Subtítulo tranquilizador
              const Text(
                'No pudimos procesar tu donación. Verifica los datos de tu tarjeta e intenta nuevamente. No se ha realizado ningún cobro.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Contador regresivo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Redirigiendo al formulario en ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$_secondsRemaining',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red, // Número en rojo para coincidir
                    ),
                  ),
                  const Text(
                    ' segundos...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Barra de progreso roja
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: (5 - _secondsRemaining) / 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botón manual para no obligar al usuario a esperar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/metodo-pago');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Intentar de nuevo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarWidget(
        currentIndex: 2,
      ),
    );
  }
}