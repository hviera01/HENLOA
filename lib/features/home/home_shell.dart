import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../buzon/buzon_screen.dart';
import '../deseos/deseos_screen.dart';
import '../inicio/inicio_screen.dart';
import '../lista/nuestra_lista_screen.dart';
import '../progreso/progreso_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indice = 0;

  static const _secciones = [
    _Seccion('Inicio', Icons.home_filled),
    _Seccion('Lista', Icons.checklist_rounded),
    _Seccion('Progreso', Icons.insights_rounded),
    _Seccion('Deseos', Icons.auto_awesome_rounded),
    _Seccion('Buzón', Icons.mail_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final paginas = [
      InicioScreen(onVerSeccion: (i) => setState(() => _indice = i)),
      const NuestraListaScreen(),
      const ProgresoScreen(),
      const DeseosScreen(),
      const BuzonScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: IndexedStack(
              sizing: StackFit.expand,
              index: _indice,
              children: paginas,
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BarraInferior(
        secciones: _secciones,
        indice: _indice,
        onCambiar: (i) => setState(() => _indice = i),
        nombreUsuario: session.usuarioActual,
      ),
    );
  }
}

class _Seccion {
  final String titulo;
  final IconData icono;
  const _Seccion(this.titulo, this.icono);
}

class _BarraInferior extends StatelessWidget {
  final List<_Seccion> secciones;
  final int indice;
  final ValueChanged<int> onCambiar;
  final String? nombreUsuario;

  const _BarraInferior({
    required this.secciones,
    required this.indice,
    required this.onCambiar,
    required this.nombreUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.papel,
        border: Border(top: BorderSide(color: AppColors.trazo)),
      ),
      child: SafeArea(
        top: false,
        // UnconstrainedBox (no Center/Align) a propósito: Scaffold mide la
        // altura de bottomNavigationBar dándole un límite generoso, y
        // Center/Align se EXPANDEN a llenar constraints acotadas — eso
        // inflaba esta barra a casi toda la pantalla. UnconstrainedBox solo
        // acota el ancho y deja que la altura la decida el contenido.
        child: UnconstrainedBox(
          constrainedAxis: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(secciones.length, (i) {
                  final seleccionado = i == indice;
                  final color = seleccionado
                      ? AppColors.colorDePersona(nombreUsuario ?? 'henry')
                      : AppColors.tintaSuave;
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onCambiar(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(secciones[i].icono, color: color, size: 22),
                          const SizedBox(height: 4),
                          Text(
                            secciones[i].titulo,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: seleccionado
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}