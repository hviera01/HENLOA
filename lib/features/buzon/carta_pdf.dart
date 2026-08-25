import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/carta.dart';

const _terracota = PdfColor.fromInt(0xFFB5482B);
const _vino = PdfColor.fromInt(0xFF5B2333);
const _oro = PdfColor.fromInt(0xFFC79A45);
const _crema = PdfColor.fromInt(0xFFFBF3EA);
const _tinta = PdfColor.fromInt(0xFF2E1E1A);

Future<pw.Document> generarPdfCarta(Carta carta, String nombreAutor, String nombreDestinatario) async {
  final doc = pw.Document();
  final serifRegular = pw.Font.times();
  final serifItalica = pw.Font.timesItalic();
  final serifNegrita = pw.Font.timesBold();

  final fecha = carta.creadoEn == null
      ? ''
      : DateFormat("d 'de' MMMM 'de' yyyy", 'es').format(carta.creadoEn!);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (context) {
        return pw.Container(
          color: _crema,
          child: pw.Container(
            margin: const pw.EdgeInsets.all(28),
            padding: const pw.EdgeInsets.fromLTRB(40, 46, 40, 40),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _oro, width: 1.4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Container(width: 46, height: 1.2, color: _terracota),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'PARA $nombreDestinatario',
                        style: pw.TextStyle(
                          font: serifNegrita,
                          fontSize: 12,
                          letterSpacing: 3,
                          color: _vino,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(width: 46, height: 1.2, color: _terracota),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                if (carta.titulo.trim().isNotEmpty) ...[
                  pw.Text(
                    carta.titulo,
                    style: pw.TextStyle(font: serifItalica, fontSize: 26, color: _terracota),
                  ),
                  pw.SizedBox(height: 18),
                ],
                pw.Expanded(
                  child: pw.Text(
                    carta.contenido,
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      font: serifRegular,
                      fontSize: 13.5,
                      color: _tinta,
                      lineSpacing: 5,
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      fecha,
                      style: pw.TextStyle(font: serifRegular, fontSize: 10.5, color: PdfColors.grey600),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Con cariño,',
                          style: pw.TextStyle(font: serifItalica, fontSize: 12, color: _tinta),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          nombreAutor,
                          style: pw.TextStyle(font: serifItalica, fontSize: 20, color: _vino),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 18),
                pw.Center(
                  child: pw.Text(
                    'HENLOA',
                    style: pw.TextStyle(
                      font: serifRegular,
                      fontSize: 9,
                      letterSpacing: 4,
                      color: PdfColors.grey500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  return doc;
}