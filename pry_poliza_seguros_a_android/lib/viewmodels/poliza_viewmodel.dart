import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/poliza_modelo.dart';

class PolizaViewModel extends ChangeNotifier {
  String propietario = '';
  double valorSeguroAuto = 0;
  String modeloAuto = 'A';
  int edadPropietario = 18;
  int accidentes = 0;
  double costoTotal = 0;
  bool isLoading = false;
  String? errorMessage;

  // IMPORTANTE: Cambia esta URL según tu configuración
  // Para emulador Android: 10.0.2.2
  // Para dispositivo físico: IP de tu computadora (ej: 192.168.1.100)
  // Para iOS Simulator: localhost o 127.0.0.1
  final String apiUrl = 'http://10.0.2.2:8080/api/poliza';

  void nuevo() {
    propietario = '';
    valorSeguroAuto = 0;
    modeloAuto = 'A';
    edadPropietario = 18;
    accidentes = 0;
    costoTotal = 0;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> crearPoliza() async {
    if (propietario.isEmpty || valorSeguroAuto <= 0) {
      errorMessage = 'Por favor complete todos los campos';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Preparar el body de la petición según tu PolizaRequest en Spring
      final requestBody = {
        'propietario': propietario,
        'valorSeguroAuto': valorSeguroAuto,
        'modeloAuto': modeloAuto,
        'edadPropietario': edadPropietario,
        'accidentes': accidentes,
      };

      print('Enviando petición a: $apiUrl');
      print('Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      print('Respuesta status: ${response.statusCode}');
      print('Respuesta body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        costoTotal = (data['costoTotal'] ?? 0).toDouble();
        errorMessage = null;
      } else {
        errorMessage = 'Error del servidor: ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (e) {
            errorMessage = response.body;
          }
        }
      }
    } catch (e) {
      print('Error en la petición: $e');
      errorMessage = 'Error de conexión: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buscarPolizaPorNombre(String nombre) async {
    if (nombre.isEmpty) {
      errorMessage = 'Por favor ingrese un nombre';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/usuario?nombre=$nombre'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        propietario = data['propietario'] ?? '';
        modeloAuto = data['modeloAuto'] ?? 'A';
        valorSeguroAuto = (data['valorSeguroAuto'] ?? 0).toDouble();
        edadPropietario = data['edadPropietario'] ?? 18;
        accidentes = data['accidentes'] ?? 0;
        costoTotal = (data['costoTotal'] ?? 0).toDouble();
        errorMessage = null;
      } else {
        errorMessage = 'Usuario no encontrado';
      }
    } catch (e) {
      errorMessage = 'Error de conexión: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}