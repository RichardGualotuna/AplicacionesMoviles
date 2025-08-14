import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  // Simulación de una propiedad para el nombre del usuario.
  // En una implementación real, podrías obtener esto del AuthViewModel.
  String _userName = 'Usuario';

  String get userName => _userName;

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }
}
