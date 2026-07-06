import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../styles/constantes/app_colors.dart';
import 'package:go_router/go_router.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      _timer?.cancel();
                      context.go('/home');
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Reporte',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  const SizedBox(height: 40),
                  Text(
                    widget.isSuccess
                        ? 'Tu reporte ha sido enviado'
                        : 'Hubo un error al generar el reporte',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isSuccess
                        ? 'Se atenderá lo antes posible'
                        : 'Vuelve a intentarlo',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Regresando al inicio en $_secondsRemaining segundo${_secondsRemaining == 1 ? '' : 's'}...',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!widget.isSuccess) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 200,
                      height: 50,
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
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
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
            onTap: () {
              _timer?.cancel();
              context.go('/home');
            },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, color: Colors.white, size: 28),
              ],
            ),
          ),
          const Icon(Icons.notifications_none, color: Colors.white, size: 28),
          const Icon(Icons.assignment_outlined, color: Colors.white, size: 28),
          const Icon(Icons.person_outline, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}