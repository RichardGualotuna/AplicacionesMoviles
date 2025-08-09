import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import 'student_form_view.dart';
import 'nota_list_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListView extends StatefulWidget {
  const StudentListView({Key? key}) : super(key: key);

  @override
  State<StudentListView> createState() => _StudentListViewState();
}

class _StudentListViewState extends State<StudentListView> {
  final StudentService _service = StudentService();

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<Student> _students = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _loading = false;
  String _search = '';

  void _loadStudents({bool clear = false}) async {
    if (_loading) return;
    if (!_hasMore && !clear) return;

    setState(() => _loading = true);

    final studentsStream = _service.getStudents(
      searchQuery: _search,
      startAfterDoc: clear ? null : _lastDocument,
      limit: 5,
    );

    final newStudents = await studentsStream.first;

    if (mounted) {
      setState(() {
        if (clear) {
          // Si limpio, reinicio AnimatedList también
          final oldLength = _students.length;
          for (int i = oldLength - 1; i >= 0; i--) {
            _listKey.currentState?.removeItem(
              i,
                  (context, animation) => SizeTransition(
                sizeFactor: animation,
                child: _buildStudentTile(_students[i], i),
              ),
              duration: const Duration(milliseconds: 300),
            );
          }
          _students = newStudents;
          for (int i = 0; i < _students.length; i++) {
            _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 300));
          }
        } else {
          final insertStartIndex = _students.length;
          _students.addAll(newStudents);
          for (int i = 0; i < newStudents.length; i++) {
            _listKey.currentState?.insertItem(insertStartIndex + i,
                duration: const Duration(milliseconds: 300));
          }
        }
        _loading = false;
        _hasMore = newStudents.length == 5;
      });

      if (newStudents.isNotEmpty) {
        final lastStudent = newStudents.last;
        _lastDocument = await _service.getDocumentSnapshotById(lastStudent.id);
      }
    }
  }

  void _onSearchChanged(String value) {
    _search = value;
    _lastDocument = null;
    _hasMore = true;
    _loadStudents(clear: true);
  }

  Future<void> _deleteStudent(int index) async {
    final student = _students[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Deseas eliminar a ${student.name}?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Eliminar'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deleteStudent(student.id);

      // Animación al eliminar
      final removedStudent = _students.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
            (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: _buildStudentTile(removedStudent, index),
        ),
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Widget _buildStudentTile(Student student, int index) {
    final primaryColor = Colors.blue.shade700;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        subtitle: Text(
          'Edad: ${student.age}',
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.note, color: primaryColor),
              tooltip: 'Notas',
              onPressed: () => _navigateWithFade(context, NotaListView(student: student)),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: primaryColor),
              tooltip: 'Editar',
              onPressed: () async {
                final edited = await _navigateWithFade(context, StudentFormView(student: student));
                if (edited == true) {
                  // Refrescar lista
                  _loadStudents(clear: true);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: 'Eliminar',
              onPressed: () => _deleteStudent(index),
            ),
          ],
        ),
      ),
    );
  }

  Future<T?> _navigateWithFade<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadStudents(clear: true);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        title: const Text(
          'Estudiantes',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por nombre o edad',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.blue.shade50,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _students.length,
                itemBuilder: (context, index, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: _buildStudentTile(_students[index], index),
                  );
                },
              ),
            ),
            if (_hasMore)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TextButton(
                  onPressed: _loading ? null : () => _loadStudents(clear: false),
                  style: TextButton.styleFrom(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                      : Text(
                    'Cargar más',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        elevation: 6,
        onPressed: () async {
          final created = await _navigateWithFade(context, const StudentFormView());
          if (created == true) _loadStudents(clear: true);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
