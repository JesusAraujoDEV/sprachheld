import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/adjective.dart';
import '../models/article_declension.dart';
import '../models/gender_rule.dart';
import '../models/noun.dart';
import '../models/phrase.dart';
import '../models/possessive_pronoun.dart';
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

  static Future<List<PossessivePronoun>> loadPossessivePronouns() =>
      _loadList('assets/data/possessive-pronouns.json', PossessivePronoun.fromJson);

  static Future<List<ArticleDeclension>> loadArticleDeclensions() =>
      _loadList('assets/data/article-declensions.json', ArticleDeclension.fromJson);

  /// Mapa plano `palabra (minúscula) → significado en español` para la
  /// traducción al tocar. Se pide en cada pantalla de quiz, así que se cachea
  /// en memoria la primera vez (a diferencia de los mazos, que se cargan una
  /// vez por sesión de todos modos). Es un mapa, no una lista: no usa
  /// [_loadList] ni un modelo propio.
  static Future<Map<String, String>>? _glossesCache;

  static Future<Map<String, String>> loadWordGlosses() =>
      _glossesCache ??= _loadGlosses();

  static Future<Map<String, String>> _loadGlosses() async {
    final raw = await rootBundle.loadString('assets/data/word-glosses.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  static Future<List<T>> _loadList<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}
