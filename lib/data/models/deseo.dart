import 'package:cloud_firestore/cloud_firestore.dart';

class Deseo {
  final String id;
  final String autorId;
  final String texto;
  final bool cumplido;
  final DateTime? creadoEn;

  const Deseo({
    required this.id,
    required this.autorId,
    required this.texto,
    required this.cumplido,
    this.creadoEn,
  });

  factory Deseo.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Deseo(
      id: doc.id,
      autorId: data['autorId'] as String,
      texto: data['texto'] as String,
      cumplido: data['cumplido'] as bool? ?? false,
      creadoEn: (data['creadoEn'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'autorId': autorId,
    'texto': texto,
    'cumplido': cumplido,
    'creadoEn': creadoEn == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(creadoEn!),
  };
}