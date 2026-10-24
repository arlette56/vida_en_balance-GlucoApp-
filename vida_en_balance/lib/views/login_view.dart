import 'package:flutter/material.dart';

import '../routes.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// Inicio de sesión.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      setState(() => _error = 'Escribe tu correo y tu contraseña');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final state = AppScope.of(context);
    final err = await state.signIn(_email.text, _pass.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _busy = false;
        _error = err;
      });
      return;
    }
    // El menú pasa a ser la base de la pila: no se puede volver al login.
    Navigator.pushNamedAndRemoveUntil(context, Routes.menu, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Text('Vida en Balance', style: scriptStyle(42))),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text('Inicia sesión para continuar',
                        style: TextStyle(color: AppColors.muted)),
                  ),
                  const SizedBox(height: 28),
                  const FieldLabel('Correo'),
                  IconTextField(
                    controller: _email,
                    icon: Icons.mail_outline,
                    hint: 'nombre@correo.com',
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const FieldLabel('Contraseña'),
                  IconTextField(
                    controller: _pass,
                    icon: Icons.lock_outline,
                    obscureText: _obscure,
                    textCapitalization: TextCapitalization.none,
                    onSubmitted: (_) => _submit(),
                    autofillHints: const [AutofillHints.password],
                    suffix: IconButton(
                      tooltip:
                          _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    ErrorBanner(_error!),
                  ],
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: _busy ? 'Entrando…' : 'Iniciar sesión',
                    onPressed: _busy ? null : _submit,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.registro),
                    child: const Text('¿No tienes cuenta? Crear cuenta',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.forest)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
