import 'package:flutter/material.dart';

const _dias = [
  'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
];
const _diasCortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
  'septiembre', 'octubre', 'noviembre', 'diciembre'
];

/// «8:00 a. m.»
String fmtTime(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.period == DayPeriod.am ? 'a. m.' : 'p. m.'}';
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int daysFromToday(DateTime d) =>
    dateOnly(d).difference(dateOnly(DateTime.now())).inDays;

/// «Hoy», «Ayer», «Mañana» o el nombre del día.
String relativeDay(DateTime d) {
  switch (daysFromToday(d)) {
    case 0:
      return 'Hoy';
    case -1:
      return 'Ayer';
    case 1:
      return 'Mañana';
    default:
      return _dias[d.weekday - 1];
  }
}

String shortDay(DateTime d) =>
    daysFromToday(d) == 0 ? 'Hoy' : _diasCortos[d.weekday - 1];

/// «Viernes 9 de octubre»
String longDate(DateTime d) =>
    '${_dias[d.weekday - 1]} ${d.day} de ${_meses[d.month - 1]}';

/// «9 oct»
String shortDate(DateTime d) =>
    '${d.day} ${_meses[d.month - 1].substring(0, 3)}';

String fmtDateTime(DateTime d) =>
    '${relativeDay(d)}, ${fmtTime(TimeOfDay.fromDateTime(d))}';

/// «Hace 2 horas»
String ago(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Hace un momento';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return 'Hace $h ${h == 1 ? 'hora' : 'horas'}';
  }
  final days = diff.inDays;
  return 'Hace $days ${days == 1 ? 'día' : 'días'}';
}

/// «14 de marzo de 1951»
String fmtFullDate(DateTime d) =>
    '${d.day} de ${_meses[d.month - 1]} de ${d.year}';
