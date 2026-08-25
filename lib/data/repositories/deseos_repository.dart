import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/deseo.dart';

class DeseosRepository {
  final _col = FirebaseFirestore.instance.collection('deseos');

  Stream<List<Deseo>> observarDe(String autorId) {
    return _col
        .where('autorId', isEqualTo: autorId)
        .orderBy('creadoEn', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Deseo.fromDoc).toList());
  }

  Future<void> agregar(String autorId, String texto) {
    return _col.add(
      Deseo(id: '', autorId: autorId, texto: texto, cumplido: false).toMap(),
    );
  }

  Future<void> marcarCumplido(String id, bool cumplido) {
    return _col.doc(id).update({'cumplido': cumplido});
  }

  Future<void> eliminar(String id) {
    return _col.doc(id).delete();
  }
}
