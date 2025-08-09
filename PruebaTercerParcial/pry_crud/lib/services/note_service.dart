import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nota.dart';

class NotaService {
  CollectionReference getNotasRef(String studentId) {
    return FirebaseFirestore.instance
        .collection('estudiantes')
        .doc(studentId)
        .collection('notas');
  }

  Stream<List<Nota>> getNotas(String studentId) {
    return getNotasRef(studentId).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Nota.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> addNota(String studentId, Nota nota) {
    return getNotasRef(studentId).add(nota.toMap());
  }

  Future<void> deleteNota(String studentId, String notaId) {
    return getNotasRef(studentId).doc(notaId).delete();
  }
  Future<void> updateNota(String studentId, Nota nota) {
    return getNotasRef(studentId).doc(nota.id).update(nota.toMap());
  }

}
