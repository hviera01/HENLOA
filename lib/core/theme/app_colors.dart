import 'package:flutter/material.dart';

/// Paleta cálida y editorial para Henloa — nada de morados/azules genéricos.
class AppColors {
  AppColors._();

  static const Color fondo = Color(0xFFFBF3EA);
  static const Color papel = Color(0xFFFFFBF5);
  static const Color tarjeta = Color(0xFFFFF7EE);

  static const Color terracota = Color(0xFFB5482B);
  static const Color terracotaOscuro = Color(0xFF8A3620);
  static const Color vino = Color(0xFF5B2333);
  static const Color vinoOscuro = Color(0xFF3E1622);
  static const Color oro = Color(0xFFC79A45);
  static const Color oroClaro = Color(0xFFE4C889);

  static const Color tintaFuerte = Color(0xFF2E1E1A);
  static const Color tintaSuave = Color(0xFF8A7268);
  static const Color trazo = Color(0xFFE3D2C0);

  static const Color henry = Color(0xFFB5482B);
  static const Color loany = Color(0xFF5B2333);

  // Rangos de calificación 1–10
  static const Color rangoMalo = Color(0xFFA6433B);
  static const Color rangoRegular = Color(0xFFCB9A45);
  static const Color rangoBien = Color(0xFF7C8F5B);
  static const Color rangoExcelente = Color(0xFF3F6B4A);

  static Color colorDePersona(String usuarioId) =>
      usuarioId == 'henry' ? henry : loany;
}
