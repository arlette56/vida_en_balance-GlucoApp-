import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'routes.dart';
import 'state.dart';
import 'theme.dart';

void main() => runApp(const VidaEnBalanceApp());

class VidaEnBalanceApp extends StatefulWidget {
  const VidaEnBalanceApp({super.key});

  @override
  State<VidaEnBalanceApp> createState() => _VidaEnBalanceAppState();
}

class _VidaEnBalanceAppState extends State<VidaEnBalanceApp> {
  final _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'Vida en Balance',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: const Locale('es', 'MX'),
        supportedLocales: const [Locale('es', 'MX'), Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Aplica el «Tamaño del texto» de Ajustes a toda la app.
        builder: (context, child) {
          final scale = AppScope.of(context).textSize.scale;
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          );
        },
        initialRoute: Routes.splash,
        onGenerateRoute: buildRouter(_state),
      ),
    );
  }
}
