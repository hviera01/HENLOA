import 'package:flutter/material.dart';

import '../../core/session/session.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/rango_utils.dart';
import '../../core/utils/semana_utils.dart';
import '../../data/models/evaluacion.dart';
import '../../data/models/item.dart';
import '../../data/repositories/evaluaciones_repository.dart';
import '../../data/repositories/items_repository.dart';

class ProgresoScreen extends StatefulWidget {
  final VoidCallback onVolver;
  const ProgresoScreen({super.key, required this.onVolver});

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {
  int _tab = 0;

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
              Text('Progreso', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _ChipTab(
                  texto: 'Tu semana',
                  seleccionado: _tab == 0,
                  color: AppColors.colorDePersona(yo),
                  onTap: () => setState(() => _tab = 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChipTab(
                  texto: '${nombresUsuario[pareja]}',
                  seleccionado: _tab == 1,
                  color: AppColors.colorDePersona(pareja),
                  onTap: () => setState(() => _tab = 1),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          // IndexedStack: mantiene las dos pestañas montadas para no perder
          // la suscripción a Firestore (y volver a "cargando") al alternar.
          child: IndexedStack(
            sizing: StackFit.expand,
            index: _tab,
            children: [
              _ContenidoProgreso(evaluadoPor: yo, autorLista: pareja),
              _ContenidoProgreso(evaluadoPor: pareja, autorLista: yo),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChipTab extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final Color color;
  final VoidCallback onTap;
  const _ChipTab({
    required this.texto,
    required this.seleccionado,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionado ? color.withValues(alpha: 0.12) : AppColors.papel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: seleccionado ? color : AppColors.trazo),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: seleccionado ? color : AppColors.tintaSuave,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ContenidoProgreso extends StatefulWidget {
  final String evaluadoPor;
  final String autorLista;
  const _ContenidoProgreso({required this.evaluadoPor, required this.autorLista});

  @override
  State<_ContenidoProgreso> createState() => _ContenidoProgresoState();
}

class _ContenidoProgresoState extends State<_ContenidoProgreso> {
  late final Stream<List<ItemLista>> _itemsStream;
  late final Stream<List<Evaluacion>> _evalStream;
  late final String _semanaId;

  @override
  void initState() {
    super.initState();
    _semanaId = SemanaUtils.idSemanaActual();
    _itemsStream = ItemsRepository().observarListaDe(widget.autorLista);
    _evalStream = EvaluacionesRepository().observarPorSemanaYEvaluador(
      _semanaId,
      widget.evaluadoPor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final evaluadoPor = widget.evaluadoPor;
    final semanaId = _semanaId;

    return StreamBuilder<List<ItemLista>>(
      stream: _itemsStream,
      builder: (context, itemsSnap) {
        final items = {
          for (final i in (itemsSnap.data ?? [])) i.id: i,
        };
        return StreamBuilder<List<Evaluacion>>(
          stream: _evalStream,
          builder: (context, evalSnap) {
            final evals = evalSnap.data ?? [];
            final promedio = evals.isEmpty
                ? null
                : evals.map((e) => e.calificacion).reduce((a, b) => a + b) / evals.length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                _TarjetaPromedio(promedio: promedio, semanaId: semanaId),
                const SizedBox(height: 20),
                if (evals.isNotEmpty) ...[
                  Text('Detalle de esta semana', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ...evals.map((e) {
                    final item = items[e.itemId];
                    if (item == null) return const SizedBox.shrink();
                    final rango = rangoDe(e.calificacion.toDouble());
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
                                color: rango.color.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${e.calificacion}',
                                style: TextStyle(
                                  color: rango.color,
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
                  const SizedBox(height: 24),
                ],
                Text('Historial semanal', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                _HistorialSemanal(evaluadoPor: evaluadoPor, semanaActualId: semanaId),
              ],
            );
          },
        );
      },
    );
  }
}

class _TarjetaPromedio extends StatelessWidget {
  final double? promedio;
  final String semanaId;
  const _TarjetaPromedio({required this.promedio, required this.semanaId});

  @override
  Widget build(BuildContext context) {
    final rango = promedio == null ? null : rangoDe(promedio!);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: rango?.color.withValues(alpha: 0.10) ?? AppColors.papel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: rango?.color.withValues(alpha: 0.35) ?? AppColors.trazo),
      ),
      child: Column(
        children: [
          Text(
            'Promedio de la semana',
            style: const TextStyle(color: AppColors.tintaSuave, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            promedio == null ? '–' : promedio!.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: rango?.color ?? AppColors.tintaSuave,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            promedio == null ? 'Todavía sin calificar' : rango!.etiqueta,
            style: TextStyle(
              color: rango?.color ?? AppColors.tintaSuave,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorialSemanal extends StatefulWidget {
  final String evaluadoPor;
  final String semanaActualId;
  const _HistorialSemanal({required this.evaluadoPor, required this.semanaActualId});

  @override
  State<_HistorialSemanal> createState() => _HistorialSemanalState();
}

class _HistorialSemanalState extends State<_HistorialSemanal> {
  late final Future<List<MapEntry<String, List<Evaluacion>>>> _historial;

  @override
  void initState() {
    super.initState();
    _historial = EvaluacionesRepository().historialPorEvaluador(widget.evaluadoPor);
  }

  @override
  Widget build(BuildContext context) {
    final semanaActualId = widget.semanaActualId;
    return FutureBuilder<List<MapEntry<String, List<Evaluacion>>>>(
      future: _historial,
      builder: (context, snap) {
        final semanas = (snap.data ?? [])
            .where((e) => e.key != semanaActualId)
            .toList();
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (semanas.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Todavía no hay semanas anteriores.',
              style: const TextStyle(color: AppColors.tintaSuave, fontSize: 13),
            ),
          );
        }
        return Column(
          children: semanas.map((entry) {
            final promedio =
                entry.value.map((e) => e.calificacion).reduce((a, b) => a + b) / entry.value.length;
            final rango = rangoDe(promedio);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.papel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.trazo),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        SemanaUtils.etiquetaSemana(entry.key),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: rango.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        promedio.toStringAsFixed(1),
                        style: TextStyle(color: rango.color, fontWeight: FontWeight.w700, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}