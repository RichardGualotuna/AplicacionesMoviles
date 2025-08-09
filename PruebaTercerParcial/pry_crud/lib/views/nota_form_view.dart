import 'package:flutter/material.dart';
import '../models/nota.dart';
import '../services/note_service.dart';

class NotaFormView extends StatefulWidget {
  final String studentId;
  final Nota? nota;

  const NotaFormView({Key? key, required this.studentId, this.nota}) : super(key: key);

  @override
  State<NotaFormView> createState() => _NotaFormViewState();
}

class _NotaFormViewState extends State<NotaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _asignaturaController = TextEditingController();
  final _valorController = TextEditingController();

  final NotaService _notaService = NotaService();

  @override
  void initState() {
    super.initState();
    if (widget.nota != null) {
      _asignaturaController.text = widget.nota!.asignatura;
      _valorController.text = widget.nota!.valor.toString();
    }
  }

  @override
  void dispose() {
    _asignaturaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final asignatura = _asignaturaController.text.trim();
    final valor = double.parse(_valorController.text.trim());

    final nota = Nota(
      id: widget.nota?.id ?? '',
      asignatura: asignatura,
      valor: valor,
    );

    if (widget.nota == null) {
      await _notaService.addNota(widget.studentId, nota);
    } else {
      await _notaService.updateNota(widget.studentId, nota);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.nota != null;

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
          isEditing ? 'Editar Nota' : 'Nueva Nota',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _asignaturaController,
                decoration: InputDecoration(
                  labelText: 'Asignatura',
                  labelStyle: TextStyle(color: primaryColor),
                  focusedBorder: inputBorder.copyWith(
                      borderSide: BorderSide(color: primaryColor, width: 2)),
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                style: const TextStyle(fontSize: 16),
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Ingrese asignatura válida (mínimo 3 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _valorController,
                decoration: InputDecoration(
                  labelText: 'Nota',
                  labelStyle: TextStyle(color: primaryColor),
                  focusedBorder: inputBorder.copyWith(
                      borderSide: BorderSide(color: primaryColor, width: 2)),
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 16),
                validator: (value) {
                  if (value == null || double.tryParse(value.trim()) == null) {
                    return 'Ingrese una nota válida';
                  }
                  final nota = double.parse(value.trim());
                  if (nota < 0 || nota > 20) {
                    return 'La nota debe estar entre 0 y 20';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: primaryColor.withOpacity(0.6),
                  ),
                  child: Text(
                    isEditing ? 'Actualizar' : 'Guardar',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
