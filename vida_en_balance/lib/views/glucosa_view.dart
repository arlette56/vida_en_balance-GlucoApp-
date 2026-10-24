import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../format.dart';
import '../routes.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

// Límites fisiológicos: los glucómetros marcan "LO" por debajo de 20 y
// "HI" por encima de 600 mg/dL, así que no se aceptan valores fuera de eso.
const _gMin = 20;
const _gMax = 600;

Color _gaugeColor(int v) {
  if (v < glucoseLow) return AppColors.amber;
  if (v > glucoseHigh) return AppColors.danger;
  return AppColors.forest;
}

/// 03 · Registrar glucosa
class RegistrarGlucosaScreen extends StatefulWidget {
  const RegistrarGlucosaScreen({super.key});

  @override
  State<RegistrarGlucosaScreen> createState() => _RegistrarGlucosaScreenState();
}

class _RegistrarGlucosaScreenState extends State<RegistrarGlucosaScreen> {
  int _value = 112;
  GlucoseMoment _moment = GlucoseMoment.ayunas;

  Timer? _hold;

  void _step(int d) {
    final next = (_value + d).clamp(_gMin, _gMax).toInt();
    if (next == _value) {
      _hold?.cancel();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(d > 0
                ? 'El valor máximo permitido es $_gMax mg/dL'
                : 'El valor mínimo permitido es $_gMin mg/dL')));
      return;
    }
    setState(() => _value = next);
  }

  // Mantener presionado repite el cambio, cada vez más rápido.
  void _startHold(int d) {
    var ticks = 0;
    _hold?.cancel();
    _hold = Timer.periodic(const Duration(milliseconds: 120), (_) {
      ticks++;
      _step(d * (ticks > 15 ? 10 : (ticks > 6 ? 5 : 1)));
    });
  }

  void _stopHold() => _hold?.cancel();

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  void _save() {
    final r = AppScope.of(context).addReading(_value, _moment);
    // Reemplaza el formulario: «Aceptar» en 04 regresa al menú.
    Navigator.pushReplacementNamed(context, Routes.glucosaRegistrada,
        arguments: r);
  }

  @override
  Widget build(BuildContext context) {
    final color = _gaugeColor(_value);
    final t = (_value - _gMin) / (_gMax - _gMin);

    return AppScaffold(
      title: 'Registrar glucosa',
      showNav: true,
      tab: NavTab.inicio,
      bottomAction: PrimaryButton(
        label: 'Guardar registro',
        icon: Icons.check,
        onPressed: _save,
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: 250,
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GaugePainter(t: t, color: color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tu nivel actual',
                        style: TextStyle(fontSize: 12, color: AppColors.muted)),
                    Semantics(
                      liveRegion: true,
                      child: Text('$_value',
                          style: const TextStyle(
                              fontSize: 56,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              color: AppColors.forestDark)),
                    ),
                    const Text('mg/dL',
                        style: TextStyle(fontSize: 15, color: AppColors.muted)),
                  ],
                ),
                Positioned(
                  left: 4,
                  bottom: 0,
                  child: _RoundStep(
                      icon: Icons.remove,
                      label: 'Bajar',
                      onTap: () => _step(-1),
                      onHoldStart: () => _startHold(-1),
                      onHoldEnd: _stopHold),
                ),
                Positioned(
                  right: 4,
                  bottom: 0,
                  child: _RoundStep(
                      icon: Icons.add,
                      label: 'Subir',
                      onTap: () => _step(1),
                      onHoldStart: () => _startHold(1),
                      onHoldEnd: _stopHold),
                ),
              ],
            ),
          ),
          const Text('Toca – o + (o mantenlo presionado) para ajustar',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 12),
          const Align(
              alignment: Alignment.centerLeft,
              child: FieldLabel('Momento de la medición')),
          Row(
            children: [
              for (final m in GlucoseMoment.values)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: m == GlucoseMoment.antesDeDormir ? 0 : 10),
                    child: _MomentTile(
                      moment: m,
                      selected: m == _moment,
                      onTap: () => setState(() => _moment = m),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundStep extends StatelessWidget {
  const _RoundStep(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.onHoldStart,
      required this.onHoldEnd});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.forest,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          onLongPress: onHoldStart,
          onTapUp: (_) => onHoldEnd(),
          onTapCancel: onHoldEnd,
          child: SizedBox(
              width: 52, height: 52, child: Icon(icon, color: Colors.white)),
        ),
      ),
    );
  }
}

class _MomentTile extends StatelessWidget {
  const _MomentTile(
      {required this.moment, required this.selected, required this.onTap});
  final GlucoseMoment moment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.sageSoft : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.forest : AppColors.sageLine,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(moment.icon,
                  size: 26,
                  color: selected ? AppColors.forest : AppColors.muted),
              const SizedBox(height: 6),
              Text(moment.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.t, required this.color});
  final double t; // 0..1
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - stroke;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = 0.75 * math.pi; // 135°
    const sweep = 1.5 * math.pi; // 270°

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.sageLine;
    canvas.drawArc(rect, start, sweep, false, track);

    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, start, sweep * t.clamp(0.0, 1.0), false, prog);

    final a = start + sweep * t.clamp(0.0, 1.0);
    final thumb = Offset(
        center.dx + radius * math.cos(a), center.dy + radius * math.sin(a));
    canvas.drawCircle(thumb, 11, Paint()..color = Colors.white);
    canvas.drawCircle(
        thumb,
        11,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.t != t || old.color != color;
}

/// 04 · Glucosa registrada
class GlucosaRegistradaScreen extends StatelessWidget {
  const GlucosaRegistradaScreen({super.key, required this.reading});
  final GlucoseReading reading;

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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                      color: AppColors.sageSoft, shape: BoxShape.circle),
                  child: const Icon(Icons.water_drop,
                      size: 40, color: AppColors.forest),
                ),
                const SizedBox(height: 16),
                Text('Glucosa', style: scriptStyle(36)),
                Text('Registrada', style: scriptStyle(46)),
                const SizedBox(height: 24),
                SoftCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _Row('Valor', '${reading.value} mg/dL'),
                      const Divider(height: 1, color: AppColors.sageLine),
                      _Row('Momento', reading.moment.label),
                      const Divider(height: 1, color: AppColors.sageLine),
                      _Row('Fecha y hora', fmtDateTime(reading.at)),
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
                            Icon(Icons.check,
                                size: 18, color: AppColors.forest),
                            SizedBox(width: 8),
                            Text('Guardado correctamente',
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
                  onPressed: () => Navigator.popUntil(
                      context, (r) => r.settings.name == Routes.menu),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: AppColors.muted)),
            Flexible(
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
}