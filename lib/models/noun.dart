import 'level.dart';

enum Gender { der, die, das }

class Noun {
  final String id;

  /// Sin artículo, ej. "Zeitung".
  final String word;
  final Gender gender;
  final String plural;
  final String es;
  final Level level;

  /// → GenderRule.id. Null = excepción o sin regla clara (honesto, no se inventa).
  final String? ruleId;

  const Noun({
    required this.id,
    required this.word,
    required this.gender,
    required this.plural,
    required this.es,
    required this.level,
    this.ruleId,
  });

  factory Noun.fromJson(Map<String, dynamic> json) => Noun(
        id: json['id'] as String,
        word: json['word'] as String,
        gender: Gender.values.byName(json['gender'] as String),
        plural: json['plural'] as String,
        es: json['es'] as String,
        level: levelFromJson(json['level'] as String),
        ruleId: json['ruleId'] as String?,
      );
}
