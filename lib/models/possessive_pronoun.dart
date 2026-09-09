/// Fila de la tabla de referencia Possessivpronomen (pronombre personal →
/// posesivo base en Nominativ). Solo consulta — no alimenta ningún quiz.
class PossessivePronoun {
  final String id;
  final String pronoun;
  final String pronounEs;
  final String possessive;
  final String example;

  const PossessivePronoun({
    required this.id,
    required this.pronoun,
    required this.pronounEs,
    required this.possessive,
    required this.example,
  });

  factory PossessivePronoun.fromJson(Map<String, dynamic> json) => PossessivePronoun(
        id: json['id'] as String,
        pronoun: json['pronoun'] as String,
        pronounEs: json['pronounEs'] as String,
        possessive: json['possessive'] as String,
        example: json['example'] as String,
      );
}
