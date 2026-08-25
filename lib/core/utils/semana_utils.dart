import 'package:intl/intl.dart';

/// La semana se identifica por la fecha del lunes con el que inicia
/// (formato yyyy-MM-dd), y se evalúa idealmente el sábado de esa semana.
class SemanaUtils {
  SemanaUtils._();

  static DateTime lunesDeSemana(DateTime fecha) {
    final soloFecha = DateTime(fecha.year, fecha.month, fecha.day);
    return soloFecha.subtract(Duration(days: soloFecha.weekday - 1));
  }

  static String idDeSemana(DateTime fecha) =>
      DateFormat('yyyy-MM-dd').format(lunesDeSemana(fecha));

  static String idSemanaActual() => idDeSemana(DateTime.now());

  static DateTime sabadoDeSemana(DateTime fecha) =>
      lunesDeSemana(fecha).add(const Duration(days: 5));

  static bool esHoySabado() => DateTime.now().weekday == DateTime.saturday;

  static String etiquetaSemana(String semanaId) {
    final lunes = DateTime.parse(semanaId);
    final sabado = lunes.add(const Duration(days: 5));
    final formato = DateFormat('d MMM', 'es');
    return '${formato.format(lunes)} – ${formato.format(sabado)}';
  }

  static String idSemanaAnterior(String semanaId) {
    final lunes = DateTime.parse(semanaId);
    return idDeSemana(lunes.subtract(const Duration(days: 7)));
  }
}
