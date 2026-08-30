import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/carta.dart';

const _terracota = PdfColor.fromInt(0xFFB5482B);
const _vino = PdfColor.fromInt(0xFF5B2333);
const _oro = PdfColor.fromInt(0xFFC79A45);
const _crema = PdfColor.fromInt(0xFFFBF3EA);
const _tinta = PdfColor.fromInt(0xFF2E1E1A);

const _padHorizontal = pw.EdgeInsets.symmetric(horizontal: 46);

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
  //
  // Margin en cero a propósito: buildBackground solo pinta el área DENTRO
  // del margen del PageTheme, así que con margen quedaba un borde blanco
  // sin cubrir alrededor. El espaciado se agrega a mano en cada widget.
  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        buildBackground: (context) => pw.Container(color: _crema),
      ),
      header: (context) {
        if (context.pageNumber > 1) {
          return pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(46, 34, 46, 14),
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
        return pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(46, 40, 46, 0),
          child: pw.Column(
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
          ),
        );
      },
      footer: (context) => pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(46, 10, 46, 26),
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
        pw.Padding(
          padding: _padHorizontal,
          child: pw.Text(
            carta.contenido,
            textAlign: pw.TextAlign.justify,
            overflow: pw.TextOverflow.span,
            style: pw.TextStyle(
              font: serifRegular,
              fontSize: 13.5,
              color: _tinta,
              lineSpacing: 5,
            ),
          ),
        ),
        pw.Padding(
          padding: _padHorizontal,
          child: pw.SizedBox(height: 26),
        ),
        pw.Padding(
          padding: _padHorizontal,
          child: pw.Row(
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
        ),
      ],
    ),
  );

  return doc;
}
