import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kUsuarioHenry = 'henry';
const String kUsuarioLoany = 'loany';

const Map<String, String> _codigos = {'5578': kUsuarioHenry, '1122': kUsuarioLoany};

const Map<String, String> nombresUsuario = {
  kUsuarioHenry: 'Henry',
  kUsuarioLoany: 'Loany',
};

String parejaDe(String usuarioId) =>
    usuarioId == kUsuarioHenry ? kUsuarioLoany : kUsuarioHenry;

class Session extends ChangeNotifier {
  static const _prefsKey = 'henloa_usuario_actual';

  String? _usuarioActual;
  bool _cargando = true;

  String? get usuarioActual => _usuarioActual;
  bool get cargando => _cargando;
  bool get haIniciadoSesion => _usuarioActual != null;
  String? get parejaActual =>
      _usuarioActual == null ? null : parejaDe(_usuarioActual!);

  Session() {
    _cargarSesionGuardada();
  }

  Future<void> _cargarSesionGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    _usuarioActual = prefs.getString(_prefsKey);
    _cargando = false;
    notifyListeners();
  }

  /// Devuelve el id de usuario si el código es válido, o null si no lo es.
  Future<String?> iniciarSesionConCodigo(String codigo) async {
    final usuario = _codigos[codigo.trim()];
    if (usuario == null) return null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, usuario);
    _usuarioActual = usuario;
    notifyListeners();
    return usuario;
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _usuarioActual = null;
    notifyListeners();
  }
}
