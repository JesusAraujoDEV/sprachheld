import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Tarjeta grande de opción para el paso 2 del sheet de verbos ("¿Qué
/// preferís?"): emoji + título + ejemplo, estilo tarjeta redondeada.
class DirectionOptionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String example;
  final VoidCallback onTap;

  const DirectionOptionCard({
    required this.emoji,
    required this.title,
    required this.example,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(example, style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: kOnSurfaceVariant.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
