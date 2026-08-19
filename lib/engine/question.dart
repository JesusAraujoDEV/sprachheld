enum QuizMode { flashcard, writeConjugation, fillPhrase, genderQuiz, tips, clockQuiz }

/// Pregunta genérica de sesión. [prompt]/[answer] se narrowean por [mode] en
/// el widget del modo correspondiente — cinco modos no justifican un union
/// type discriminado completo (ponytail; se ajusta si el `dynamic` empieza a
/// esconder bugs). Ver docs/PLAN.md §9.
class Question {
  final String id;
  final QuizMode mode;
  final dynamic prompt;
  final dynamic answer;

  const Question({
    required this.id,
    required this.mode,
    required this.prompt,
    required this.answer,
  });
}
