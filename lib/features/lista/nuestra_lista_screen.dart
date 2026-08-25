import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import 'mi_lista_tab.dart';
import 'evaluarme_tab.dart';

class NuestraListaScreen extends StatefulWidget {
  const NuestraListaScreen({super.key});

  @override
  State<NuestraListaScreen> createState() => _NuestraListaScreenState();
}

class _NuestraListaScreenState extends State<NuestraListaScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final yo = session.usuarioActual!;
    final pareja = session.parejaActual!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nuestra lista', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SegmentoTabs(
            opciones: const ['Mi lista', 'Evaluarme'],
            indice: _tab,
            onCambiar: (i) => setState(() => _tab = i),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _tab == 0
              ? MiListaTab(usuarioId: yo)
              : EvaluarmeTab(yo: yo, pareja: pareja),
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