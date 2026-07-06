import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../styles/constantes/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../home/presentation/widgets/bottom_bar.dart';

class ReportSuccessScreen extends StatefulWidget {
  final bool isSuccess;

  const ReportSuccessScreen({super.key, this.isSuccess = true});

  @override
  State<ReportSuccessScreen> createState() => _ReportSuccessScreenState();
}

class _ReportSuccessScreenState extends State<ReportSuccessScreen> {
  int _secondsRemaining = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
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
          onPressed: () {
            _timer?.cancel();
            context.go('/home');
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono circular
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: widget.isSuccess
                      ? AppColors.secondary
                      : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isSuccess ? Icons.check : Icons.close,
                    size: 80,
                    color: widget.isSuccess
                        ? AppColors.primary
                        : Colors.red.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Mensaje principal
              Text(
                widget.isSuccess
                    ? '¡Reporte Enviado!'
                    : 'Error al Enviar',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Mensaje secundario
              Text(
                widget.isSuccess
                    ? 'Tu reporte ha sido enviado y se atenderá lo antes posible.'
                    : 'No se pudo enviar el reporte. Inténtalo de nuevo.',
                style: const TextStyle(
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
              
              // Botón solo si es error
              if (!widget.isSuccess) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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