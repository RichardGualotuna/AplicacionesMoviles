import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentService {
  final CollectionReference _students =
  FirebaseFirestore.instance.collection('estudiantes');

  Stream<List<Student>> getStudents({
    String? searchQuery,
    DocumentSnapshot? startAfterDoc,
    int limit = 5,
  }) {
    Query query = _students.orderBy('name').limit(limit);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final int? age = int.tryParse(searchQuery);
      if (age != null) {
        query = query.where('age', isEqualTo: age);
      } else {
        query = query
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
      }
    }

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Student.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addStudent(Student student) {
    _validateStudent(student);
    return _students.add(student.toMap());
  }

  Future<void> updateStudent(Student student) {
    if (student.id.isEmpty) {
      throw Exception('ID requerido para actualizar');
    }
    _validateStudent(student);
    return _students.doc(student.id).update(student.toMap());
  }

  Future<void> deleteStudent(String id) {
    if (id.isEmpty) throw Exception('ID requerido para eliminar');
    return _students.doc(id).delete();
  }
  Future<DocumentSnapshot> getDocumentSnapshotById(String id) {
    return _students.doc(id).get();
  }


  void _validateStudent(Student student) {
    if (student.name.trim().isEmpty) {
      throw Exception('El nombre no puede estar vacío');
    }
    if (student.name.length < 2) {
      throw Exception('El nombre es demasiado corto');
    }
    if (student.age <= 0 || student.age > 120) {
      throw Exception('Edad inválida. Debe estar entre 1 y 120');
    }
  }
}
