import 'package:flutter/material.dart';

import '../routes.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// Se muestra si el rol actual no tiene permiso para la pantalla pedida.
class AccesoDenegadoScreen extends StatelessWidget {
  const AccesoDenegadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                    color: AppColors.dangerSoft, shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline,
                    size: 40, color: AppColors.danger),
              ),
              const SizedBox(height: 20),
              const Text('Acceso no permitido',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                s.user == null
                    ? 'Inicia sesión para continuar.'
                    : 'Tu perfil (${s.user!.role.label}) no tiene permiso '
                        'para entrar a esta sección.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const Spacer(flex: 2),
              PrimaryButton(
                label: s.user == null ? 'Ir al inicio de sesión' : 'Volver al menú',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  s.user == null ? Routes.login : Routes.menu,
                  (_) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
