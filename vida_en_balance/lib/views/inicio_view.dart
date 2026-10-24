import 'package:flutter/material.dart';

import '../routes.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// 01 · Inicio (bienvenida), con el botón «Comenzar» del diagrama de flujo.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.sageSoft, AppColors.bg, AppColors.sageSoft],
          ),
        ),
        child: SafeArea(
          child: ScrollableFill(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Text('Vida en', style: scriptStyle(34)),
                Text('Balance', style: scriptStyle(56)),
                const Spacer(),
                // Ilustración de la pareja (assets/pareja.png), tomada de tu diseño.
                const AppImage(
                  'assets/pareja.png',
                  height: 220,
                  fallback: IllustrationPlaceholder(
                    icons: [Icons.elderly, Icons.elderly_woman],
                    size: 220,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Pequeños hábitos hacen\ngrandes cambios en tu salud.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const Spacer(flex: 2),
                PrimaryButton(
                  label: 'Comenzar',
                  // Con sesión abierta va al menú; si no, al inicio de sesión.
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppScope.of(context).isSignedIn
                        ? Routes.menu
                        : Routes.login,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
