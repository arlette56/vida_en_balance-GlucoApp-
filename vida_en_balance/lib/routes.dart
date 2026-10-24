import 'package:flutter/material.dart';

import 'views/acceso_denegado_view.dart';
import 'views/ajustes_view.dart';
import 'views/alimentacion_view.dart';
import 'views/glucosa_view.dart';
import 'views/historial_view.dart';
import 'views/inicio_view.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/medicamentos_view.dart';
import 'views/menu_view.dart';
import 'views/motivacion_view.dart';
import 'views/recordatorios_view.dart';
import 'views/registro_view.dart';
import 'state.dart';

/// Nombres de ruta; el número corresponde al del diagrama de flujo.
class Routes {
  static const splash = '/'; // splashscreen
  static const inicio = '/inicio'; // 01
  static const login = '/login';
  static const registro = '/registro';
  static const menu = '/menu'; // 02
  static const glucosa = '/glucosa'; // 03
  static const glucosaRegistrada = '/glucosa/registrada'; // 04
  static const historial = '/historial'; // 05
  static const medicamentos = '/medicamentos'; // 06
  static const agregarMedicamento = '/medicamentos/agregar'; // 07
  static const medicamentoRegistrado = '/medicamentos/registrado'; // 08
  static const alimentacion = '/alimentacion'; // 09
  static const recordatorios = '/recordatorios'; // 10
  static const agregarRecordatorio = '/recordatorios/agregar'; // 11
  static const motivacion = '/motivacion'; // 12
  static const ajustes = '/ajustes'; // 13
  static const perfil = '/ajustes/perfil'; // 14
}

/// Rutas accesibles sin sesión.
const _publicRoutes = {Routes.splash, Routes.inicio, Routes.login, Routes.registro};

/// Permiso necesario por ruta. Las rutas que no aparecen aquí (menú,
/// ajustes, perfil) solo piden haber iniciado sesión.
const _requiredPermission = <String, Permission>{
  Routes.glucosa: Permission.registrarGlucosa,
  Routes.glucosaRegistrada: Permission.registrarGlucosa,
  Routes.historial: Permission.verHistorial,
  Routes.medicamentos: Permission.verMedicamentos,
  Routes.agregarMedicamento: Permission.agregarMedicamento,
  Routes.medicamentoRegistrado: Permission.marcarToma,
  Routes.alimentacion: Permission.verAlimentacion,
  Routes.recordatorios: Permission.verRecordatorios,
  Routes.agregarRecordatorio: Permission.administrarRecordatorios,
  Routes.motivacion: Permission.verMotivacion,
};

/// Generador de rutas con guardia de acceso: sin sesión redirige al login y
/// sin permiso muestra «Acceso no permitido».
RouteFactory buildRouter(AppState state) {
  return (RouteSettings s) {
    final name = s.name ?? Routes.splash;
    final Widget page;

    final needed = _requiredPermission[name];
    if (!_publicRoutes.contains(name) && !state.isSignedIn) {
      page = const LoginScreen();
    } else if (needed != null && !state.can(needed)) {
      page = const AccesoDenegadoScreen();
    } else {
      switch (name) {
        case Routes.splash:
          page = const SplashScreen();
        case Routes.inicio:
          page = const InicioScreen();
        case Routes.login:
          page = const LoginScreen();
        case Routes.registro:
          page = const RegistroScreen();
        case Routes.menu:
          page = const MenuScreen();
        case Routes.glucosa:
          page = const RegistrarGlucosaScreen();
        case Routes.glucosaRegistrada:
          page =
              GlucosaRegistradaScreen(reading: s.arguments as GlucoseReading);
        case Routes.historial:
          page = const HistorialScreen();
        case Routes.medicamentos:
          page = const MisMedicamentosScreen();
        case Routes.agregarMedicamento:
          page = const AgregarMedicamentoScreen();
        case Routes.medicamentoRegistrado:
          page = MedicamentoRegistradoScreen(med: s.arguments as Medication);
        case Routes.alimentacion:
          page = const AlimentacionScreen();
        case Routes.recordatorios:
          page = const RecordatoriosScreen();
        case Routes.agregarRecordatorio:
          page = const AgregarRecordatorioScreen();
        case Routes.motivacion:
          page = const MotivacionScreen();
        case Routes.ajustes:
          page = const AjustesScreen();
        case Routes.perfil:
          page = const MiPerfilScreen();
        default:
          return null;
      }
    }

    return PageRouteBuilder<void>(
      settings: s,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
    );
  };
}
