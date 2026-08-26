import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A single answer button in the verb quiz 2×2 grid.
class VerbOptionButton extends StatelessWidget {
  final String label;
  final String? chosen;
  final String correctValue;
  final VoidCallback onTap;

  const VerbOptionButton({
    required this.label,
    required this.chosen,
    required this.correctValue,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final answered = chosen != null;
    final isCorrect = label == correctValue;
    final isChosen = label == chosen;

    var background = kSurfaceContainer;
    var border = kOutline;
    if (answered) {
      if (isCorrect) {
        background = kGenderDas.withValues(alpha: 0.22);
        border = kGenderDas;
      } else if (isChosen) {
        background = kError.withValues(alpha: 0.22);
        border = kError;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: answered ? null : onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
