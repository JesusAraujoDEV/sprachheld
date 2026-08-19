import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Celda compacta del grid "Practicar" del Home: icono + título corto, sin
/// subtítulo largo — 6 modos del mismo peso funcional no justifican el
/// tamaño de [ModeCard] (docs/PLAN-hora.md §7).
class ModeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const ModeTile({
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kSurfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kOutline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accent, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
