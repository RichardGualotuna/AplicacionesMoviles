import 'package:flutter/material.dart';

class AppColors {
  // Colores principales
  static const Color primaryGreen = Color(0xFF27AE60);
  static const Color secondaryGreen = Color(0xFF2ECC71);
  static const Color lightGreen = Color(0xFFE8F5E8);
  
  // Colores de gradientes
  static const Color purpleStart = Color(0xFF667EEA);
  static const Color purpleEnd = Color(0xFF764BA2);
  
  // Colores de texto
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textGray = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFF95A5A6);
  
  // Colores de fondo
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundGray = Color(0xFFECF0F1);
  
  // Colores de borde
  static const Color borderGray = Color(0xFFBDC3C7);
  static const Color borderLight = Color(0xFFE9ECEF);
  
  // Colores de sistema
  static const Color successGreen = Color(0xFF27AE60);
  static const Color warningYellow = Color(0xFFF39C12);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color infoBlue = Color(0xFF3498DB);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, secondaryGreen],
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleStart, purpleEnd],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F7FA), Color(0xFFC3CFE2)],
  );
}