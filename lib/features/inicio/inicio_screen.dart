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

class InicioScreen extends StatelessWidget {
  final ValueChanged<int> onVerSeccion;
  const InicioScreen({super.key, required this.onVerSeccion});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final yo = session.usuarioActual!;
    final pareja = session.parejaActual!;
    final semanaId = SemanaUtils.idSemanaActual();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${nombresUsuario[yo]}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    SemanaUtils.etiquetaSemana(semanaId),
                    style: const TextStyle(color: AppColors.tintaSuave),
                  ),
                ],
              ),
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: () => session.cerrarSesion(),
                icon: const Icon(Icons.logout_rounded, color: AppColors.tintaSuave),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (SemanaUtils.esHoySabado()) _BannerSabado(onTap: () => onVerSeccion(1)),
          if (SemanaUtils.esHoySabado()) const SizedBox(height: 16),
          _TarjetaProgresoResumen(
            titulo: 'Tu semana',
            subtitulo: 'Cómo te autoevaluaste',
            evaluadoPor: yo,
            semanaId: semanaId,
            onTap: () => onVerSeccion(2),
          ),
          const SizedBox(height: 14),
          _TarjetaProgresoResumen(
            titulo: '${nombresUsuario[pareja]}',
            subtitulo: 'Cómo se autoevaluó',
            evaluadoPor: pareja,
            semanaId: semanaId,
            onTap: () => onVerSeccion(2),
          ),
          const SizedBox(height: 24),
          Text('Accesos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AccesoCard(
                  icono: Icons.checklist_rounded,
                  texto: 'Nuestra lista',
                  onTap: () => onVerSeccion(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AccesoCard(
                  icono: Icons.auto_awesome_rounded,
                  texto: 'Deseos y antojos',
                  onTap: () => onVerSeccion(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AccesoCard(
            icono: Icons.mail_rounded,
            texto: 'Buzón de cartas',
            onTap: () => onVerSeccion(4),
          ),
        ],
      ),
    );
  }
}

class _BannerSabado extends StatelessWidget {
  final VoidCallback onTap;
  const _BannerSabado({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.vino,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.oroClaro, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hoy es sábado',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Toca evaluar cómo te fue esta semana',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _TarjetaProgresoResumen extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String evaluadoPor;
  final String semanaId;
  final VoidCallback onTap;

  const _TarjetaProgresoResumen({
    required this.titulo,
    required this.subtitulo,
    required this.evaluadoPor,
    required this.semanaId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemsRepo = ItemsRepository();
    final evalRepo = EvaluacionesRepository();
    final autorDeLista = evaluadoPor == kUsuarioHenry ? kUsuarioLoany : kUsuarioHenry;

    return StreamBuilder<List<ItemLista>>(
      stream: itemsRepo.observarListaDe(autorDeLista),
      builder: (context, itemsSnap) {
        final items = (itemsSnap.data ?? []).where((i) => i.activo).toList();
        return StreamBuilder<List<Evaluacion>>(
          stream: evalRepo.observarPorSemanaYEvaluador(semanaId, evaluadoPor),
          builder: (context, evalSnap) {
            final evals = evalSnap.data ?? [];
            final promedio = evals.isEmpty
                ? null
                : evals.map((e) => e.calificacion).reduce((a, b) => a + b) / evals.length;
            final pendientes = items.length - evals.length;

            return InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.tarjeta,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.trazo),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.colorDePersona(evaluadoPor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            items.isEmpty
                                ? 'Sin ítems en la lista'
                                : pendientes > 0
                                    ? '$subtitulo · $pendientes pendiente${pendientes == 1 ? '' : 's'}'
                                    : subtitulo,
                            style: const TextStyle(color: AppColors.tintaSuave, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    if (promedio != null) _BadgePromedio(promedio: promedio),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BadgePromedio extends StatelessWidget {
  final double promedio;
  const _BadgePromedio({required this.promedio});

  @override
  Widget build(BuildContext context) {
    final rango = rangoDe(promedio);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: rango.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        promedio.toStringAsFixed(1),
        style: TextStyle(color: rango.color, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}

class _AccesoCard extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;
  const _AccesoCard({required this.icono, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.papel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.trazo),
        ),
        child: Row(
          children: [
            Icon(icono, color: AppColors.terracota, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}