import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/item.dart';
import '../../data/repositories/items_repository.dart';

/// Lista de la pareja, solo lectura — para saber qué se espera de vos.
class SuListaTab extends StatefulWidget {
  final String usuarioId;
  final String nombre;
  const SuListaTab({super.key, required this.usuarioId, required this.nombre});

  @override
  State<SuListaTab> createState() => _SuListaTabState();
}

class _SuListaTabState extends State<SuListaTab> {
  late final Stream<List<ItemLista>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = ItemsRepository().observarListaDe(widget.usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.colorDePersona(widget.usuarioId);
    return StreamBuilder<List<ItemLista>>(
      stream: _stream,
      builder: (context, snap) {
        final items = (snap.data ?? []).where((i) => i.activo).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          children: [
            Text(
              'Esto es lo que ${widget.nombre} espera de vos. Cada sábado te '
              'califica según cómo te fue en cada punto.',
              style: const TextStyle(color: AppColors.tintaSuave, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty && snap.connectionState != ConnectionState.waiting)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    '${widget.nombre} todavía no escribió su lista.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.tintaSuave),
                  ),
                ),
              ),
            ...items.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FilaSoloLectura(numero: entry.key + 1, item: entry.value, color: color),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilaSoloLectura extends StatelessWidget {
  final int numero;
  final ItemLista item;
  final Color color;

  const _FilaSoloLectura({required this.numero, required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.trazo),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(top: 1),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Text(
              numero.toString().padLeft(2, '0'),
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                item.texto,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.35,
                  color: AppColors.tintaFuerte,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
