import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../format.dart';
import '../routes.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// 06 · Mis medicamentos
class MisMedicamentosScreen extends StatelessWidget {
  const MisMedicamentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final total = s.meds.length;
    final next = s.nextMed;

    return AppScaffold(
      title: 'Mis medicamentos',
      showNav: true,
      tab: NavTab.inicio,
      bottomAction: s.can(Permission.agregarMedicamento)
          ? PrimaryButton(
              label: 'Agregar medicamento',
              icon: Icons.add,
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.agregarMedicamento),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progreso de hoy',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('${s.takenCount} de $total',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.forest)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: total == 0 ? 0 : s.takenCount / total,
                    backgroundColor: AppColors.sageLine,
                    color: AppColors.forest,
                  ),
                ),
              ],
            ),
          ),
          const FieldLabel('Medicamentos programados'),
          for (final m in s.meds) ...[
            _MedTile(med: m, isNext: identical(m, next)),
            const SizedBox(height: 12),
          ],
          if (s.meds.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Aún no hay medicamentos registrados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted)),
              ),
            ),
        ],
      ),
    );
  }
}

class _MedTile extends StatelessWidget {
  const _MedTile({required this.med, required this.isNext});
  final Medication med;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SoftCard(
      color: isNext ? const Color(0xFFFFFBEA) : Colors.white,
      borderColor: isNext ? const Color(0xFFE9D48A) : AppColors.sageLine,
      child: Row(
        children: [
          Icon(
            med.taken
                ? Icons.check_circle
                : isNext
                    ? Icons.access_time_filled
                    : Icons.radio_button_unchecked,
            color: med.taken
                ? AppColors.forest
                : isNext
                    ? AppColors.amber
                    : AppColors.muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(med.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    if (isNext) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amberSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Próxima',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.amber)),
                      ),
                    ],
                  ],
                ),
                Text(med.detail,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.muted)),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(fmtTime(med.time),
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (med.taken)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.sageLine),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 16, color: AppColors.forest),
                  SizedBox(width: 4),
                  Text('Tomado',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest)),
                ],
              ),
            )
          else if (!s.can(Permission.marcarToma))
            const Text('Pendiente',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted))
          else
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sage,
                foregroundColor: AppColors.forestDark,
                minimumSize: const Size(72, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
              ),
              onPressed: () {
                s.takeMed(med);
                Navigator.pushNamed(context, Routes.medicamentoRegistrado,
                    arguments: med);
              },
              child: const Text('Tomar',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

/// 07 · Agregar medicamento
class AgregarMedicamentoScreen extends StatefulWidget {
  const AgregarMedicamentoScreen({super.key});

  @override
  State<AgregarMedicamentoScreen> createState() =>
      _AgregarMedicamentoScreenState();
}

class _AgregarMedicamentoScreenState extends State<AgregarMedicamentoScreen> {
  static const _whenOptions = [
    'Con el desayuno',
    'Con la comida',
    'Con la cena',
    'Otro',
  ];

  final _name = TextEditingController();
  final _dose = TextEditingController();
  int _when = 0;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = 'Escribe el nombre del medicamento');
      return;
    }
    final label = _whenOptions[_when];
    AppScope.of(context).addMed(Medication(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      dose: _dose.text.trim(),
      when: label == 'Otro' ? '' : label.toLowerCase(),
      time: _time,
    ));
    Navigator.pop(context); // vuelve a Mis medicamentos
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Agregar medicamento',
      bottomAction: PrimaryButton(
        label: 'Guardar medicamento',
        icon: Icons.check,
        onPressed: _save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('Nombre del medicamento'),
          IconTextField(
            controller: _name,
            icon: Icons.medication_outlined,
            hint: 'Ej. Metformina',
            errorText: _nameError,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const FieldLabel('Dosis'),
          IconTextField(
            controller: _dose,
            icon: Icons.wb_sunny_outlined,
            hint: 'Ej. 850 mg',
            textCapitalization: TextCapitalization.none,
          ),
          const FieldLabel('¿Cuándo se toma?'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _whenOptions.length; i++)
                ChoiceChipTile(
                  label: _whenOptions[i],
                  selected: i == _when,
                  onTap: () => setState(() => _when = i),
                ),
            ],
          ),
          const FieldLabel('Hora'),
          SoftCard(
            color: AppColors.sageSoft,
            child: TimeWheel(
              initial: _time,
              onChanged: (t) => _time = t,
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector de hora con tres ruedas (hora · minutos · a. m./p. m.).
class TimeWheel extends StatefulWidget {
  const TimeWheel({super.key, required this.initial, required this.onChanged});
  final TimeOfDay initial;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  State<TimeWheel> createState() => _TimeWheelState();
}

class _TimeWheelState extends State<TimeWheel> {
  late int _hour12; // 1..12
  late int _minute;
  late bool _pm;
  late final FixedExtentScrollController _hc;
  late final FixedExtentScrollController _mc;
  late final FixedExtentScrollController _pc;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    _minute = t.minute;
    _pm = t.period == DayPeriod.pm;
    _hc = FixedExtentScrollController(initialItem: _hour12 - 1);
    _mc = FixedExtentScrollController(initialItem: _minute);
    _pc = FixedExtentScrollController(initialItem: _pm ? 1 : 0);
  }

  @override
  void dispose() {
    _hc.dispose();
    _mc.dispose();
    _pc.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged(
      TimeOfDay(hour: (_hour12 % 12) + (_pm ? 12 : 0), minute: _minute));

  Widget _wheel(FixedExtentScrollController c, List<String> items,
      ValueChanged<int> onSel, double width) {
    return SizedBox(
      width: width,
      child: CupertinoPicker(
        scrollController: c,
        itemExtent: 40,
        onSelectedItemChanged: (i) {
          onSel(i);
          _emit();
        },
        children: [
          for (final t in items)
            Center(
              child: Text(t,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _wheel(_hc, [for (var h = 1; h <= 12; h++) '$h'],
              (i) => _hour12 = i + 1, 64),
          const Text(':',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          _wheel(_mc, [for (var m = 0; m < 60; m++) m.toString().padLeft(2, '0')],
              (i) => _minute = i, 64),
          _wheel(_pc, const ['a. m.', 'p. m.'], (i) => _pm = i == 1, 84),
        ],
      ),
    );
  }
}

/// 08 · Medicamento registrado
class MedicamentoRegistradoScreen extends StatelessWidget {
  const MedicamentoRegistradoScreen({super.key, required this.med});
  final Medication med;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.sageSoft, AppColors.bg],
          ),
        ),
        child: SafeArea(
          child: ScrollableFill(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                // Foto de medicinas del diseño: guardar en assets/medicinas.png.
                const AppImage('assets/medicinas.png', height: 130),
                const SizedBox(height: 8),
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                      color: AppColors.forest, shape: BoxShape.circle),
                  child:
                      const Icon(Icons.check, size: 52, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text('Medicamento', style: scriptStyle(36)),
                Text('Registrado', style: scriptStyle(46)),
                const SizedBox(height: 24),
                SoftCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.medication_outlined,
                                color: AppColors.forest),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(med.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  Text(med.detail,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.muted)),
                                  Text(fmtTime(med.time),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.muted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          color: AppColors.sageSoft,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(18)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 18, color: AppColors.forest),
                            SizedBox(width: 8),
                            Text('Tomado correctamente',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forest)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                PrimaryButton(
                  label: 'Aceptar',
                  onPressed: () => Navigator.pop(context), // Mis medicamentos
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
