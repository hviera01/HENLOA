import 'package:flutter/material.dart';

import '../../core/session/session.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import 'mi_lista_tab.dart';
import 'su_lista_tab.dart';
import 'evaluar_tab.dart';

class NuestraListaScreen extends StatefulWidget {
  final int tabInicial;
  final VoidCallback onVolver;

  const NuestraListaScreen({
    super.key,
    this.tabInicial = 0,
    required this.onVolver,
  });

  @override
  State<NuestraListaScreen> createState() => _NuestraListaScreenState();
}

class _NuestraListaScreenState extends State<NuestraListaScreen> {
  late int _tab = widget.tabInicial;

  @override
  void didUpdateWidget(covariant NuestraListaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabInicial != oldWidget.tabInicial) {
      setState(() => _tab = widget.tabInicial);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final yo = session.usuarioActual!;
    final pareja = session.parejaActual!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onVolver,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Text('Nuestra lista', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SegmentoTabs(
            opciones: ['Mi lista', 'De ${nombresUsuario[pareja]}', 'Evaluar'],
            indice: _tab,
            onCambiar: (i) => setState(() => _tab = i),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          // IndexedStack: mantiene las tres pestañas montadas para no perder
          // la suscripción a Firestore (y volver a "cargando") al alternar.
          child: IndexedStack(
            sizing: StackFit.expand,
            index: _tab,
            children: [
              MiListaTab(usuarioId: yo),
              SuListaTab(usuarioId: pareja, nombre: nombresUsuario[pareja]!),
              EvaluarTab(yo: yo, pareja: pareja, nombrePareja: nombresUsuario[pareja]!),
            ],
          ),
        ),
      ],
    );
  }
}

class _SegmentoTabs extends StatelessWidget {
  final List<String> opciones;
  final int indice;
  final ValueChanged<int> onCambiar;

  const _SegmentoTabs({required this.opciones, required this.indice, required this.onCambiar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.papel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.trazo),
      ),
      child: Row(
        children: List.generate(opciones.length, (i) {
          final seleccionado = i == indice;
          return Expanded(
            child: GestureDetector(
              onTap: () => onCambiar(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: seleccionado ? AppColors.terracota : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  opciones[i],
                  style: TextStyle(
                    color: seleccionado ? Colors.white : AppColors.tintaSuave,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
