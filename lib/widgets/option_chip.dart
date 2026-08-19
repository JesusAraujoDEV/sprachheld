import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Chip de opción compartido por los modos de "elegir la respuesta" (completar
/// frase, preposiciones). Superficie neutra hasta contestar; luego verde el
/// correcto y ámbar el elegido si erró. NO colorea por género — el color aquí
/// significa acierto/error, no der/die/das.
class OptionChip extends StatelessWidget {
  final String label;
  final String? chosen;
  final String correctValue;
  final VoidCallback onTap;

  const OptionChip({
    required this.label,
    required this.chosen,
    required this.correctValue,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final answered = chosen != null;
    final isCorrectOption = label == correctValue;
    final isChosenOption = label == chosen;

    var background = kSurfaceContainer;
    var border = kOutline;
    if (answered) {
      if (isCorrectOption) {
        background = kGenderDas.withValues(alpha: 0.22);
        border = kGenderDas;
      } else if (isChosenOption) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}
