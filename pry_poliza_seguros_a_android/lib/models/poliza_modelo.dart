class Poliza {
  final String propietario;
  final double valorSeguroAuto;
  final String modeloAuto;
  final String edadPropietario;
  final int accidentes;
  final double costoTotal;

  Poliza({
    required this.propietario,
    required this.valorSeguroAuto,
    required this.modeloAuto,
    required this.edadPropietario,
    required this.accidentes,
    required this.costoTotal,
  });

  factory Poliza.fromJson(Map<String, dynamic> json) => Poliza(
    propietario: json['propietario'],
    valorSeguroAuto: json['valorSeguroAuto'],
    modeloAuto: json['modeloAuto'],
    edadPropietario: json['edadPropietario'],
    accidentes: json['accidentes'],
    costoTotal: json['costoTotal'],
  );

  Map<String, dynamic> toJson() => {
    'propietario': propietario,
    'valorSeguroAuto': valorSeguroAuto,
    'modeloAuto': modeloAuto,
    'edadPropietario': edadPropietario,
    'accidentes': accidentes,
    'costoTotal': costoTotal,
  };
}