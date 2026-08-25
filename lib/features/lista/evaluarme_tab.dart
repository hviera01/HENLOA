import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/rango_utils.dart';
import '../../core/utils/semana_utils.dart';
import '../../data/models/evaluacion.dart';
import '../../data/models/item.dart';
import '../../data/repositories/evaluaciones_repository.dart';
import '../../data/repositories/items_repository.dart';

class EvaluarmeTab extends StatelessWidget {
  final String yo;
  final String pareja;
  const EvaluarmeTab({super.key, required this.yo, required this.pareja});

  @override
  Widget build(BuildContext context) {
    final itemsRepo = ItemsRepository();
    final evalRepo = EvaluacionesRepository();
    final semanaId = SemanaUtils.idSemanaActual();

    return StreamBuilder<List<ItemLista>>(
      stream: itemsRepo.observarListaDe(pareja),
      builder: (context, itemsSnap) {
        final items = (itemsSnap.data ?? []).where((i) => i.activo).toList();
        return StreamBuilder<List<Evaluacion>>(
          stream: evalRepo.observarPorSemanaYEvaluador(semanaId, yo),
          builder: (context, evalSnap) {
            final evaluaciones = {
              for (final e in evalSnap.data ?? <Evaluacion>[]) e.itemId: e,
            };

            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Tu pareja todavía no escribió su lista.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.tintaSuave),
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                Text(
                  'Calificá del 1 al 10 cómo te fue esta semana en cada punto de la lista de tu pareja.',
                  style: const TextStyle(color: AppColors.tintaSuave, fontSize: 12.5),
                ),
                const SizedBox(height: 6),
                Text(
                  SemanaUtils.etiquetaSemana(semanaId),
                  style: const TextStyle(
                    color: AppColors.terracota,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _FilaCalificar(
                      item: item,
                      calificacionActual: evaluaciones[item.id]?.calificacion,
                      onCalificar: (valor) => evalRepo.calificar(
                        itemId: item.id,
                        semanaId: semanaId,
                        evaluadoPor: yo,
                        calificacion: valor,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FilaCalificar extends StatelessWidget {
  final ItemLista item;
  final int? calificacionActual;
  final ValueChanged<int> onCalificar;

  const _FilaCalificar({
    required this.item,
    required this.calificacionActual,
    required this.onCalificar,
  });

  @override
  Widget build(BuildContext context) {
    final valor = calificacionActual;
    final rango = valor == null ? null : rangoDe(valor.toDouble());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.trazo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.texto,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (rango?.color ?? AppColors.trazo).withValues(
                    alpha: rango == null ? 0.4 : 0.14,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  valor?.toString() ?? '–',
                  style: TextStyle(
                    color: rango?.color ?? AppColors.tintaSuave,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: rango?.color ?? AppColors.terracota,
              inactiveTrackColor: AppColors.trazo,
              thumbColor: rango?.color ?? AppColors.terracota,
              overlayColor: (rango?.color ?? AppColors.terracota).withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: (valor ?? 5).toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: (valor ?? 5).toString(),
              onChanged: (v) => onCalificar(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}