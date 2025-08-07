class PolizaRequest {
  final String propietario;
  final double valorSeguroAuto;
  final String modeloAuto;
  final int edadPropietario;
  final int accidentes;

  PolizaRequest({
    required this.propietario,
    required this.valorSeguroAuto,
    required this.modeloAuto,
    required this.edadPropietario,
    required this.accidentes,
  });

  Map<String, dynamic> toJson() => {
    'propietario': propietario,
    'valorSeguroAuto': valorSeguroAuto,
    'modeloAuto': modeloAuto,
    'edadPropietario': edadPropietario,
    'accidentes': accidentes,
  };
}

class PolizaResponse {
  final String propietario;
  final String modeloAuto;
  final double valorSeguroAuto;
  final int edadPropietario;
  final int accidentes;
  final double costoTotal;

  PolizaResponse({
    required this.propietario,
    required this.modeloAuto,
    required this.valorSeguroAuto,
    required this.edadPropietario,
    required this.accidentes,
    required this.costoTotal,
  });

  factory PolizaResponse.fromJson(Map<String, dynamic> json) => PolizaResponse(
    propietario: json['propietario'] ?? '',
    modeloAuto: json['modeloAuto'] ?? 'A',
    valorSeguroAuto: (json['valorSeguroAuto'] ?? 0).toDouble(),
    edadPropietario: json['edadPropietario'] ?? 18,
    accidentes: json['accidentes'] ?? 0,
    costoTotal: (json['costoTotal'] ?? 0).toDouble(),
  );
}