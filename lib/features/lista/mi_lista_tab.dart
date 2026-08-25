import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/item.dart';
import '../../data/repositories/items_repository.dart';

class MiListaTab extends StatefulWidget {
  final String usuarioId;
  const MiListaTab({super.key, required this.usuarioId});

  @override
  State<MiListaTab> createState() => _MiListaTabState();
}

class _MiListaTabState extends State<MiListaTab> {
  final _repo = ItemsRepository();

  Future<void> _agregar() async {
    final texto = await _mostrarDialogoTexto(context, titulo: 'Nuevo punto de la lista');
    if (texto == null || texto.trim().isEmpty) return;
    await _repo.agregar(widget.usuarioId, texto.trim(), DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _editar(ItemLista item) async {
    final texto = await _mostrarDialogoTexto(
      context,
      titulo: 'Editar punto',
      inicial: item.texto,
    );
    if (texto == null || texto.trim().isEmpty) return;
    await _repo.editarTexto(item.id, texto.trim());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ItemLista>>(
      stream: _repo.observarListaDe(widget.usuarioId),
      builder: (context, snap) {
        final items = snap.data ?? [];
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              children: [
                Text(
                  'Cosas que esperás de tu pareja. Cada sábado vos la calificás según '
                  'cómo le fue en cada punto.',
                  style: const TextStyle(color: AppColors.tintaSuave, fontSize: 12.5),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty && snap.connectionState != ConnectionState.waiting)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'Todavía no agregás nada.\nTocá + para escribir tu primer punto.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.tintaSuave),
                      ),
                    ),
                  ),
                ...items.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FilaItem(
                      numero: entry.key + 1,
                      item: entry.value,
                      onEditar: () => _editar(entry.value),
                      onActivar: (v) => _repo.cambiarActivo(entry.value.id, v),
                      onEliminar: () => _repo.eliminar(entry.value.id),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 8,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: _agregar,
                backgroundColor: AppColors.terracota,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilaItem extends StatelessWidget {
  final int numero;
  final ItemLista item;
  final VoidCallback onEditar;
  final ValueChanged<bool> onActivar;
  final VoidCallback onEliminar;

  const _FilaItem({
    required this.numero,
    required this.item,
    required this.onEditar,
    required this.onActivar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final activo = item.activo;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onEditar,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 14, 8, 14),
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
                  color: activo
                      ? AppColors.terracota.withValues(alpha: 0.12)
                      : AppColors.trazo.withValues(alpha: 0.5),
                ),
                child: activo
                    ? Text(
                        numero.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: AppColors.terracota,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      )
                    : const Icon(Icons.pause_rounded, size: 15, color: AppColors.tintaSuave),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    item.texto,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.35,
                      color: activo ? AppColors.tintaFuerte : AppColors.tintaSuave,
                      decoration: activo ? null : TextDecoration.lineThrough,
                      decorationColor: AppColors.tintaSuave,
                    ),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.tintaSuave, size: 20),
                onSelected: (v) {
                  if (v == 'editar') onEditar();
                  if (v == 'activar') onActivar(!activo);
                  if (v == 'eliminar') onEliminar();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'editar', child: Text('Editar')),
                  PopupMenuItem(
                    value: 'activar',
                    child: Text(activo ? 'Pausar' : 'Reactivar'),
                  ),
                  const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> _mostrarDialogoTexto(
  BuildContext context, {
  required String titulo,
  String inicial = '',
}) {
  final controlador = TextEditingController(text: inicial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.papel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(titulo),
      content: TextField(
        controller: controlador,
        autofocus: true,
        maxLines: 3,
        minLines: 1,
        decoration: const InputDecoration(hintText: 'Escribí acá...'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controlador.text),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}