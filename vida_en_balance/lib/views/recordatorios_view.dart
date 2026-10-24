import 'package:flutter/material.dart';

import '../format.dart';
import '../routes.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// 10 · Recordatorios
class RecordatoriosScreen extends StatelessWidget {
  const RecordatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final hoy = s.reminders.where((r) => r.isToday).toList();
    final proximos = s.reminders.where((r) => !r.isToday).toList();

    return AppScaffold(
      title: 'Recordatorios',
      showNav: true,
      tab: NavTab.inicio,
      bottomAction: s.can(Permission.administrarRecordatorios)
          ? PrimaryButton(
              label: 'Agregar recordatorio',
              icon: Icons.add,
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.agregarRecordatorio),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hoy.isNotEmpty) ...[
            const _Badge('Hoy', AppColors.sageSoft, AppColors.forest),
            const SizedBox(height: 10),
            for (final r in hoy) _ReminderTile(r),
          ],
          if (proximos.isNotEmpty) ...[
            const SizedBox(height: 8),
            const _Badge('Próximos', AppColors.amberSoft, AppColors.amber),
            const SizedBox(height: 10),
            for (final r in proximos) _ReminderTile(r),
          ],
          if (s.reminders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No tienes recordatorios.',
                    style: TextStyle(color: AppColors.muted)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, this.bg, this.fg);
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(text,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: fg)),
      );
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile(this.r);
  final Reminder r;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        child: Row(
          children: [
            Container(
              width: 62,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.sageSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(r.kind.icon, size: 22, color: AppColors.forest),
                  const SizedBox(height: 4),
                  Text(fmtTime(r.time),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(r.subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.muted)),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: r.active,
                  // Sin permiso el interruptor queda deshabilitado.
                  onChanged: s.can(Permission.administrarRecordatorios)
                      ? (v) => s.toggleReminder(r, v)
                      : null,
                ),
                Text(r.active ? 'Activo' : 'Apagado',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: r.active ? AppColors.forest : AppColors.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 11 · Agregar recordatorio
class AgregarRecordatorioScreen extends StatefulWidget {
  const AgregarRecordatorioScreen({super.key});

  @override
  State<AgregarRecordatorioScreen> createState() =>
      _AgregarRecordatorioScreenState();
}

class _AgregarRecordatorioScreenState extends State<AgregarRecordatorioScreen> {
  ReminderKind _kind = ReminderKind.cita;
  late final TextEditingController _title =
      TextEditingController(text: _kind.defaultTitle);
  bool _titleEdited = false;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _daily = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: dateOnly(now),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  void _save() {
    final title = _title.text.trim().isEmpty
        ? _kind.defaultTitle
        : _title.text.trim();
    AppScope.of(context).addReminder(Reminder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      kind: _kind,
      title: title,
      time: _time,
      date: _date,
      daily: _daily,
    ));
    Navigator.pop(context); // vuelve a Recordatorios
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Agregar recordatorio',
      bottomAction: PrimaryButton(
        label: 'Guardar recordatorio',
        icon: Icons.check,
        onPressed: _save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('¿Qué quieres recordar?'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in ReminderKind.values)
                ChoiceChipTile(
                  label: k.label,
                  selected: k == _kind,
                  onTap: () => setState(() {
                    _kind = k;
                    if (!_titleEdited) _title.text = k.defaultTitle;
                  }),
                ),
            ],
          ),
          const FieldLabel('Título'),
          IconTextField(
            controller: _title,
            icon: Icons.notifications_none,
            onChanged: (_) => _titleEdited = true,
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Fecha'),
                    PickerField(
                      icon: Icons.event_outlined,
                      text: shortDate(_date),
                      onTap: _pickDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Hora'),
                    PickerField(
                      icon: Icons.schedule,
                      text: fmtTime(_time),
                      onTap: _pickTime,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const FieldLabel('Repetir'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChipTile(
                label: 'Solo una vez',
                selected: !_daily,
                onTap: () => setState(() => _daily = false),
              ),
              ChoiceChipTile(
                label: 'Todos los días',
                selected: _daily,
                onTap: () => setState(() => _daily = true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
