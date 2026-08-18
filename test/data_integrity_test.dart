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
}
