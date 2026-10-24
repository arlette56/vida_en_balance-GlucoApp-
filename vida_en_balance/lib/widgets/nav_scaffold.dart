import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme.dart';

/// Pestañas de la barra inferior. El orden coincide con el diagrama.
enum NavTab {
  inicio('Inicio', Icons.home_outlined, Routes.menu),
  historial('Historial', Icons.bar_chart_rounded, Routes.historial),
  alimentacion('Alimentación', Icons.restaurant, Routes.alimentacion),
  ajustes('Ajustes', Icons.settings_outlined, Routes.ajustes);

  const NavTab(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

/// Estructura común: encabezado con «atrás» y título, contenido, acción
/// inferior opcional y barra de navegación opcional.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.showBack = true,
    this.tab,
    this.showNav = false,
    this.bottomAction,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 16),
    this.scrollable = true,
  });

  final String? title;
  final Widget child;
  final bool showBack;

  /// Pestaña resaltada en la barra inferior (solo si [showNav]).
  final NavTab? tab;
  final bool showNav;
  final Widget? bottomAction;
  final EdgeInsets padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: showBack
                          ? IconButton(
                              tooltip: 'Regresar',
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.chevron_left_rounded,
                                  size: 32, color: AppColors.forestDark),
                            )
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            Expanded(
              child: scrollable
                  ? SingleChildScrollView(padding: padding, child: child)
                  : Padding(padding: padding, child: child),
            ),
            if (bottomAction != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: bottomAction,
              ),
            if (showNav) AppBottomBar(current: tab),
          ],
        ),
      ),
    );
  }
}

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({super.key, this.current});
  final NavTab? current;

  void _go(BuildContext context, NavTab t) {
    if (t == current) return;
    final nav = Navigator.of(context);
    if (t == NavTab.inicio) {
      nav.popUntil((r) => r.settings.name == Routes.menu);
    } else {
      // Mantiene el menú como base de la pila: «atrás» siempre vuelve a él.
      nav.pushNamedAndRemoveUntil(
          t.route, (r) => r.settings.name == Routes.menu);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.sageLine)),
      ),
      child: Row(
        children: [
          for (final t in NavTab.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: t == current,
                label: t.label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _go(context, t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          t == current ? AppColors.sageSoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon,
                            size: 24,
                            color: t == current
                                ? AppColors.forest
                                : AppColors.muted),
                        const SizedBox(height: 2),
                        Text(
                          t.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: t == current
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: t == current
                                ? AppColors.forest
                                : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
