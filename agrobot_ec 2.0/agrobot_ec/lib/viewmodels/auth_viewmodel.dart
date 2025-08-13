import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  AuthViewModel() {
    // Escucha los cambios en el estado de autenticación
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners(); // Notifica a los oyentes (GoRouter) sobre el cambio
    });
  }

  bool get isLoggedIn => _currentUser != null;

  // Método para iniciar sesión
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Manejar errores
      print('Error al iniciar sesión: $e');
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}