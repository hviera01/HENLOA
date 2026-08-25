import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/rango_utils.dart';
import '../../core/utils/semana_utils.dart';
import '../../data/models/evaluacion.dart';
import '../../data/models/item.dart';
import '../../data/repositories/evaluaciones_repository.dart';
import '../../data/repositories/items_repository.dart';
import 'evaluacion_wizard_screen.dart';

/// Acá el usuario evalúa a SU PAREJA: cada punto de SU PROPIA lista (lo que
/// él/ella pidió) se califica según cómo le fue a la pareja esa semana.
class EvaluarTab extends StatefulWidget {
  final String yo;
  final String pareja;
  final String nombrePareja;
  const EvaluarTab({
    super.key,
    required this.yo,
    required this.pareja,
    required this.nombrePareja,
  });

  @override
  State<EvaluarTab> createState() => _EvaluarTabState();
}

class _EvaluarTabState extends State<EvaluarTab> {
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
    _itemsStream = ItemsRepository().observarListaDe(widget.yo);
    _evalStream = _evalRepo.observarPorSemanaYEvaluador(_semanaId, widget.pareja);
  }

  Future<void> _abrirEvaluacion(List<ItemLista> items, Map<String, int> actuales) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EvaluacionWizardScreen(
          items: items,
          semanaId: _semanaId,
          sujetoEvaluado: widget.pareja,
          nombreSujeto: widget.nombrePareja,
          calificacionesActuales: actuales,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Todavía no escribiste tu lista.\nAndá a "Mi lista" para agregar el primer punto.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.tintaSuave),
                  ),
                ),
              );
            }

            final calificadas = items.where((i) => evaluaciones.containsKey(i.id)).length;
            final completo = calificadas == items.length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                Text(
                  'Calificá del 1 al 10 cómo le fue a ${widget.nombrePareja} esta semana '
                  'en cada punto de tu lista.',
                  style: const TextStyle(color: AppColors.tintaSuave, fontSize: 12.5),
                ),
                const SizedBox(height: 6),
                Text(
                  SemanaUtils.etiquetaSemana(_semanaId),
                  style: const TextStyle(
                    color: AppColors.terracota,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: completo
                        ? AppColors.rangoBien.withValues(alpha: 0.10)
                        : AppColors.vino.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: completo
                          ? AppColors.rangoBien.withValues(alpha: 0.35)
                          : AppColors.vino.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        completo ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                        color: completo ? AppColors.rangoBien : AppColors.vino,
                        size: 28,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        completo
                            ? '¡Ya evaluaste los ${items.length} puntos!'
                            : '$calificadas de ${items.length} evaluados',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        completo
                            ? '${widget.nombrePareja} ya puede ver cómo le fue.'
                            : 'Hacé la evaluación de esta semana',
                        style: const TextStyle(color: AppColors.tintaSuave, fontSize: 12.5),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _abrirEvaluacion(items, {
                            for (final e in evaluaciones.entries) e.key: e.value.calificacion,
                          }),
                          icon: Icon(completo ? Icons.replay_rounded : Icons.rate_review_rounded),
                          label: Text(completo ? 'Repetir evaluación' : 'Hacer evaluación'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (evaluaciones.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Tus calificaciones', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ...items.map((item) {
                    final calificacion = evaluaciones[item.id]?.calificacion;
                    final rango = calificacion == null ? null : rangoDe(calificacion.toDouble());
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.tarjeta,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.trazo),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(item.texto, style: const TextStyle(fontSize: 13.5)),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: (rango?.color ?? AppColors.trazo).withValues(
                                  alpha: rango == null ? 0.4 : 0.14,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                calificacion?.toString() ?? '–',
                                style: TextStyle(
                                  color: rango?.color ?? AppColors.tintaSuave,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
