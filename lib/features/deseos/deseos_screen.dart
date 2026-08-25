import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                  if (deseos.isEmpty && snap.connectionState != ConnectionState.waiting)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          esMio ? 'Todavía no agregás deseos.' : 'Todavía no hay antojos por acá.',
                          style: const TextStyle(color: AppColors.tintaSuave),
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const espacio = 14.0;
                        final anchoTarjeta = (constraints.maxWidth - espacio) / 2;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
                          child: Wrap(
                            spacing: espacio,
                            runSpacing: espacio,
                            children: deseos.asMap().entries.map((entry) {
                              return SizedBox(
                                width: anchoTarjeta,
                                child: _TarjetaDeseo(
                                  indice: entry.key,
                                  deseo: entry.value,
                                  puedeMarcar: !esMio,
                                  puedeEliminar: esMio,
                                  onMarcar: (v) => _repo.marcarCumplido(entry.value.id, v),
                                  onEliminar: () => _repo.eliminar(entry.value.id),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
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

/// Paleta de "papelitos" pastel — se turnan según el índice para que el
/// tablero de deseos no se vea repetitivo.
const _tonosNota = [
  (fondo: Color(0xFFF6E4D9), cinta: AppColors.terracota),
  (fondo: Color(0xFFF3E6D3), cinta: AppColors.oro),
  (fondo: Color(0xFFEFE0E3), cinta: AppColors.vino),
];

class _TarjetaDeseo extends StatelessWidget {
  final int indice;
  final Deseo deseo;
  final bool puedeMarcar;
  final bool puedeEliminar;
  final ValueChanged<bool> onMarcar;
  final VoidCallback onEliminar;

  const _TarjetaDeseo({
    required this.indice,
    required this.deseo,
    required this.puedeMarcar,
    required this.puedeEliminar,
    required this.onMarcar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final cumplido = deseo.cumplido;
    final tono = _tonosNota[indice % _tonosNota.length];
    final inclinacion = (indice.isEven ? -1 : 1) * (2.2 + (indice % 3) * 0.6);
    // Radios asimétricos y distintos por tarjeta: rompe la sensación de
    // "caja cuadrada" y da un aire más de papelito pegado a mano.
    final radios = indice.isEven
        ? const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          );

    return Transform.rotate(
      angle: inclinacion * 0.0174533,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radios,
          onTap: puedeMarcar ? () => onMarcar(!cumplido) : null,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 22, 14, 14),
            constraints: const BoxConstraints(minHeight: 108),
            decoration: BoxDecoration(
              color: cumplido ? tono.fondo.withValues(alpha: 0.55) : tono.fondo,
              borderRadius: radios,
              boxShadow: [
                BoxShadow(
                  color: AppColors.tintaFuerte.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // "Cinta" pegada arriba, como si el papelito estuviera
                // prendido a un corcho de deseos.
                Positioned(
                  top: -18,
                  left: 18,
                  child: Transform.rotate(
                    angle: -0.12,
                    child: Container(
                      width: 34,
                      height: 16,
                      decoration: BoxDecoration(
                        color: tono.cinta.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      deseo.texto,
                      style: GoogleFonts.fraunces(
                        fontStyle: FontStyle.italic,
                        fontSize: 15.5,
                        height: 1.3,
                        color: cumplido ? AppColors.tintaSuave : AppColors.tintaFuerte,
                        decoration: cumplido ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.tintaSuave,
                        decorationThickness: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (puedeMarcar || cumplido)
                          Icon(
                            cumplido ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 16,
                            color: tono.cinta,
                          ),
                        const Spacer(),
                        if (puedeEliminar)
                          GestureDetector(
                            onTap: onEliminar,
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppColors.tintaSuave.withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}