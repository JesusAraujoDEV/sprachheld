/// Una expresión hablada de la hora, ya construida por el motor
/// (`lib/engine/clock.dart`). [tokens] es la fuente de verdad; [de] y
/// [phonetic] son dos renderizados de la misma lista de palabras.
class ClockExpression {
  final List<String> tokens;
  final String de;
  final String phonetic;

  const ClockExpression({required this.tokens, required this.de, required this.phonetic});
}
