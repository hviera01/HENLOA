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

  // MultiPage (no Page): una carta larga tiene que poder repartirse en
  // varias hojas en vez de recortarse en la primera.
  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(46, 40, 46, 34),
        buildBackground: (context) => pw.Container(color: _crema),
      ),
      header: (context) {
        if (context.pageNumber > 1) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 14),
            child: pw.Text(
              nombreDestinatario,
              style: pw.TextStyle(
                font: serifItalica,
                fontSize: 10,
                color: PdfColors.grey500,
              ),
            ),
          );
        }
        return pw.Column(
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
            pw.SizedBox(height: 26),
            if (carta.titulo.trim().isNotEmpty) ...[
              pw.Text(
                carta.titulo,
                style: pw.TextStyle(font: serifItalica, fontSize: 24, color: _terracota),
              ),
              pw.SizedBox(height: 16),
            ],
          ],
        );
      },
      footer: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 10),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'HENLOA',
              style: pw.TextStyle(
                font: serifRegular,
                fontSize: 8,
                letterSpacing: 3,
                color: _oro,
              ),
            ),
            pw.Text(
              '${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(font: serifRegular, fontSize: 8.5, color: PdfColors.grey500),
            ),
          ],
        ),
      ),
      build: (context) => [
        pw.Text(
          carta.contenido,
          textAlign: pw.TextAlign.left,
          overflow: pw.TextOverflow.span,
          style: pw.TextStyle(
            font: serifRegular,
            fontSize: 13.5,
            color: _tinta,
            lineSpacing: 5,
          ),
        ),
        pw.SizedBox(height: 26),
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
      ],
    ),
  );

  return doc;
}
