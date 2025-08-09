import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/nota.dart';
import 'nota_form_view.dart';
import '../services/note_service.dart';

class NotaListView extends StatefulWidget {
  final Student student;

  const NotaListView({Key? key, required this.student}) : super(key: key);

  @override
  State<NotaListView> createState() => _NotaListViewState();
}

class _NotaListViewState extends State<NotaListView> {
  final NotaService _notaService = NotaService();

  final _asignaturaController = TextEditingController();
  final _valorController = TextEditingController();

  @override
  void dispose() {
    _asignaturaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _addNota() async {
    final asignatura = _asignaturaController.text.trim();
    final valor = double.tryParse(_valorController.text.trim());

    if (asignatura.isEmpty || valor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos válidos')),
      );
      return;
    }

    final nota = Nota(id: '', asignatura: asignatura, valor: valor);

    await _notaService.addNota(widget.student.id, nota);

    _asignaturaController.clear();
    _valorController.clear();
  }

  void _deleteNota(String id) async {
    await _notaService.deleteNota(widget.student.id, id);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue.shade300),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        title: Text(
          'Notas de ${widget.student.name}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Formulario para agregar nota
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _asignaturaController,
                    decoration: InputDecoration(
                      labelText: 'Asignatura',
                      labelStyle: TextStyle(color: primaryColor),
                      focusedBorder: inputBorder.copyWith(
                          borderSide: BorderSide(color: primaryColor, width: 2)),
                      enabledBorder: inputBorder,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _valorController,
                    decoration: InputDecoration(
                      labelText: 'Nota',
                      labelStyle: TextStyle(color: primaryColor),
                      focusedBorder: inputBorder.copyWith(
                          borderSide: BorderSide(color: primaryColor, width: 2)),
                      enabledBorder: inputBorder,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _addNota,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: primaryColor.withOpacity(0.6),
                      ),
                      child: const Text(
                        'Agregar Nota',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Lista de notas
            Expanded(
              child: StreamBuilder<List<Nota>>(
                stream: _notaService.getNotas(widget.student.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final notas = snapshot.data ?? [];
                  if (notas.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay notas',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: notas.length,
                    itemBuilder: (context, index) {
                      final nota = notas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          title: Text(
                            nota.asignatura,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          subtitle: Text(
                            'Nota: ${nota.valor}',
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: primaryColor),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NotaFormView(
                                        studentId: widget.student.id,
                                        nota: nota,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {}); // recarga la lista
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _deleteNota(nota.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
