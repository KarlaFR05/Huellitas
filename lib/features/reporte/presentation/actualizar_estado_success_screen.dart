import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../styles/constantes/app_colors.dart';

class ActualizarEstadoSuccessScreen extends StatelessWidget {
  const ActualizarEstadoSuccessScreen({super.key});

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
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    onPressed: () => context.go('/home'),
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
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: AppColors.secondary,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: AppColors.background,
                      child: Icon(Icons.check,
                          size: 80, color: AppColors.primary),
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Actualización completada',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Se atenderá lo antes posible',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}