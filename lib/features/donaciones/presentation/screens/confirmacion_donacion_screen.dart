import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../styles/constantes/app_color.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';

class ConfirmacionDonacionScreen extends StatefulWidget {
  const ConfirmacionDonacionScreen({super.key});

  @override
  State<ConfirmacionDonacionScreen> createState() =>
      _ConfirmacionDonacionScreenState();
}

class _ConfirmacionDonacionScreenState
    extends State<ConfirmacionDonacionScreen> {
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Donación',
          style: TextStyle(
            color: AppColors.textPrimary,
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
              // Icono de éxito grande
              Icon(
                Icons.check_circle_outline,
                size: 120,
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),
              
              // Títulos de donación
              const Text(
                '¡Gracias por tu donación!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tu aportación nos ayuda mucho a seguir rescatando vidas.',
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
              
              // Barra de progreso
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
        currentIndex: 2,
      ),
    );
  }
}