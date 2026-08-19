import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/adjective.dart';
import '../models/gender_rule.dart';
import '../models/noun.dart';
import '../models/phrase.dart';
import '../models/preposition.dart';
import '../models/preposition_item.dart';
import '../models/verb.dart';

/// Carga los mazos desde `assets/data/*.json`. Cada método parsea una vez;
/// llamar varias veces vuelve a leer el asset — cachear en el caller si hace
/// falta (ponytail: sin capa de caché propia hasta que el costo se note).
class DataRepository {
  static Future<List<Verb>> loadVerbs() =>
      _loadList('assets/data/verbs.json', Verb.fromJson);

  static Future<List<Noun>> loadNouns() =>
      _loadList('assets/data/nouns.json', Noun.fromJson);

  static Future<List<GenderRule>> loadGenderRules() =>
      _loadList('assets/data/gender-rules.json', GenderRule.fromJson);

  static Future<List<Adjective>> loadAdjectives() =>
      _loadList('assets/data/adjectives.json', Adjective.fromJson);

  /// [asset] permite reutilizar el modo "Completar la frase" con otro banco
  /// (ej. las frases de preposiciones), sin duplicar el modelo Phrase.
  static Future<List<Phrase>> loadPhrases([
    String asset = 'assets/data/phrases.json',
  ]) =>
      _loadList(asset, Phrase.fromJson);

  static Future<List<Preposition>> loadPrepositions() =>
      _loadList('assets/data/prepositions.json', Preposition.fromJson);

  static Future<List<PrepositionItem>> loadPrepositionItems() =>
      _loadList('assets/data/preposition-double.json', PrepositionItem.fromJson);

  static Future<List<T>> _loadList<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}
