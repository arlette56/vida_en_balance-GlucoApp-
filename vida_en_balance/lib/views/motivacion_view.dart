import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// 12 · Motivación
class MotivacionScreen extends StatelessWidget {
  const MotivacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);

    return AppScaffold(
      title: 'Motivación',
      showNav: true,
      tab: NavTab.inicio,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
                color: AppColors.sageSoft, shape: BoxShape.circle),
            child: const Icon(Icons.favorite,
                size: 42, color: AppColors.danger),
          ),
          const SizedBox(height: 24),
          SoftCard(
            color: AppColors.sageSoft,
            borderColor: AppColors.sageLine,
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const Text('MENSAJE DEL DÍA',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forest)),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Semantics(
                    liveRegion: true,
                    key: ValueKey(s.messageIndex),
                    child: Text(
                      s.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20,
                          height: 1.35,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < motivationalMessages.length; i++)
                Container(
                  width: i == s.messageIndex ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == s.messageIndex
                        ? AppColors.forest
                        : AppColors.sageLine,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: s.nextMessage,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Otro mensaje',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forestDark,
                side: const BorderSide(color: AppColors.forest, width: 1.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
