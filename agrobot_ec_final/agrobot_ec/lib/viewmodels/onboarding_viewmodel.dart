import 'package:flutter/material.dart';

class OnboardingPage {
  final String icon;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class OnboardingViewModel extends ChangeNotifier {
  int _currentPage = 0;
  bool _isOnboardingComplete = false; // 🔹 Nuevo flag para controlar si se completó la bienvenida

  int get currentPage => _currentPage;
  bool get isLastPage => _currentPage == onboardingPages.length - 1;
  bool get isOnboardingComplete => _isOnboardingComplete;

  List<OnboardingPage> get onboardingPages => [
    OnboardingPage(
      icon: '🌾',
      title: '¡Bienvenido a AgroBot!',
      description: 'Tu asistente inteligente para agricultura. Obtén recomendaciones personalizadas para tus cultivos en tiempo real.',
    ),
    OnboardingPage(
      icon: '🤖',
      title: 'Chatbot Especializado',
      description: 'Pregunta sobre fertilización, control de plagas, épocas de siembra y más. Respuestas basadas en documentos técnicos del MAG y FAO.',
    ),
    OnboardingPage(
      icon: '📍',
      title: 'Recomendaciones Locales',
      description: 'Consejos específicos para tu zona agroecológica y tipo de cultivo. Información adaptada a las condiciones de Ecuador.',
    ),
  ];

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  // 🔹 Método para marcar la bienvenida como completa
  void completeOnboarding() {
    _isOnboardingComplete = true;
    notifyListeners();
  }
}
