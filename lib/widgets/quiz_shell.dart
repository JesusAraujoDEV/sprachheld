import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Chrome mínimo de una sesión: cerrar + barra de progreso. Genérico para
/// todos los modos — solo cambia el [child] (docs/PLAN.md §9).
class QuizShell extends StatelessWidget {
  final int index;
  final int total;
  final VoidCallback onClose;
  final Widget child;

  const QuizShell({
    required this.index,
    required this.total,
    required this.onClose,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: kOnSurfaceVariant,
                  onPressed: onClose,
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : index / total,
                      minHeight: 8,
                      backgroundColor: kOutlineVariant,
                      valueColor: const AlwaysStoppedAnimation(kPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
