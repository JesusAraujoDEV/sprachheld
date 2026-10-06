import 'package:flutter/material.dart';

import '../services/speak_service.dart';
import '../theme/app_theme.dart';

/// Frase alemana donde cada palabra es tocable: al tocarla, un mini-modal
/// muestra la palabra, su significado en español y un botón para escucharla
/// sola (estilo Duolingo). Recibe el [glossary] ya cargado — la pantalla es
/// la que llama a `DataRepository.loadWordGlosses()`; el widget solo renderiza.
///
/// Decisión de UI (ver work-log 2026-10-06): `showDialog` con un diálogo
/// chico, no un overlay anclado. Más simple y confiable, entra en el tope de
/// 150 líneas, y se cierra tocando afuera (comportamiento estándar del
/// barrier). En web se envuelve en [SelectionContainer.disabled] para que el
/// `SelectionArea` global (main.dart) no se quede con el tap de la palabra.
class TappableGermanText extends StatelessWidget {
  final String sentence;
  final Map<String, String> glossary;
  final TextStyle? style;
  final TextAlign textAlign;

  const TappableGermanText({
    required this.sentence,
    required this.glossary,
    this.style,
    this.textAlign = TextAlign.center,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final align = textAlign == TextAlign.center
        ? WrapAlignment.center
        : WrapAlignment.start;
    return SelectionContainer.disabled(
      child: Wrap(
        alignment: align,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 2,
        children: [
          for (final token in sentence.split(RegExp(r'\s+')))
            if (token.isNotEmpty) _wordSpan(context, token),
        ],
      ),
    );
  }

  Widget _wordSpan(BuildContext context, String token) {
    final word = _stripPunctuation(token);
    if (word.isEmpty) return Text(token, style: style);
    // Pista visual de que la palabra es tocable: manito del cursor en web
    // (MouseRegion no hace nada en móvil) + subrayado punteado sutil.
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showPopup(context, word),
        child: Text(
          token,
          style: (style ?? const TextStyle()).copyWith(
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: (style?.color ?? kOnSurface).withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  void _showPopup(BuildContext context, String word) {
    final meaning = glossary[word.toLowerCase()];
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _WordPopup(word: word, meaning: meaning),
    );
  }
}

/// Limpia puntuación de los bordes conservando letras alemanas y números.
String _stripPunctuation(String token) {
  return token.replaceAll(
    RegExp(r'^[^\wäöüßÄÖÜ]+|[^\wäöüßÄÖÜ]+$', unicode: true),
    '',
  );
}

class _WordPopup extends StatelessWidget {
  final String word;
  final String? meaning;

  const _WordPopup({required this.word, required this.meaning});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kSurfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700, color: kOnSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meaning ?? '(traducción no disponible)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kOnSurfaceVariant,
                          fontStyle: meaning == null ? FontStyle.italic : null,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up_rounded),
              color: kPrimary,
              tooltip: 'Escuchar pronunciación',
              onPressed: () => SpeakService.instance.speak(word),
            ),
          ],
        ),
      ),
    );
  }
}
