import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = Colors.white,
    this.borderColor = AppColors.sageLine,
    this.onTap,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Etiqueta con el rol y, si acompaña a alguien, a quién.
class RoleBanner extends StatelessWidget {
  const RoleBanner({super.key, required this.role, this.patientName});
  final UserRole role;
  final String? patientName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sageSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(role.icon, size: 20, color: AppColors.forest),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              patientName == null
                  ? role.label
                  : '${role.label} · Cliente: $patientName',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestDark),
            ),
          ),
        ],
      ),
    );
  }
}
