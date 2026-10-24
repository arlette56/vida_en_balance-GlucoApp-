import 'package:flutter/material.dart';

import '../format.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// 05 · Historial
class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final week = s.lastWeekReadings;
    final values = week.map((r) => r.value).toList();

    final avg = values.isEmpty
        ? null
        : (values.reduce((a, b) => a + b) / values.length).round();
    final min = values.isEmpty ? null : values.reduce((a, b) => a < b ? a : b);
    final max = values.isEmpty ? null : values.reduce((a, b) => a > b ? a : b);

    return AppScaffold(
      title: 'Historial',
      showNav: true,
      tab: NavTab.historial,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen de 7 días (mg/dL)',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted)),
          const SizedBox(height: 10),
          Row(
            children: [
              _Stat('Promedio', avg, Icons.trending_flat),
              const SizedBox(width: 10),
              _Stat('Mínimo', min, Icons.arrow_downward),
              const SizedBox(width: 10),
              _Stat('Máximo', max, Icons.arrow_upward),
            ],
          ),
          const SizedBox(height: 16),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
            child: _WeekChart(data: s.dailyAverages),
          ),
          const FieldLabel('Últimos registros'),
          for (final r in s.readings.take(8)) ...[
            _ReadingTile(r),
            const SizedBox(height: 10),
          ],
          if (s.readings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Todavía no hay registros.',
                    style: TextStyle(color: AppColors.muted)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.icon);
  final String label;
  final int? value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: AppColors.muted),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(value?.toString() ?? '—',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestDark)),
          ],
        ),
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.data});
  final List<MapEntry<DateTime, double>> data;

  static const _top = 180.0; // escala vertical (mg/dL)
  static const _height = 130.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _height,
          child: Stack(
            children: [
              // Línea de referencia (130 mg/dL)
              Positioned(
                left: 0,
                right: 0,
                bottom: _height * glucoseHigh / _top,
                child: Row(
                  children: [
                    const Text('Referencia $glucoseHigh',
                        style: TextStyle(fontSize: 9, color: AppColors.muted)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Container(height: 1, color: AppColors.sageLine)),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < data.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (i == data.length - 1 && data[i].value > 0)
                              Text(data[i].value.round().toString(),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.forest)),
                            Container(
                              height: (data[i].value / _top).clamp(0.0, 1.0) *
                                  (_height - 14),
                              decoration: BoxDecoration(
                                color: i == data.length - 1
                                    ? AppColors.forest
                                    : AppColors.sage,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final e in data)
              Expanded(
                child: Text(shortDay(e.key),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.muted)),
              ),
          ],
        ),
      ],
    );
  }
}

class _ReadingTile extends StatelessWidget {
  const _ReadingTile(this.r);
  final GlucoseReading r;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.sageSoft, shape: BoxShape.circle),
            child: Icon(r.moment.icon, size: 20, color: AppColors.forest),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${r.value} mg/dL',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                Text(r.moment.label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(relativeDay(r.at),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
              Text(fmtTime(TimeOfDay.fromDateTime(r.at)),
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}
