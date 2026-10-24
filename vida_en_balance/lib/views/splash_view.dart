import 'dart:async';

import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme.dart';

/// Splashscreen: marca y barra de carga. Tras unos segundos pasa sola a la
/// pantalla de Inicio (01). Reemplaza la ruta: no se vuelve a ella.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.duration = const Duration(seconds: 3)});

  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.inicio);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
        parent: _anim, curve: const Interval(0, 0.35, curve: Curves.easeOut));
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.sageSoft, AppColors.bg, AppColors.sageSoft],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              FadeTransition(
                opacity: fade,
                child: ScaleTransition(
                  scale: Tween(begin: 0.9, end: 1.0).animate(fade),
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                            color: AppColors.forest, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite_rounded,
                            size: 52, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text('Vida en', style: scriptStyle(34)),
                      Text('Balance', style: scriptStyle(60)),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              FadeTransition(
                opacity: fade,
                child: const Text(
                  'Pequeños hábitos hacen\ngrandes cambios en tu salud.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 72),
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _anim.value,
                      minHeight: 6,
                      color: AppColors.forest,
                      backgroundColor: AppColors.sageLine,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
