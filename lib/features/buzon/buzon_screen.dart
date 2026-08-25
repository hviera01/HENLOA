import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../core/session/session.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/carta.dart';
import '../../data/repositories/cartas_repository.dart';
import 'carta_pdf.dart';

class BuzonScreen extends StatefulWidget {
  final VoidCallback onVolver;
  const BuzonScreen({super.key, required this.onVolver});

  @override
  State<BuzonScreen> createState() => _BuzonScreenState();
}

class _BuzonScreenState extends State<BuzonScreen> {
  int _tab = 0;
  final _repo = CartasRepository();
  Stream<List<Carta>>? _recibidasStream;
  Stream<List<Carta>>? _enviadasStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Streams creados una sola vez (no en build) para no perder la
    // suscripción — y volver a "cargando" — cada vez que la pantalla se
    // reconstruye.
    if (_recibidasStream == null) {
      final yo = SessionScope.of(context).usuarioActual!;
      _recibidasStream = _repo.observarRecibidasPor(yo);
      _enviadasStream = _repo.observarEnviadasPor(yo);
    }
  }

  Future<void> _escribirCarta(String autorId, String destinatarioId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _EscribirCartaScreen(autorId: autorId, destinatarioId: destinatarioId),
      ),
    );
  }

  Future<void> _abrirCarta(Carta carta, String nombreAutor, String nombreDestinatario) async {
    if (!carta.leida && carta.destinatarioId == SessionScope.of(context).usuarioActual) {
      unawaited(_repo.marcarLeida(carta.id));
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VerCartaScreen(
          carta: carta,
          nombreAutor: nombreAutor,
          nombreDestinatario: nombreDestinatario,
        ),
      ),
    );
  }

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
              Expanded(
                child: Text('Buzón', style: Theme.of(context).textTheme.headlineMedium),
              ),
              FilledButton.icon(
                onPressed: () => _escribirCarta(yo, pareja),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Escribir'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _Tab(
                  texto: 'Recibidas',
                  seleccionado: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Tab(
                  texto: 'Enviadas',
                  seleccionado: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<Carta>>(
            stream: _tab == 0 ? _recibidasStream : _enviadasStream,
            builder: (context, snap) {
              final cartas = snap.data ?? [];
              if (cartas.isEmpty && snap.connectionState != ConnectionState.waiting) {
                return Center(
                  child: Text(
                    _tab == 0 ? 'Todavía no te escriben cartas.' : 'Todavía no enviás cartas.',
                    style: const TextStyle(color: AppColors.tintaSuave),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                itemCount: cartas.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final c = cartas[i];
                  final autorMostrado = _tab == 0 ? pareja : yo;
                  final destinoMostrado = _tab == 0 ? yo : pareja;
                  return _FilaCarta(
                    carta: c,
                    esRecibida: _tab == 0,
                    onTap: () => _abrirCarta(
                      c,
                      nombresUsuario[autorMostrado]!,
                      nombresUsuario[destinoMostrado]!,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

void unawaited(Future<void> f) {}

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
          color: seleccionado ? AppColors.vino.withValues(alpha: 0.10) : AppColors.papel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: seleccionado ? AppColors.vino : AppColors.trazo),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: seleccionado ? AppColors.vino : AppColors.tintaSuave,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FilaCarta extends StatelessWidget {
  final Carta carta;
  final bool esRecibida;
  final VoidCallback onTap;
  const _FilaCarta({required this.carta, required this.esRecibida, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sinLeer = esRecibida && !carta.leida;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.tarjeta,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: sinLeer ? AppColors.terracota : AppColors.trazo, width: sinLeer ? 1.4 : 1),
        ),
        child: Row(
          children: [
            Icon(
              sinLeer ? Icons.mark_email_unread_rounded : Icons.mail_outline_rounded,
              color: sinLeer ? AppColors.terracota : AppColors.tintaSuave,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    carta.titulo.trim().isEmpty ? 'Sin título' : carta.titulo,
                    style: TextStyle(
                      fontWeight: sinLeer ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    carta.contenido,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.tintaSuave, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.tintaSuave),
          ],
        ),
      ),
    );
  }
}

class _EscribirCartaScreen extends StatefulWidget {
  final String autorId;
  final String destinatarioId;
  const _EscribirCartaScreen({required this.autorId, required this.destinatarioId});

  @override
  State<_EscribirCartaScreen> createState() => _EscribirCartaScreenState();
}

class _EscribirCartaScreenState extends State<_EscribirCartaScreen> {
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  bool _enviando = false;

  Future<void> _enviar() async {
    if (_contenidoCtrl.text.trim().isEmpty) return;
    setState(() => _enviando = true);
    await CartasRepository().enviar(
      autorId: widget.autorId,
      destinatarioId: widget.destinatarioId,
      titulo: _tituloCtrl.text.trim(),
      contenido: _contenidoCtrl.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(title: const Text('Nueva carta')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              TextField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(hintText: 'Título (opcional)'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _contenidoCtrl,
                maxLines: 14,
                minLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Escribí lo que sientas...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _enviando ? null : _enviar,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(_enviando ? 'Enviando...' : 'Enviar carta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerCartaScreen extends StatelessWidget {
  final Carta carta;
  final String nombreAutor;
  final String nombreDestinatario;

  const _VerCartaScreen({
    required this.carta,
    required this.nombreAutor,
    required this.nombreDestinatario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(title: const Text('Carta')),
      body: PdfPreview(
        build: (format) async {
          final doc = await generarPdfCarta(carta, nombreAutor, nombreDestinatario);
          return doc.save();
        },
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        pdfPreviewPageDecoration: const BoxDecoration(),
      ),
    );
  }
}