import 'package:cloud_firestore/cloud_firestore.dart';

/// Un punto en la lista de expectativas que [autorId] escribió sobre lo que
/// espera de su pareja. Cada sábado, la pareja se autoevalúa sobre esto.
class ItemLista {
  final String id;
  final String autorId;
  final String texto;
  final bool activo;
  final int orden;
  final DateTime? creadoEn;

  const ItemLista({
    required this.id,
    required this.autorId,
    required this.texto,
    required this.activo,
    required this.orden,
    this.creadoEn,
  });

  factory ItemLista.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ItemLista(
      id: doc.id,
      autorId: data['autorId'] as String,
      texto: data['texto'] as String,
      activo: data['activo'] as bool? ?? true,
      orden: data['orden'] as int? ?? 0,
      creadoEn: (data['creadoEn'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'autorId': autorId,
    'texto': texto,
    'activo': activo,
    'orden': orden,
    'creadoEn': creadoEn == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(creadoEn!),
  };
}