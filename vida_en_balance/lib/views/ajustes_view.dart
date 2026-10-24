import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../format.dart';
import '../routes.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// 13 · Ajustes
class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  Future<void> _copyCode(BuildContext context, String code) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: code));
    messenger.showSnackBar(
      const SnackBar(content: Text('Código copiado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final user = s.user!;

    return AppScaffold(
      title: 'Ajustes',
      showNav: true,
      tab: NavTab.ajustes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Perfil'),
          SoftCard(
            child: Row(
              children: [
                const _Avatar(size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.nombre,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(user.role.label,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, Routes.perfil),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.forest,
                    side: const BorderSide(color: AppColors.sageLine),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
          if (s.can(Permission.compartirAcceso) && user.linkCode != null) ...[
            const _SectionHeader('Dar acceso a mi familiar o médico'),
            SoftCard(
              color: AppColors.sageSoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comparte este código solo con quien quieras que '
                    'acompañe tu salud. Lo pedirán al crear su cuenta.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(user.linkCode!,
                            style: const TextStyle(
                                fontSize: 22,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.forestDark)),
                      ),
                      IconButton(
                        tooltip: 'Copiar código',
                        icon: const Icon(Icons.copy, color: AppColors.forest),
                        onPressed: () => _copyCode(context, user.linkCode!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            const _SectionHeader('Acompañando a'),
            RoleBanner(role: user.role, patientName: s.patient?.nombre),
          ],
          const _SectionHeader('Tamaño del texto'),
          Row(
            children: [
              for (final o in TextSizeOption.values)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: o == TextSizeOption.muyGrande ? 0 : 10),
                    child: _SizeTile(
                      option: o,
                      selected: s.textSize == o,
                      onTap: () => s.setTextSize(o),
                    ),
                  ),
                ),
            ],
          ),
          const _SectionHeader('Vista previa'),
          const SoftCard(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hoy es un gran día',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Así se verá el texto en toda la aplicación.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                // Primero se quitan las pantallas con datos y luego se cierra
                // la sesión, para que ninguna se reconstruya sin usuario.
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.login, (_) => false);
                s.signOut();
              },
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Cerrar sesión',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text('Balance', style: scriptStyle(30, color: AppColors.sage)),
                const Text('Versión 1.0',
                    style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.muted)),
      );
}

class _SizeTile extends StatelessWidget {
  const _SizeTile(
      {required this.option, required this.selected, required this.onTap});
  final TextSizeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // La «A» de muestra usa un tamaño fijo propio para que la comparación
    // sea visible incluso con el escalado global ya aplicado.
    final sample = switch (option) {
      TextSizeOption.normal => 16.0,
      TextSizeOption.grande => 22.0,
      TextSizeOption.muyGrande => 28.0,
    };
    return Semantics(
      button: true,
      selected: selected,
      label: 'Texto ${option.label}',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
              Text('A',
                  style: TextStyle(
                      fontSize: sample,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.forest : AppColors.ink)),
              const SizedBox(height: 4),
              Text(option.label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
            color: AppColors.sage, shape: BoxShape.circle),
        child: Icon(Icons.person_outline,
            size: size * 0.55, color: Colors.white),
      );
}

/// 14 · Mi perfil
class MiPerfilScreen extends StatefulWidget {
  const MiPerfilScreen({super.key});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  static const _sexOptions = ['Femenino', 'Masculino', 'Otro'];

  TextEditingController? _name;
  TextEditingController? _goal;
  TextEditingController? _email;
  DateTime? _birth;
  String _sex = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_name == null) {
      final u = AppScope.of(context).user!;
      _name = TextEditingController(text: u.nombre);
      _goal = TextEditingController(text: u.objetivo);
      _email = TextEditingController(text: u.correo);
      _birth = u.fechaNacimiento;
      _sex = u.sexo;
    }
  }

  @override
  void dispose() {
    _name?.dispose();
    _goal?.dispose();
    _email?.dispose();
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

  void _save() {
    AppScope.of(context).saveProfile(
      nombre: _name!.text,
      fechaNacimiento: _birth,
      sexo: _sex,
      objetivo: _goal!.text,
    );
    Navigator.pop(context); // vuelve a Ajustes
  }

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).user!;
    final first = _name!.text.trim().isEmpty
        ? 'Usuario'
        : _name!.text.trim().split(RegExp(r'\s+')).first;

    return AppScaffold(
      title: 'Mi perfil',
      bottomAction: PrimaryButton(
        label: 'Guardar',
        icon: Icons.check,
        onPressed: _save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Center(child: _Avatar(size: 88)),
          const FieldLabel('¿Cómo te llamas?'),
          IconTextField(
            controller: _name!,
            icon: Icons.person_outline,
            hint: 'Tu nombre',
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const FieldLabel('Correo (no se puede cambiar aquí)'),
          IconTextField(
            controller: _email!,
            icon: Icons.mail_outline,
            enabled: false,
          ),
          const FieldLabel('Fecha de nacimiento'),
          PickerField(
            icon: Icons.cake_outlined,
            text: _birth == null ? 'Elegir fecha' : fmtFullDate(_birth!),
            onTap: _pickBirth,
          ),
          const FieldLabel('Sexo'),
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
          if (user.role.isCliente) ...[
            const FieldLabel('Mi objetivo'),
            IconTextField(
              controller: _goal!,
              icon: Icons.flag_outlined,
              hint: 'Ej. Mantener mi glucosa en rango',
            ),
          ],
          const FieldLabel('Tipo de usuario'),
          RoleBanner(role: user.role),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8DC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Tu nombre aparecerá en el saludo de inicio: «¡Hola, $first!»',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}