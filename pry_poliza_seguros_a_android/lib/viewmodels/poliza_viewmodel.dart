import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/poliza_modelo.dart';

class PolizaViewModel extends ChangeNotifier {
  String propietario = '';
  double valorSeguroAuto = 0;
  String modeloAuto = 'A';
  String edadPropietario = '18-23';
  int accidentes = 0;
  double costoTotal = 0;

  final String apiUrl = 'http://10.0.2.2:9090/bdd_dto/api/poliza';

  void nuevo() {
    propietario = '';
    valorSeguroAuto = 0;
    modeloAuto = 'A';
    edadPropietario = '18-23';
    accidentes = 0;
    costoTotal = 0;
    notifyListeners();
  }

  Future<void> calcularPoliza() async {
    final poliza = Poliza(
      propietario: propietario,
      valorSeguroAuto: valorSeguroAuto,
      modeloAuto: modeloAuto,
      edadPropietario: edadPropietario,
      accidentes: accidentes,
      costoTotal: costoTotal,
    );

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(poliza.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      costoTotal = data['costoTotal'] * 1.0;
      notifyListeners();
    } else {
      throw Exception('Error en la respuesta del servidor');
    }
  }
}
