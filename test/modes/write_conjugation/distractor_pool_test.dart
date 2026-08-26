import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprachheld/modes/write_conjugation/distractor_pool.dart';
import 'package:sprachheld/models/level.dart';
import 'package:sprachheld/models/verb.dart';

void main() {
  final verb = Verb(
    id: 'gehen',
    infinitiv: 'gehen',
    es: 'ir',
    level: Level.a1,
    regularity: VerbRegularity.irregular,
    separable: false,
    aux: Aux.sein,
    partizipII: 'gegangen',
    praesens: ['gehe', 'gehst', 'geht', 'gehen', 'geht', 'gehen'],
    praeteritum: ['ging', 'gingst', 'ging', 'gingen', 'gingt', 'gingen'],
    examples: ['Ich gehe nach Hause.'],
  );

  test('pool never contains the correct answer', () {
    const correct = 'gehst';
    final pool = distractorPool(verb, correct, random: Random(42));

    expect(pool, isNot(contains(correct)));
  });

  test('pool has exactly count unique entries for a normal verb', () {
    const correct = 'gehe';
    final pool = distractorPool(verb, correct, count: 3, random: Random(7));

    expect(pool.length, 3);
    expect(pool.toSet().length, 3);
  });

  test('pool draws from praesens and praeteritum forms', () {
    const correct = 'gehe';
    final allForms = {...verb.praesens, ...verb.praeteritum}..remove(correct);
    final pool = distractorPool(verb, correct, random: Random(1));

    for (final entry in pool) {
      expect(allForms, contains(entry));
    }
  });

  test('handles verb with many duplicate forms gracefully', () {
    // Verb where praesens and praeteritum have overlapping forms
    final dupVerb = Verb(
      id: 'test',
      infinitiv: 'test',
      es: 'test',
      level: Level.a1,
      regularity: VerbRegularity.regular,
      separable: false,
      aux: Aux.haben,
      partizipII: 'getestet',
      praesens: ['a', 'b', 'a', 'a', 'b', 'a'],
      praeteritum: ['c', 'c', 'c', 'c', 'c', 'c'],
      examples: [],
    );

    // correct='a' → unique pool is {'b','c'} → only 2 unique, needs padding
    final pool = distractorPool(dupVerb, 'a', count: 3, random: Random(0));

    expect(pool.length, 3);
    expect(pool, isNot(contains('a')));
  });
}
