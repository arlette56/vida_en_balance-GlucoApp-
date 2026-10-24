import 'package:flutter/material.dart';

import '../format.dart';
import '../routes.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

const _sexOptions = ['Femenino', 'Masculino', 'Otro'];

/// Crear cuenta: elige el tipo de usuario y completa el perfil.
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  UserRole _role = UserRole.cliente;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _goal = TextEditingController();
  final _code = TextEditingController();
  DateTime? _birth;
  String _sex = '';
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _goal.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(now.year - 60, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (d != null) setState(() => _birth = d);
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await AppScope.of(context).register(
      nombre: _name.text,
      correo: _email.text,
      password: _pass.text,
      role: _role,
      fechaNacimiento: _birth,
      sexo: _sex,
      objetivo: _goal.text,
      linkCode: _code.text,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _busy = false;
        _error = err;
      });
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, Routes.menu, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Crear cuenta',
      bottomAction: PrimaryButton(
        label: _busy ? 'Creando…' : 'Crear cuenta',
        icon: Icons.check,
        onPressed: _busy ? null : _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('¿Cómo vas a usar la app?'),
          for (final r in UserRole.values) ...[
            _RoleCard(
              role: r,
              selected: r == _role,
              onTap: () => setState(() => _role = r),
            ),
            const SizedBox(height: 10),
          ],
          const FieldLabel('Nombre'),
          IconTextField(
            controller: _name,
            icon: Icons.person_outline,
            hint: 'Tu nombre completo',
            textCapitalization: TextCapitalization.words,
          ),
          const FieldLabel('Correo'),
          IconTextField(
            controller: _email,
            icon: Icons.mail_outline,
            hint: 'nombre@correo.com',
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
          ),
          const FieldLabel('Contraseña'),
          IconTextField(
            controller: _pass,
            icon: Icons.lock_outline,
            obscureText: _obscure,
            textCapitalization: TextCapitalization.none,
            suffix: IconButton(
              tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                  size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text('Mínimo 8 caracteres, con letras y números.',
                style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ),
          const FieldLabel('Fecha de nacimiento (opcional)'),
          PickerField(
            icon: Icons.cake_outlined,
            text: _birth == null ? 'Elegir fecha' : fmtFullDate(_birth!),
            onTap: _pickBirth,
          ),
          const FieldLabel('Sexo (opcional)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in _sexOptions)
                ChoiceChipTile(
                  label: o,
                  selected: _sex == o,
                  onTap: () => setState(() => _sex = _sex == o ? '' : o),
                ),
            ],
          ),
          if (_role.isCliente) ...[
            const FieldLabel('Tu objetivo (opcional)'),
            IconTextField(
              controller: _goal,
              icon: Icons.flag_outlined,
              hint: 'Ej. Mantener mi glucosa en rango',
            ),
          ] else ...[
            const FieldLabel('Código de vinculación'),
            IconTextField(
              controller: _code,
              icon: Icons.link,
              hint: 'VIDA-XXXXX',
              textCapitalization: TextCapitalization.characters,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Text(
                  'Pídeselo al cliente: lo encuentra en Ajustes. '
                  'Sin código no se puede acceder a sus datos.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            ErrorBanner(_error!),
          ],
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard(
      {required this.role, required this.selected, required this.onTap});
  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.sageSoft : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.forest : AppColors.sageLine,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(role.icon,
                  size: 26,
                  color: selected ? AppColors.forest : AppColors.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role.label,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(role.description,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted)),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: AppColors.forest),
            ],
          ),
        ),
      ),
    );
  }
}
