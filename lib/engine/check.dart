class CheckResult {
  final bool correct;
  final String expected;

  const CheckResult({required this.correct, required this.expected});
}

/// Compara la respuesta escrita/elegida contra la esperada. Normaliza
/// espacios, mayúsculas y tolera ß↔ss (ponytail: sin fuzzy-match — exacto
/// tras normalizar; variantes aceptadas se listan en el dato, no aquí).
CheckResult checkAnswer(String expected, String input) {
  String normalize(String s) => s.trim().toLowerCase().replaceAll('ß', 'ss');
  return CheckResult(
    correct: normalize(expected) == normalize(input),
    expected: expected,
  );
}
