import 'package:flutter/material.dart';

import '../../core/session/session.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/semana_utils.dart';
import '../../data/repositories/evaluaciones_repository.dart';
import '../../data/repositories/items_repository.dart';
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
  int _listaTabSolicitado = 0;
  bool _revisoRecordatorio = false;

  static const _secciones = [
    _Seccion('Inicio', Icons.home_filled),
    _Seccion('Lista', Icons.checklist_rounded),
    _Seccion('Progreso', Icons.insights_rounded),
    _Seccion('Deseos', Icons.auto_awesome_rounded),
    _Seccion('Buzón', Icons.mail_rounded),
  ];

  void _irAInicio() => setState(() => _indice = 0);

  void _irAEvaluar() {
    setState(() {
      _indice = 1;
      _listaTabSolicitado = 1;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_revisoRecordatorio) {
      _revisoRecordatorio = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _revisarRecordatorioSabado());
    }
  }

  Future<void> _revisarRecordatorioSabado() async {
    if (!SemanaUtils.esHoySabado()) return;
    if (!mounted) return;
    final session = SessionScope.of(context);
    final yo = session.usuarioActual!;
    final pareja = session.parejaActual!;
    final semanaId = SemanaUtils.idSemanaActual();

    final items = await ItemsRepository().observarListaDe(pareja).first;
    final evals = await EvaluacionesRepository()
        .observarPorSemanaYEvaluador(semanaId, yo)
        .first;
    final pendientes = items.where((i) => i.activo).length - evals.length;
    if (pendientes <= 0 || !mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.papel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¡Hoy es sábado!'),
        content: Text(
          'Te faltan $pendientes punto${pendientes == 1 ? '' : 's'} por calificar '
          'de la lista de ${nombresUsuario[pareja]} esta semana.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Después'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _irAEvaluar();
            },
            child: const Text('Evaluar ahora'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final paginas = [
      InicioScreen(
        onVerSeccion: (i) => setState(() => _indice = i),
        onEvaluarAhora: _irAEvaluar,
      ),
      NuestraListaScreen(tabInicial: _listaTabSolicitado, onVolver: _irAInicio),
      ProgresoScreen(onVolver: _irAInicio),
      DeseosScreen(onVolver: _irAInicio),
      BuzonScreen(onVolver: _irAInicio),
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
