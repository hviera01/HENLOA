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
                  'Cosas que esperás de tu pareja. Cada sábado ella/él se autoevalúa sobre esto.',
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
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FilaItem(
                      item: item,
                      onEditar: () => _editar(item),
                      onActivar: (v) => _repo.cambiarActivo(item.id, v),
                      onEliminar: () => _repo.eliminar(item.id),
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
  final ItemLista item;
  final VoidCallback onEditar;
  final ValueChanged<bool> onActivar;
  final VoidCallback onEliminar;

  const _FilaItem({
    required this.item,
    required this.onEditar,
    required this.onActivar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.trazo),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onEditar,
              child: Text(
                item.texto,
                style: TextStyle(
                  fontSize: 14,
                  color: item.activo ? AppColors.tintaFuerte : AppColors.tintaSuave,
                  decoration: item.activo ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.tintaSuave),
            onSelected: (v) {
              if (v == 'editar') onEditar();
              if (v == 'activar') onActivar(!item.activo);
              if (v == 'eliminar') onEliminar();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'editar', child: Text('Editar')),
              PopupMenuItem(
                value: 'activar',
                child: Text(item.activo ? 'Pausar' : 'Reactivar'),
              ),
              const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
            ],
          ),
        ],
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