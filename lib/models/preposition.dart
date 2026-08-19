import 'german_case.dart';
import 'level.dart';

/// Categoría por el caso que rige. `wechsel` son las 9 que rigen dos casos
/// según movimiento (Akkusativ) vs. ubicación (Dativ).
enum PrepCategory { akkusativ, dativ, wechsel, genitiv }

/// Preposición alemana — dato de referencia que alimenta el modo Tips y el
/// modo de práctica (docs/PLAN-preposiciones.md §3.1). La regla Wohin/Wo no
/// es un campo: vive en [examples] y en la nota de cada ejercicio, porque
/// depende de la frase, no de la preposición.
class Preposition {
  final String id;
  final String prep;
  final PrepCategory category;

  /// Casos que rige. Las `wechsel` traen dos ([akkusativ, dativ]); el resto uno.
  final List<GermanCase> governs;
  final String es;
  final Level level;
  final List<String> examples;

  const Preposition({
    required this.id,
    required this.prep,
    required this.category,
    required this.governs,
    required this.es,
    required this.level,
    required this.examples,
  });

  factory Preposition.fromJson(Map<String, dynamic> json) => Preposition(
        id: json['id'] as String,
        prep: json['prep'] as String,
        category: PrepCategory.values.byName(json['category'] as String),
        governs: (json['governs'] as List)
            .map((c) => germanCaseFromJson(c as String))
            .toList(),
        es: json['es'] as String,
        level: levelFromJson(json['level'] as String),
        examples: List<String>.from(json['examples'] as List),
      );
}
