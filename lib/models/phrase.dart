import 'level.dart';

/// Ítem del modo "Completar la frase". [sentence] trae el hueco marcado con
/// "___"; [options] son los chips (incluye [answer]) — ver docs/PLAN.md §6.3.
class Phrase {
  final String id;
  final String sentence;
  final String answer;
  final List<String> options;
  final String es;
  final Level level;

  /// El "por qué": caso, preposición, orden verbal, etc.
  final String? note;

  /// Grammatical case required by the preposition (dativ/akkusativ).
  /// Only present in preposition-phrases.json; null for generic phrases.
  final String? caseType;

  const Phrase({
    required this.id,
    required this.sentence,
    required this.answer,
    required this.options,
    required this.es,
    required this.level,
    this.note,
    this.caseType,
  });

  factory Phrase.fromJson(Map<String, dynamic> json) => Phrase(
        id: json['id'] as String,
        sentence: json['sentence'] as String,
        answer: json['answer'] as String,
        options: List<String>.from(json['options'] as List),
        es: json['es'] as String,
        level: levelFromJson(json['level'] as String),
        note: json['note'] as String?,
        caseType: json['caseType'] as String?,
      );
}
