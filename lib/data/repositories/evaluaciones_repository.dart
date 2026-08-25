import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/evaluacion.dart';

class EvaluacionesRepository {
  final _col = FirebaseFirestore.instance.collection('evaluaciones');

  Stream<List<Evaluacion>> observarPorSemanaYEvaluador(
    String semanaId,
    String evaluadoPor,
  ) {
    return _col
        .where('semanaId', isEqualTo: semanaId)
        .where('evaluadoPor', isEqualTo: evaluadoPor)
        .snapshots()
        .map((s) => s.docs.map(Evaluacion.fromDoc).toList());
  }

  Future<void> calificar({
    required String itemId,
    required String semanaId,
    required String evaluadoPor,
    required int calificacion,
  }) {
    final id = Evaluacion.idPara(itemId: itemId, semanaId: semanaId);
    return _col.doc(id).set(
      Evaluacion(
        id: id,
        itemId: itemId,
        semanaId: semanaId,
        evaluadoPor: evaluadoPor,
        calificacion: calificacion,
      ).toMap(),
      SetOptions(merge: true),
    );
  }

  /// Historial de promedios semanales de [evaluadoPor], últimas [limite] semanas con datos.
  Future<List<MapEntry<String, List<Evaluacion>>>> historialPorEvaluador(
    String evaluadoPor, {
    int limite = 12,
  }) async {
    final snap = await _col
        .where('evaluadoPor', isEqualTo: evaluadoPor)
        .orderBy('semanaId', descending: true)
        .limit(limite * 20)
        .get();
    final porSemana = <String, List<Evaluacion>>{};
    for (final doc in snap.docs) {
      final ev = Evaluacion.fromDoc(doc);
      porSemana.putIfAbsent(ev.semanaId, () => []).add(ev);
    }
    final semanas = porSemana.keys.toList()..sort((a, b) => b.compareTo(a));
    return semanas
        .take(limite)
        .map((s) => MapEntry(s, porSemana[s]!))
        .toList();
  }
}
