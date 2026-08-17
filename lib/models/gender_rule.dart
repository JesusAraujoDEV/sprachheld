import 'noun.dart';

enum RuleKind { ending, semantic }

/// Regla de género der/die/das como dato consultable: alimenta el "por qué"
/// inline del quiz de género y las tarjetas del modo Tips (docs/PLAN.md §4).
class GenderRule {
  final String id;
  final Gender gender;
  final RuleKind kind;

  /// Terminación ("-ung") o categoría semántica ("alcoholes", "puntos cardinales").
  final String pattern;
  final String explanation;
  final List<String> examples;
  final List<String> exceptions;

  const GenderRule({
    required this.id,
    required this.gender,
    required this.kind,
    required this.pattern,
    required this.explanation,
    required this.examples,
    required this.exceptions,
  });

  factory GenderRule.fromJson(Map<String, dynamic> json) => GenderRule(
        id: json['id'] as String,
        gender: Gender.values.byName(json['gender'] as String),
        kind: RuleKind.values.byName(json['kind'] as String),
        pattern: json['pattern'] as String,
        explanation: json['explanation'] as String,
        examples: List<String>.from(json['examples'] as List),
        exceptions: List<String>.from(json['exceptions'] as List),
      );
}
