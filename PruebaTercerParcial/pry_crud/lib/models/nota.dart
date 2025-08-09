class Nota {
  String id;
  String asignatura;
  double valor;

  Nota({required this.id, required this.asignatura, required this.valor});

  factory Nota.fromMap(Map<String, dynamic> data, String documentId) {
    return Nota(
      id: documentId,
      asignatura: data['asignatura'] ?? '',
      valor: (data['valor'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'asignatura': asignatura,
      'valor': valor,
    };
  }
}
