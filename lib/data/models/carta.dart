import 'package:cloud_firestore/cloud_firestore.dart';

class Carta {
  final String id;
  final String autorId;
  final String destinatarioId;
  final String titulo;
  final String contenido;
  final bool leida;
  final DateTime? creadoEn;

  const Carta({
    required this.id,
    required this.autorId,
    required this.destinatarioId,
    required this.titulo,
    required this.contenido,
    required this.leida,
    this.creadoEn,
  });

  factory Carta.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Carta(
      id: doc.id,
      autorId: data['autorId'] as String,
      destinatarioId: data['destinatarioId'] as String,
      titulo: data['titulo'] as String? ?? '',
      contenido: data['contenido'] as String,
      leida: data['leida'] as bool? ?? false,
      creadoEn: (data['creadoEn'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'autorId': autorId,
    'destinatarioId': destinatarioId,
    'titulo': titulo,
    'contenido': contenido,
    'leida': leida,
    'creadoEn': creadoEn == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(creadoEn!),
  };
}