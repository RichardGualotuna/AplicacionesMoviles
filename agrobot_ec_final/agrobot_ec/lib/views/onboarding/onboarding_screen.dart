import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/onboarding_viewmodel.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.spa_outlined,
                size: 100,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Cultiva tu conocimiento!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'AgroBot te ayuda a optimizar tus cultivos y a resolver tus dudas agrícolas.',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Marca la pantalla de bienvenida como completa
                    Provider.of<OnboardingViewModel>(context, listen: false).completeOnboarding();
                    // Navega a la pantalla de login
                    context.go(AppRoutes.login);
                  },
                  child: const Text('Comenzar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
