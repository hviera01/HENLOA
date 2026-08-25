import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/rango_utils.dart';
import '../../core/utils/semana_utils.dart';
import '../../data/models/evaluacion.dart';
import '../../data/models/item.dart';
import '../../data/repositories/evaluaciones_repository.dart';
import '../../data/repositories/items_repository.dart';

class EvaluarmeTab extends StatefulWidget {
  final String yo;
  final String pareja;
  const EvaluarmeTab({super.key, required this.yo, required this.pareja});

  @override
  State<EvaluarmeTab> createState() => _EvaluarmeTabState();
}

class _EvaluarmeTabState extends State<EvaluarmeTab> {
  final _evalRepo = EvaluacionesRepository();
  late final Stream<List<ItemLista>> _itemsStream;
  late final Stream<List<Evaluacion>> _evalStream;
  late final String _semanaId;

  @override
  void initState() {
    super.initState();
    _semanaId = SemanaUtils.idSemanaActual();
    // Streams creados una sola vez para no perder la suscripción (y volver a
    // "cargando") en cada rebuild.
    _itemsStream = ItemsRepository().observarListaDe(widget.pareja);
    _evalStream = _evalRepo.observarPorSemanaYEvaluador(_semanaId, widget.yo);
  }

  @override
  Widget build(BuildContext context) {
    final yo = widget.yo;
    final semanaId = _semanaId;
    final evalRepo = _evalRepo;

    return StreamBuilder<List<ItemLista>>(
      stream: _itemsStream,
      builder: (context, itemsSnap) {
        final items = (itemsSnap.data ?? []).where((i) => i.activo).toList();
        return StreamBuilder<List<Evaluacion>>(
          stream: _evalStream,
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
                ...items.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _FilaCalificar(
                      numero: entry.key + 1,
                      item: entry.value,
                      calificacionActual: evaluaciones[entry.value.id]?.calificacion,
                      onCalificar: (valor) => evalRepo.calificar(
                        itemId: entry.value.id,
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
  final int numero;
  final ItemLista item;
  final int? calificacionActual;
  final ValueChanged<int> onCalificar;

  const _FilaCalificar({
    required this.numero,
    required this.item,
    required this.calificacionActual,
    required this.onCalificar,
  });

  @override
  Widget build(BuildContext context) {
    final valor = calificacionActual;
    final rango = valor == null ? null : rangoDe(valor.toDouble());
    final color = rango?.color ?? AppColors.terracota;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: rango?.color.withValues(alpha: 0.4) ?? AppColors.trazo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.vino.withValues(alpha: 0.10),
                  ),
                  child: Text(
                    numero.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: AppColors.vino,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.texto,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: valor == null ? 0.10 : 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        valor?.toString() ?? '–',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    if (rango != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        rango.etiqueta,
                        style: TextStyle(
                          color: rango.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.16),
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.15),
                trackHeight: 5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 · flojo', style: _estiloExtremo),
                Text('10 · excelente', style: _estiloExtremo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _estiloExtremo = TextStyle(color: AppColors.tintaSuave, fontSize: 10.5);
}