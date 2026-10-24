import 'package:flutter/material.dart';

import '../routes.dart';
import '../state.dart';
import '../theme.dart';
import 'cards.dart';
import 'form_fields.dart';

/// Contenido propio de cada dashboard según el rol del usuario.
/// - Cliente: sin resumen extra (el menú es el del diseño).
/// - Operador: situación actual del cliente que acompaña.
/// - Administrador: indicadores clínicos de los últimos 7 días.
class RoleDashboard extends StatelessWidget {
  const RoleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final role = AppScope.of(context).user!.role;
    switch (role) {
      case UserRole.cliente:
        // El cliente ve el menú tal cual el diseño, sin resumen extra.
        return const SizedBox.shrink();
      case UserRole.operador:
        return const _OperadorSection();
      case UserRole.administrador:
        return const _AdministradorSection();
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon, {this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.forest),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestDark)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.muted)),
      );
}

// ───────── Operador ─────────

class _OperadorSection extends StatelessWidget {
  const _OperadorSection();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final last = s.lastReading;
    final pendientes = s.meds.length - s.takenCount;
    final hoy = s.reminders.where((r) => r.active && r.isToday).length;
    final fuera = last != null &&
        (last.value < glucoseLow || last.value > glucoseHigh);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Cómo está ${s.patient?.firstName ?? 'el cliente'} hoy'),
        if (fuera)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: ErrorBanner('La última glucosa está fuera del rango (70–130).'),
          ),
        Row(
          children: [
            _Metric(
              'Última glucosa',
              last == null ? '—' : '${last.value}',
              Icons.water_drop_outlined,
              color: fuera ? AppColors.danger : null,
            ),
            const SizedBox(width: 10),
            _Metric('Tomas pendientes', '$pendientes',
                Icons.medication_outlined,
                color: pendientes > 0 ? AppColors.amber : null),
            const SizedBox(width: 10),
            _Metric('Recordatorios hoy', '$hoy', Icons.schedule),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ───────── Administrador ─────────

class _AdministradorSection extends StatelessWidget {
  const _AdministradorSection();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final week = s.lastWeekReadings;
    final n = week.length;
    final avg = n == 0
        ? '—'
        : '${(week.map((r) => r.value).reduce((a, b) => a + b) / n).round()}';
    final enRango =
        week.where((r) => r.value >= glucoseLow && r.value <= glucoseHigh).length;
    final pct = n == 0 ? '—' : '${(enRango * 100 / n).round()}%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Indicadores de 7 días'),
        Row(
          children: [
            _Metric('Promedio mg/dL', avg, Icons.trending_flat),
            const SizedBox(width: 10),
            _Metric('En rango', pct, Icons.verified_outlined),
            const SizedBox(width: 10),
            _Metric('Lecturas', '$n', Icons.list_alt),
          ],
        ),
        const SizedBox(height: 10),
        SoftCard(
          onTap: () => Navigator.pushNamed(context, Routes.historial),
          child: Row(
            children: [
              const Icon(Icons.show_chart, color: AppColors.forest),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Medicamentos activos: ${s.meds.length} · '
                  'toca para ver el historial completo',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
