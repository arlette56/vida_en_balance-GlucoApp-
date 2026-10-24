import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// 09 · Mi alimentación
/// Todos los roles ven el catálogo; solo quien tiene el permiso
/// `editarAlimentacion` (administrador de salud) puede agregar o quitar.
class AlimentacionScreen extends StatelessWidget {
  const AlimentacionScreen({super.key});

  Future<void> _addFood(BuildContext context) async {
    final state = AppScope.of(context);
    final result = await showDialog<({String nombre, bool restringido})>(
      context: context,
      builder: (_) => const _AddFoodDialog(),
    );
    if (result != null) {
      state.addFood(result.nombre, restringido: result.restringido);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final canEdit = s.can(Permission.editarAlimentacion);
    final restringidos = s.foods.where((f) => f.restringido).toList();
    final recomendados = s.foods.where((f) => !f.restringido).toList();

    return AppScaffold(
      title: s.user!.role.isCliente ? 'Mi alimentación' : 'Alimentación',
      showNav: true,
      tab: NavTab.alimentacion,
      bottomAction: canEdit
          ? PrimaryButton(
              label: 'Agregar alimento',
              icon: Icons.add,
              onPressed: () => _addFood(context),
            )
          : null,
      child: Column(
        children: [
          _FoodSection(
            title: 'Alimentos restringidos',
            icon: Icons.cancel,
            color: AppColors.danger,
            bg: AppColors.dangerSoft,
            items: restringidos,
            onRemove: canEdit ? s.removeFood : null,
          ),
          const SizedBox(height: 18),
          _FoodSection(
            title: 'Platillos recomendados',
            icon: Icons.check_circle,
            color: AppColors.forest,
            bg: AppColors.sageSoft,
            items: recomendados,
            onRemove: canEdit ? s.removeFood : null,
          ),
        ],
      ),
    );
  }
}

class _FoodSection extends StatelessWidget {
  const _FoodSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.bg,
    required this.items,
    required this.onRemove,
  });
  final String title;
  final IconData icon;
  final Color color;
  final Color bg;
  final List<FoodItem> items;
  final void Function(FoodItem)? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sageLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: bg,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin elementos.',
                  style: TextStyle(color: AppColors.muted)),
            ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.sageLine),
            Padding(
              padding: EdgeInsets.fromLTRB(16, onRemove == null ? 14 : 4, 8,
                  onRemove == null ? 14 : 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 7, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(items[i].nombre,
                        style: const TextStyle(fontSize: 15)),
                  ),
                  if (onRemove != null)
                    IconButton(
                      tooltip: 'Quitar ${items[i].nombre}',
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.muted),
                      onPressed: () => onRemove!(items[i]),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddFoodDialog extends StatefulWidget {
  const _AddFoodDialog();

  @override
  State<_AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<_AddFoodDialog> {
  final _name = TextEditingController();
  bool _restringido = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar alimento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTextField(
            controller: _name,
            icon: Icons.restaurant,
            hint: 'Ej. Ensalada de nopales',
            errorText: _error,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChipTile(
                label: 'Recomendado',
                selected: !_restringido,
                onTap: () => setState(() => _restringido = false),
              ),
              ChoiceChipTile(
                label: 'Restringido',
                selected: _restringido,
                onTap: () => setState(() => _restringido = true),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.forest),
          onPressed: () {
            if (_name.text.trim().isEmpty) {
              setState(() => _error = 'Escribe el nombre');
              return;
            }
            Navigator.pop(
                context, (nombre: _name.text, restringido: _restringido));
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
