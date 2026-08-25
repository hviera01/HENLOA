import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/item.dart';

class ItemsRepository {
  final _col = FirebaseFirestore.instance.collection('items');

  Stream<List<ItemLista>> observarListaDe(String autorId) {
    return _col
        .where('autorId', isEqualTo: autorId)
        .orderBy('orden')
        .snapshots()
        .map((s) => s.docs.map(ItemLista.fromDoc).toList());
  }

  Future<void> agregar(String autorId, String texto, int orden) {
    return _col.add(
      ItemLista(
        id: '',
        autorId: autorId,
        texto: texto,
        activo: true,
        orden: orden,
      ).toMap(),
    );
  }

  Future<void> editarTexto(String id, String texto) {
    return _col.doc(id).update({'texto': texto});
  }

  Future<void> cambiarActivo(String id, bool activo) {
    return _col.doc(id).update({'activo': activo});
  }

  Future<void> eliminar(String id) {
    return _col.doc(id).delete();
  }
}