import 'package:cloud_firestore/cloud_firestore.dart';

/// La autoevaluación (1-10) de [evaluadoPor] sobre un [itemId] de la lista
/// de su pareja, para la semana [semanaId].
class Evaluacion {
  final String id;
  final String itemId;
  final String semanaId;
  final String evaluadoPor;
  final int calificacion;
  final DateTime? actualizadoEn;

  const Evaluacion({
    required this.id,
    required this.itemId,
    required this.semanaId,
    required this.evaluadoPor,
    required this.calificacion,
    this.actualizadoEn,
  });

  static String idPara({
    required String itemId,
    required String semanaId,
  }) => '${semanaId}_$itemId';

  factory Evaluacion.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Evaluacion(
      id: doc.id,
      itemId: data['itemId'] as String,
      semanaId: data['semanaId'] as String,
      evaluadoPor: data['evaluadoPor'] as String,
      calificacion: data['calificacion'] as int,
      actualizadoEn: (data['actualizadoEn'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'itemId': itemId,
    'semanaId': semanaId,
    'evaluadoPor': evaluadoPor,
    'calificacion': calificacion,
    'actualizadoEn': FieldValue.serverTimestamp(),
  };
}