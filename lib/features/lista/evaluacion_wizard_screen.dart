import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/rango_utils.dart';
import '../../data/models/item.dart';
import '../../data/repositories/evaluaciones_repository.dart';

/// Flujo guiado tipo presentación: un punto de la lista a la vez, hasta
/// terminar de calificar todos.
class EvaluacionWizardScreen extends StatefulWidget {
  final List<ItemLista> items;
  final String semanaId;
  final String sujetoEvaluado;
  final String nombreSujeto;
  final Map<String, int> calificacionesActuales;

  const EvaluacionWizardScreen({
    super.key,
    required this.items,
    required this.semanaId,
    required this.sujetoEvaluado,
    required this.nombreSujeto,
    required this.calificacionesActuales,
  });

  @override
  State<EvaluacionWizardScreen> createState() => _EvaluacionWizardScreenState();
}

class _EvaluacionWizardScreenState extends State<EvaluacionWizardScreen> {
  final _repo = EvaluacionesRepository();
  late final Map<String, int> _calificaciones;
  int _indice = 0;
  bool _terminado = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _calificaciones = Map.of(widget.calificacionesActuales);
  }

  int get _valorActual =>
      _calificaciones[widget.items[_indice].id] ?? 5;

  Future<void> _siguiente() async {
    setState(() => _guardando = true);
    final item = widget.items[_indice];
    await _repo.calificar(
      itemId: item.id,
      semanaId: widget.semanaId,
      evaluadoPor: widget.sujetoEvaluado,
      calificacion: _valorActual,
    );
    if (!mounted) return;
    setState(() {
      _guardando = false;
      if (_indice < widget.items.length - 1) {
        _indice++;
      } else {
        _terminado = true;
      }
    });
  }

  void _atras() {
    if (_indice == 0) return;
    setState(() => _indice--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: _terminado ? _VistaFinal(nombreSujeto: widget.nombreSujeto) : _vistaPregunta(),
          ),
        ),
      ),
    );
  }

  Widget _vistaPregunta() {
    final item = widget.items[_indice];
    final total = widget.items.length;
    final valor = _valorActual;
    final rango = rangoDe(valor.toDouble());
    final esUltimo = _indice == total - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
              Expanded(
                child: Text(
                  'Punto ${_indice + 1} de $total',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.tintaSuave,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_indice + 1) / total,
              minHeight: 6,
              backgroundColor: AppColors.trazo,
              color: AppColors.terracota,
            ),
          ),
          const Spacer(),
          Text(
            'Calificá a ${widget.nombreSujeto} en:',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.tintaSuave, fontSize: 13.5),
          ),
          const SizedBox(height: 12),
          Text(
            item.texto,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 36),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rango.color.withValues(alpha: 0.14),
              border: Border.all(color: rango.color.withValues(alpha: 0.4), width: 2),
            ),
            child: Text(
              '$valor',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: rango.color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rango.etiqueta,
            style: TextStyle(color: rango.color, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 28),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: rango.color,
              inactiveTrackColor: rango.color.withValues(alpha: 0.16),
              thumbColor: rango.color,
              overlayColor: rango.color.withValues(alpha: 0.15),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: valor.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$valor',
              onChanged: (v) => setState(
                () => _calificaciones[item.id] = v.round(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('1 · flojo', style: TextStyle(color: AppColors.tintaSuave, fontSize: 11.5)),
                Text('10 · excelente', style: TextStyle(color: AppColors.tintaSuave, fontSize: 11.5)),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              if (_indice > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _guardando ? null : _atras,
                    child: const Text('Atrás'),
                  ),
                ),
              if (_indice > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _guardando ? null : _siguiente,
                  child: Text(esUltimo ? 'Finalizar' : 'Siguiente'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VistaFinal extends StatelessWidget {
  final String nombreSujeto;
  const _VistaFinal({required this.nombreSujeto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.rangoBien.withValues(alpha: 0.14),
            ),
            child: const Icon(Icons.favorite_rounded, color: AppColors.rangoBien, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            '¡Evaluación completa!',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '$nombreSujeto ya puede ver cómo le fue esta semana en Progreso.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.tintaSuave, fontSize: 14),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Listo'),
            ),
          ),
        ],
      ),
    );
  }
}
