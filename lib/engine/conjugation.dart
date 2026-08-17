import '../models/verb.dart';

/// Deriva los tiempos COMPUESTOS de un verbo en runtime a partir de
/// [Verb.aux] + [Verb.partizipII] + [Verb.infinitiv]. No se almacenan en el
/// JSON — evita repetir el auxiliar y el participio en cada tiempo
/// (docs/PLAN.md §3.1). Dart puro, sin dependencias de Flutter.
class Conjugation {
  /// Perfekt = aux (Präsens) + partizipII. Ej.: "habe gemacht".
  static List<String> perfekt(Verb verb, Map<Aux, Verb> auxLookup) =>
      _combine(_auxOf(verb, auxLookup).praesens, verb.partizipII);

  /// Plusquamperfekt = aux (Präteritum) + partizipII. Ej.: "hatte gemacht".
  static List<String> plusquamperfekt(Verb verb, Map<Aux, Verb> auxLookup) =>
      _combine(_auxOf(verb, auxLookup).praeteritum, verb.partizipII);

  /// Futur I = werden (Präsens) + infinitiv. Ej.: "werde machen".
  static List<String> futurI(Verb verb, Verb werden) =>
      _combine(werden.praesens, verb.infinitiv);

  /// Futur II = werden (Präsens) + partizipII + aux (infinitivo).
  /// Ej.: "werde gemacht haben".
  static List<String> futurII(Verb verb, Verb werden) => List.generate(
        6,
        (i) => '${werden.praesens[i]} ${verb.partizipII} ${verb.aux.name}',
      );

  static Verb _auxOf(Verb verb, Map<Aux, Verb> auxLookup) {
    final aux = auxLookup[verb.aux];
    if (aux == null) {
      throw ArgumentError('Falta el verbo auxiliar "${verb.aux.name}" en auxLookup');
    }
    return aux;
  }

  static List<String> _combine(List<String> forms, String suffix) =>
      forms.map((form) => '$form $suffix').toList();
}
