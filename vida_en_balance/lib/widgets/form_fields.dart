import 'package:flutter/material.dart';

import '../theme.dart';
import 'cards.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.muted)),
      );
}

class ChoiceChipTile extends StatelessWidget {
  const ChoiceChipTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.sageSoft : Colors.white,
            border: Border.all(
              color: selected ? AppColors.forest : AppColors.sageLine,
              width: selected ? 1.6 : 1,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 16, color: AppColors.forest),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.forest : AppColors.ink,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Campo de texto con icono, estilo de los formularios del diagrama.
class IconTextField extends StatelessWidget {
  const IconTextField({
    super.key,
    required this.controller,
    required this.icon,
    this.hint,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.enabled = true,
    this.autofillHints,
  });
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool enabled;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        prefixIcon: Icon(icon, size: 20, color: AppColors.forest),
        suffixIcon: suffix,
        filled: true,
        fillColor: enabled ? Colors.white : AppColors.sageSoft,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: border(AppColors.sageLine),
        disabledBorder: border(AppColors.sageLine),
        focusedBorder: border(AppColors.forest, 1.8),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.8),
      ),
    );
  }
}

/// Campo que abre un selector (fecha, hora…) al tocarlo.
class PickerField extends StatelessWidget {
  const PickerField(
      {super.key, required this.icon, required this.text, required this.onTap});
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.forest),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

/// Mensaje de error en línea (formularios).
class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }
}
