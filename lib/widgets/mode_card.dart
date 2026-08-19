import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tarjeta full-width de un modo destacado (hoy solo Contrarreloj — el modo
/// de mayor prioridad visual del Home, ver docs/PLAN-hora.md §7).
class ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const ModeCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSurfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kOutline),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: -8,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 40,
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(6)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kOnSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
