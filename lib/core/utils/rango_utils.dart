import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RangoCalificacion {
  final String etiqueta;
  final Color color;

  const RangoCalificacion(this.etiqueta, this.color);
}

/// Escala 1–10: 1-3 malo, 4-6 regular, 7-8 bien, 9-10 excelente.
RangoCalificacion rangoDe(double promedio) {
  if (promedio < 4) {
    return const RangoCalificacion('Necesita atención', AppColors.rangoMalo);
  } else if (promedio < 7) {
    return const RangoCalificacion('Regular', AppColors.rangoRegular);
  } else if (promedio < 9) {
    return const RangoCalificacion('Bien', AppColors.rangoBien);
  }
  return const RangoCalificacion('Excelente', AppColors.rangoExcelente);
}
