import 'package:flutter/material.dart';

import '../../state/progress_notifier.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_chip.dart';

/// Fila de estadísticas del jugador (racha, XP, dominados, débiles). Escucha
/// al ProgressNotifier y se comparte entre el layout móvil y el ancho.
class HomeStats extends StatelessWidget {
  final ProgressNotifier progress;

  const HomeStats({required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: kSurfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kOutline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatChip(icon: '🔥', label: '${progress.streakDays} días'),
            StatChip(icon: '⭐', label: '${progress.xp} XP'),
            StatChip(icon: '✅', label: '${progress.masteredCount} dominados'),
            StatChip(icon: '📌', label: '${progress.weakCount} débiles'),
          ],
        ),
      ),
    );
  }
}
