import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../styles/constantes/app_colors.dart';
import '../../home/presentation/widgets/bottom_bar.dart';

class ActualizarEstadoSuccessScreen extends StatefulWidget {
  const ActualizarEstadoSuccessScreen({super.key});

  @override
  State<ActualizarEstadoSuccessScreen> createState() =>
      _ActualizarEstadoSuccessScreenState();
}

class _ActualizarEstadoSuccessScreenState
    extends State<ActualizarEstadoSuccessScreen> {
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
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 120,
                color: Colors.green,
              ),
              const SizedBox(height: 32),
              const Text(
                '¡Actualización Exitosa!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'El estado del reporte ha sido actualizado correctamente.',
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
                    'Redirigiendo al inicio en ',
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
                      color: AppColors.primary,
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
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: (5 - _secondsRemaining) / 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarWidget(
        currentIndex: 0,
      ),
    );
  }
}