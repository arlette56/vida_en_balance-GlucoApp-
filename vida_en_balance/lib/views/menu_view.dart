import 'package:flutter/material.dart';

import '../format.dart';
import '../routes.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// 02 · Menú principal
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final last = s.lastReading;

    final user = s.user!;
    final isOwner = user.role.isCliente;

    return AppScaffold(
      showBack: false,
      showNav: true,
      tab: NavTab.inicio,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Brillo de la esquina (amarillo y verde), como en el diseño.
          Positioned(
            top: -60,
            left: -60,
            child: IgnorePointer(
              child: Stack(
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFFF6E58B)),
                  ),
                  Container(
                    width: 125,
                    height: 125,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFFB9D17C)),
                  ),
                ],
              ),
            ),
          ),
          _content(context, s, last, user, isOwner),
        ],
      ),
    );
  }

  String _mensaje(UserRole role, String? cliente) {
    final nombre = (cliente ?? 'tu familiar').split(' ').first;
    switch (role) {
      case UserRole.cliente:
        return 'Hoy es un gran día para cuidar de tu salud.';
      case UserRole.operador:
        return 'Gracias por acompañar a $nombre en su cuidado de hoy.';
      case UserRole.administrador:
        return 'Revisa el avance de $nombre y mantén todo al día.';
    }
  }

  Widget _content(BuildContext context, AppState s, GlucoseReading? last,
      AppUser user, bool isOwner) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¡Hola, ${s.displayName}!',
                        style: scriptStyle(34, color: AppColors.forestDark)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 250,
                      child: Text(
                        _mensaje(user.role, s.patient?.nombre),
                        style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D211A)),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.wb_sunny_rounded,
                  size: 44, color: Color(0xFFF2BE45)),
            ],
          ),
          if (!isOwner) ...[
            const SizedBox(height: 12),
            RoleBanner(role: user.role, patientName: s.patient?.nombre),
          ],
          const SizedBox(height: 20),
          // Resumen propio de cada rol (cliente, operador, administrador).
          const RoleDashboard(),
          _MenuPill(
            icon: Icons.water_drop_outlined,
            iconColor: _blue,
            tall: true,
            // Sin permiso para registrar, la tarjeta lleva al historial.
            onTap: () => Navigator.pushNamed(
              context,
              s.can(Permission.registrarGlucosa)
                  ? Routes.glucosa
                  : Routes.historial,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Última glucosa',
                    style: TextStyle(fontSize: 13, color: AppColors.muted)),
                Text(
                  last == null ? '—' : '${last.value} mg/dL',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.forestDark),
                ),
                if (last != null)
                  Text(ago(last.at),
                      style:
                          const TextStyle(fontSize: 13, color: AppColors.muted)),
              ],
            ),
          ),
          if (s.can(Permission.registrarGlucosa)) ...[
            const SizedBox(height: 16),
            _MenuPill(
              icon: Icons.water_drop_outlined,
              iconColor: _blue,
              label: 'Registrar glucosa',
              onTap: () => Navigator.pushNamed(context, Routes.glucosa),
            ),
          ],
          if (s.can(Permission.verMedicamentos)) ...[
            const SizedBox(height: 16),
            _MenuPill(
              icon: Icons.medication_outlined,
              iconWidget: const _CapsuleIcon(),
              label: isOwner ? 'Mis medicamentos' : 'Medicamentos',
              onTap: () => Navigator.pushNamed(context, Routes.medicamentos),
            ),
          ],
          if (s.can(Permission.verAlimentacion)) ...[
            const SizedBox(height: 16),
            _MenuPill(
              icon: Icons.restaurant,
              iconColor: const Color(0xFF333333),
              label: isOwner ? 'Mi alimentación' : 'Alimentación',
              onTap: () => Navigator.pushNamed(context, Routes.alimentacion),
            ),
          ],
          if (s.can(Permission.verRecordatorios)) ...[
            const SizedBox(height: 16),
            _MenuPill(
              icon: Icons.schedule,
              iconColor: const Color(0xFF666666),
              label: 'Recordatorios',
              onTap: () => Navigator.pushNamed(context, Routes.recordatorios),
            ),
          ],
          if (s.can(Permission.verMotivacion)) ...[
            const SizedBox(height: 16),
            _MenuPill(
              icon: Icons.favorite_border,
              iconColor: AppColors.danger,
              label: 'Motivación',
              onTap: () => Navigator.pushNamed(context, Routes.motivacion),
            ),
          ],
        ],
    );
  }
}

const _blue = Color(0xFF3E7FB5);

class _CapsuleIcon extends StatelessWidget {
  const _CapsuleIcon();

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(painter: _CapsulePainter());
}

class _CapsulePainter extends CustomPainter {
  const _CapsulePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF777777)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.785);
    final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 22, height: 11),
        const Radius.circular(5.5));
    canvas.drawRRect(r, paint);
    canvas.drawLine(const Offset(0, -5.5), const Offset(0, 5.5), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CapsulePainter old) => false;
}

class _MenuPill extends StatelessWidget {
  const _MenuPill({
    required this.icon,
    required this.onTap,
    this.label,
    this.child,
    this.iconWidget,
    this.tall = false,
    this.iconColor = AppColors.forest,
  });
  final IconData icon;
  final String? label;
  final Widget? child;
  final Widget? iconWidget;
  final bool tall;
  final Color iconColor;
  final VoidCallback onTap;

  Widget _fallbackIcon() => Container(
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: iconWidget ?? Icon(icon, size: 24, color: iconColor),
      );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: AppColors.sage,
        borderRadius: BorderRadius.circular(tall ? 32 : 28),
        child: InkWell(
          borderRadius: BorderRadius.circular(tall ? 32 : 28),
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: tall ? 92 : 64),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              children: [
                // Círculo blanco con el ícono.
                SizedBox(
                  width: 46,
                  height: 46,
                  child: _fallbackIcon(),
                ),
                Expanded(
                  child: Center(
                    child: child ??
                        Text(label!,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.forestDark)),
                  ),
                ),
                const SizedBox(width: 46),
              ],
            ),
          ),
        ),
      ),
    );
  }
}