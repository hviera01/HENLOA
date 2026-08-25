import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _codigo = '';
  bool _error = false;
  bool _verificando = false;

  Future<void> _agregarDigito(String d) async {
    if (_codigo.length >= 4 || _verificando) return;
    setState(() {
      _codigo += d;
      _error = false;
    });
    if (_codigo.length == 4) {
      setState(() => _verificando = true);
      final session = SessionScope.of(context);
      final usuario = await session.iniciarSesionConCodigo(_codigo);
      if (!mounted) return;
      if (usuario == null) {
        setState(() {
          _error = true;
          _verificando = false;
          _codigo = '';
        });
      }
    }
  }

  void _borrar() {
    if (_codigo.isEmpty || _verificando) return;
    setState(() => _codigo = _codigo.substring(0, _codigo.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      _Cabecera(),
                      const SizedBox(height: 40),
                      _PuntosCodigo(longitud: _codigo.length, error: _error),
                      const SizedBox(height: 10),
                      AnimatedOpacity(
                        opacity: _error ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          'Código incorrecto, probá de nuevo',
                          style: TextStyle(
                            color: AppColors.rangoMalo,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: 300,
                        child: _Teclado(
                          habilitado: !_verificando,
                          onDigito: _agregarDigito,
                          onBorrar: _borrar,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.trazo, width: 1.4),
          ),
          child: Center(
            child: CustomPaint(size: const Size(30, 26), painter: _NudoPainter()),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Henloa',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: 40,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Henry  &  Loany',
          style: TextStyle(
            color: AppColors.tintaSuave,
            fontSize: 13,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Ingresá tu código',
          style: TextStyle(color: AppColors.tintaFuerte, fontSize: 15),
        ),
      ],
    );
  }
}

/// Dos trazos entrelazados, como un nudo simple — evita el clásico corazón
/// genérico de IA.
class _NudoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = AppColors.terracota
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    final p2 = Paint()
      ..color = AppColors.vino
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(0, size.height * 0.75)
      ..cubicTo(
        size.width * 0.15,
        0,
        size.width * 0.55,
        size.height,
        size.width * 0.7,
        size.height * 0.3,
      );
    final path2 = Path()
      ..moveTo(size.width * 0.3, size.height * 0.7)
      ..cubicTo(
        size.width * 0.45,
        size.height * 1.3,
        size.width * 0.85,
        size.height,
        size.width,
        size.height * 0.25,
      );

    canvas.drawPath(path1, p1);
    canvas.drawPath(path2, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PuntosCodigo extends StatelessWidget {
  final int longitud;
  final bool error;
  const _PuntosCodigo({required this.longitud, required this.error});

  @override
  Widget build(BuildContext context) {
    final color = error ? AppColors.rangoMalo : AppColors.terracota;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final lleno = i < longitud;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lleno ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.6),
          ),
        );
      }),
    );
  }
}

class _Teclado extends StatelessWidget {
  final bool habilitado;
  final ValueChanged<String> onDigito;
  final VoidCallback onBorrar;

  const _Teclado({
    required this.habilitado,
    required this.onDigito,
    required this.onBorrar,
  });

  @override
  Widget build(BuildContext context) {
    const filas = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Column(
      children: filas.map((fila) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: fila.map((tecla) {
              if (tecla.isEmpty) return const SizedBox(width: 68, height: 60);
              final esBorrar = tecla == '⌫';
              return _TeclaBoton(
                texto: tecla,
                habilitado: habilitado,
                onTap: () {
                  HapticFeedback.selectionClick();
                  esBorrar ? onBorrar() : onDigito(tecla);
                },
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _TeclaBoton extends StatelessWidget {
  final String texto;
  final bool habilitado;
  final VoidCallback onTap;
  const _TeclaBoton({
    required this.texto,
    required this.habilitado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: habilitado ? onTap : null,
          child: Center(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: texto == '⌫' ? 20 : 24,
                fontWeight: FontWeight.w600,
                color: AppColors.tintaFuerte,
              ),
            ),
          ),
        ),
      ),
    );
  }
}