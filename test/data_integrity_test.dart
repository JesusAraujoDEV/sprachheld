// Self-check de integridad de los assets: con ~150 ítems curados a mano
// entre varias fuentes (Notion + subagentes), un id duplicado o un ruleId
// colgante son errores silenciosos fáciles de cometer y difíciles de notar
// jugando. Este test los detecta en CI/local sin necesidad de abrir la app.

import 'package:flutter_test/flutter_test.dart';

import 'package:sprachheld/data/repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('todos los ids de verbos son únicos', () async {
    final verbs = await DataRepository.loadVerbs();
    final ids = verbs.map((v) => v.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'hay ids de verbo duplicados');
  });

  test('todos los ids de sustantivos son únicos', () async {
    final nouns = await DataRepository.loadNouns();
    final ids = nouns.map((n) => n.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'hay ids de sustantivo duplicados');
  });

  test('todos los ruleId de sustantivos apuntan a una regla existente', () async {
    final nouns = await DataRepository.loadNouns();
    final rules = await DataRepository.loadGenderRules();
    final ruleIds = rules.map((r) => r.id).toSet();
    for (final noun in nouns) {
      if (noun.ruleId == null) continue;
      expect(
        ruleIds.contains(noun.ruleId),
        isTrue,
        reason: '${noun.word} apunta a ruleId "${noun.ruleId}" que no existe',
      );
    }
  });

  test('todos los ids de reglas de género son únicos', () async {
    final rules = await DataRepository.loadGenderRules();
    final ids = rules.map((r) => r.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'hay ids de regla duplicados');
  });

  test('prepositions.json parsea y tiene ids únicos', () async {
    final preps = await DataRepository.loadPrepositions();
    expect(preps, isNotEmpty);
    final ids = preps.map((p) => p.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'hay ids de preposición duplicados');
    // Las wechsel rigen dos casos; el resto uno — es la invariante del modelo.
    for (final p in preps) {
      final expected = p.category.name == 'wechsel' ? 2 : 1;
      expect(p.governs.length, expected, reason: '${p.prep} rige ${p.governs.length} casos');
    }
  });

  test('preposition-phrases.json: answer siempre está entre options y hay hueco', () async {
    final phrases =
        await DataRepository.loadPhrases('assets/data/preposition-phrases.json');
    expect(phrases, isNotEmpty);
    final ids = phrases.map((p) => p.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'hay ids de frase duplicados');
    for (final p in phrases) {
      expect(p.options.contains(p.answer), isTrue,
          reason: '${p.id}: la respuesta "${p.answer}" no está en las opciones');
      expect(p.sentence.contains('___'), isTrue, reason: '${p.id}: falta el hueco ___');
    }
  });

  test('preposition-double.json (Nivel 2): dos huecos, ambas respuestas en sus '
      'opciones, ids únicos', () async {
    final items = await DataRepository.loadPrepositionItems();
    expect(items, isNotEmpty);
    final ids = items.map((it) => it.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'hay ids de ítem duplicados');
    for (final it in items) {
      expect('___'.allMatches(it.sentence).length, 2,
          reason: '${it.id}: debe tener exactamente 2 huecos (preposición + artículo)');
      expect(it.prepOptions.contains(it.prep), isTrue,
          reason: '${it.id}: la preposición "${it.prep}" no está en prepOptions');
      expect(it.articleOptions.contains(it.article), isTrue,
          reason: '${it.id}: el artículo "${it.article}" no está en articleOptions');
    }
  });

  test('frequencyRank de verbos es posición entre verbos, no entre todas las '
      'palabras del idioma (regresión: "Top 100" mostraba solo ~7 verbos '
      'porque el rango era el de la lista de frecuencia completa, dominada '
      'por artículos/pronombres)', () async {
    final verbs = await DataRepository.loadVerbs();
    final top100 = verbs.where((v) => (v.frequencyRank ?? 999999) <= 100).length;
    expect(
      top100,
      100,
      reason: 'debería haber exactamente 100 verbos con frequencyRank <= 100 '
          '(es la definición de "Top 100" entre verbos)',
    );
    // haber/ser/poder son verbos centrales del idioma: si no están en el
    // puñado más frecuente, el ranking está mal calculado otra vez.
    final topIds = verbs
        .where((v) => (v.frequencyRank ?? 999999) <= 10)
        .map((v) => v.id)
        .toSet();
    for (final expected in ['haben', 'sein', 'koennen']) {
      expect(topIds.contains(expected), isTrue, reason: '$expected debería estar en el top 10');
    }
  });
}
