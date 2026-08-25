import 'package:flutter/material.dart';

import '../../core/session/session.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/deseo.dart';
import '../../data/repositories/deseos_repository.dart';

class DeseosScreen extends StatefulWidget {
  final VoidCallback onVolver;
  const DeseosScreen({super.key, required this.onVolver});

  @override
  State<DeseosScreen> createState() => _DeseosScreenState();
}

class _DeseosScreenState extends State<DeseosScreen> {
  int _tab = 0;
  final _repo = DeseosRepository();
  Stream<List<Deseo>>? _misDeseosStream;
  Stream<List<Deseo>>? _deseosParejaStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Streams creados una sola vez (no en build) para no perder la
    // suscripción — y volver a "cargando" — cada vez que la pantalla se
    // reconstruye.
    if (_misDeseosStream == null) {
      final session = SessionScope.of(context);
      _misDeseosStream = _repo.observarDe(session.usuarioActual!);
      _deseosParejaStream = _repo.observarDe(session.parejaActual!);
    }
  }

  Future<void> _agregar(String autorId) async {
    final controlador = TextEditingController();
    final texto = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.papel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nuevo deseo o antojo'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          decoration: const InputDecoration(hintText: 'Qué se te antoja / qué deseás...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controlador.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (texto == null || texto.trim().isEmpty) return;
    await _repo.agregar(autorId, texto.trim());
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final yo = session.usuarioActual!;
    final pareja = session.parejaActual!;
    final esMio = _tab == 0;

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
              Text('Deseos y antojos', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _Tab(
                  texto: 'Mis deseos',
                  seleccionado: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Tab(
                  texto: 'De ${nombresUsuario[pareja]}',
                  seleccionado: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<Deseo>>(
            stream: esMio ? _misDeseosStream : _deseosParejaStream,
            builder: (context, snap) {
              final deseos = snap.data ?? [];
              return Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    children: [
                      if (deseos.isEmpty && snap.connectionState != ConnectionState.waiting)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              esMio ? 'Todavía no agregás deseos.' : 'Todavía no hay antojos por acá.',
                              style: const TextStyle(color: AppColors.tintaSuave),
                            ),
                          ),
                        ),
                      ...deseos.map(
                        (d) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _FilaDeseo(
                            deseo: d,
                            puedeMarcar: !esMio,
                            puedeEliminar: esMio,
                            onMarcar: (v) => _repo.marcarCumplido(d.id, v),
                            onEliminar: () => _repo.eliminar(d.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (esMio)
                    Positioned(
                      right: 8,
                      bottom: 16,
                      child: FloatingActionButton(
                        onPressed: () => _agregar(yo),
                        backgroundColor: AppColors.terracota,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;
  const _Tab({required this.texto, required this.seleccionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.oro.withValues(alpha: 0.16) : AppColors.papel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: seleccionado ? AppColors.oro : AppColors.trazo),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: seleccionado ? AppColors.terracotaOscuro : AppColors.tintaSuave,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FilaDeseo extends StatelessWidget {
  final Deseo deseo;
  final bool puedeMarcar;
  final bool puedeEliminar;
  final ValueChanged<bool> onMarcar;
  final VoidCallback onEliminar;

  const _FilaDeseo({
    required this.deseo,
    required this.puedeMarcar,
    required this.puedeEliminar,
    required this.onMarcar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: deseo.cumplido ? AppColors.oro.withValues(alpha: 0.08) : AppColors.tarjeta,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.trazo),
      ),
      child: Row(
        children: [
          if (puedeMarcar)
            GestureDetector(
              onTap: () => onMarcar(!deseo.cumplido),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: deseo.cumplido ? AppColors.oro : Colors.transparent,
                  border: Border.all(color: AppColors.oro, width: 1.6),
                ),
                child: deseo.cumplido
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : null,
              ),
            )
          else if (deseo.cumplido)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.favorite, size: 16, color: AppColors.oro),
            ),
          Expanded(
            child: Text(
              deseo.texto,
              style: TextStyle(
                fontSize: 14,
                decoration: deseo.cumplido ? TextDecoration.lineThrough : null,
                color: deseo.cumplido ? AppColors.tintaSuave : AppColors.tintaFuerte,
              ),
            ),
          ),
          if (puedeEliminar)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.tintaSuave),
              onPressed: onEliminar,
            ),
        ],
      ),
    );
  }
}