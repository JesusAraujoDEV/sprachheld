import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/adjective.dart';
import '../models/gender_rule.dart';
import '../models/noun.dart';
import '../models/phrase.dart';
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

  static Future<List<Phrase>> loadPhrases() =>
      _loadList('assets/data/phrases.json', Phrase.fromJson);

  static Future<List<T>> _loadList<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}
