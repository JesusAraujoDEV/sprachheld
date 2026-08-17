import 'level.dart';

enum VerbRegularity { regular, irregular }

enum Aux { haben, sein }

/// Un verbo alemán. Solo se almacenan los tiempos SINTÉTICOS (Präsens,
/// Präteritum, Konjunktiv II); los compuestos (Perfekt, Plusquamperfekt,
/// Futur I/II) se derivan en runtime de [aux] + [partizipII] + [infinitiv]
/// — ver `lib/engine/conjugation.dart`. Evita repetir el auxiliar y el
/// participio en cada tiempo compuesto (docs/PLAN.md §3.1).
class Verb {
  final String id;
  final String infinitiv;
  final String es;
  final Level level;
  final VerbRegularity regularity;
  final bool separable;

  final Aux aux;
  final String partizipII;

  /// Las 6 formas en orden fijo: [ich, du, er/sie/es, wir, ihr, sie/Sie].
  final List<String> praesens;
  final List<String> praeteritum;
  final List<String>? konjunktivII;

  final List<String> examples;
  final String? conjugationNote;

  const Verb({
    required this.id,
    required this.infinitiv,
    required this.es,
    required this.level,
    required this.regularity,
    required this.separable,
    required this.aux,
    required this.partizipII,
    required this.praesens,
    required this.praeteritum,
    this.konjunktivII,
    required this.examples,
    this.conjugationNote,
  });

  factory Verb.fromJson(Map<String, dynamic> json) => Verb(
        id: json['id'] as String,
        infinitiv: json['infinitiv'] as String,
        es: json['es'] as String,
        level: levelFromJson(json['level'] as String),
        regularity: VerbRegularity.values.byName(json['regularity'] as String),
        separable: json['separable'] as bool,
        aux: Aux.values.byName(json['aux'] as String),
        partizipII: json['partizipII'] as String,
        praesens: List<String>.from(json['praesens'] as List),
        praeteritum: List<String>.from(json['praeteritum'] as List),
        konjunktivII: json['konjunktivII'] != null
            ? List<String>.from(json['konjunktivII'] as List)
            : null,
        examples: List<String>.from(json['examples'] as List),
        conjugationNote: json['conjugationNote'] as String?,
      );
}
