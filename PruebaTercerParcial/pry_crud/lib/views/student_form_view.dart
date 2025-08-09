import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_service.dart';

class StudentFormView extends StatefulWidget {
  final Student? student;

  const StudentFormView({Key? key, this.student}) : super(key: key);

  @override
  State<StudentFormView> createState() => _StudentFormViewState();
}

class _StudentFormViewState extends State<StudentFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  final StudentService _service = StudentService();

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _nameController.text = widget.student!.name;
      _ageController.text = widget.student!.age.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final age = int.parse(_ageController.text.trim());

    try {
      if (widget.student == null) {
        await _service.addStudent(Student(id: '', name: name, age: age));
        _showSnackbar('Estudiante agregado exitosamente', Colors.green);
      } else {
        await _service.updateStudent(Student(id: widget.student!.id, name: name, age: age));
        _showSnackbar('Estudiante actualizado', Colors.green);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackbar('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
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
          isEditing ? 'Editar Estudiante' : 'Nuevo Estudiante',
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
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese un nombre';
                  }
                  if (value.trim().length < 2) {
                    return 'El nombre es demasiado corto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Edad',
                  labelStyle: TextStyle(color: primaryColor),
                  focusedBorder: inputBorder.copyWith(
                      borderSide: BorderSide(color: primaryColor, width: 2)),
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16),
                validator: (value) {
                  final edad = int.tryParse(value?.trim() ?? '');
                  if (edad == null) return 'Ingrese una edad válida';
                  if (edad <= 0 || edad > 120) return 'Edad fuera de rango (1–120)';
                  return null;
                },
              ),
              const SizedBox(height: 36),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
