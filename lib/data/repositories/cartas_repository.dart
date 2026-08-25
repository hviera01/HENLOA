import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/carta.dart';

class CartasRepository {
  final _col = FirebaseFirestore.instance.collection('cartas');

  Stream<List<Carta>> observarRecibidasPor(String destinatarioId) {
    return _col
        .where('destinatarioId', isEqualTo: destinatarioId)
        .orderBy('creadoEn', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Carta.fromDoc).toList());
  }

  Stream<List<Carta>> observarEnviadasPor(String autorId) {
    return _col
        .where('autorId', isEqualTo: autorId)
        .orderBy('creadoEn', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Carta.fromDoc).toList());
  }

  Future<void> enviar({
    required String autorId,
    required String destinatarioId,
    required String titulo,
    required String contenido,
  }) {
    return _col.add(
      Carta(
        id: '',
        autorId: autorId,
        destinatarioId: destinatarioId,
        titulo: titulo,
        contenido: contenido,
        leida: false,
      ).toMap(),
    );
  }

  Future<void> marcarLeida(String id) {
    return _col.doc(id).update({'leida': true});
  }

  Future<void> eliminar(String id) {
    return _col.doc(id).delete();
  }
}
