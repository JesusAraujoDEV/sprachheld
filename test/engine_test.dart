// Self-check del motor de quiz (lib/engine/): lógica no trivial (derivación
// de tiempos compuestos, SRS, normalización de respuesta, priorización de
// sesión), sin widgets — un caso por pieza, no una suite exhaustiva.

import 'package:flutter_test/flutter_test.dart';

import 'package:sprachheld/engine/check.dart';
import 'package:sprachheld/engine/conjugation.dart';
import 'package:sprachheld/engine/question.dart';
import 'package:sprachheld/engine/session.dart';
import 'package:sprachheld/engine/srs.dart';
import 'package:sprachheld/models/level.dart';
import 'package:sprachheld/models/verb.dart';

Verb _verb({
  required String id,
  required String infinitiv,
  required Aux aux,
  required String partizipII,
  required List<String> praesens,
  required List<String> praeteritum,
}) {
  return Verb(
    id: id,
    infinitiv: infinitiv,
    es: id,
    level: Level.a1,
    regularity: VerbRegularity.regular,
    separable: false,
    aux: aux,
    partizipII: partizipII,
    praesens: praesens,
    praeteritum: praeteritum,
    examples: const [],
  );
}

void main() {
  final haben = _verb(
    id: 'haben',
    infinitiv: 'haben',
    aux: Aux.haben,
    partizipII: 'gehabt',
    praesens: ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
    praeteritum: ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
  );
  final werden = _verb(
    id: 'werden',
    infinitiv: 'werden',
    aux: Aux.sein,
    partizipII: 'geworden',
    praesens: ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'],
    praeteritum: ['wurde', 'wurdest', 'wurde', 'wurden', 'wurdet', 'wurden'],
  );
  final machen = _verb(
    id: 'machen',
    infinitiv: 'machen',
    aux: Aux.haben,
    partizipII: 'gemacht',
    praesens: ['mache', 'machst', 'macht', 'machen', 'macht', 'machen'],
    praeteritum: ['machte', 'machtest', 'machte', 'machten', 'machtet', 'machten'],
  );
  final auxLookup = {Aux.haben: haben};

  group('Conjugation', () {
    test('perfekt = aux Präsens + partizipII', () {
      expect(Conjugation.perfekt(machen, auxLookup)[0], 'habe gemacht');
      expect(Conjugation.perfekt(machen, auxLookup)[2], 'hat gemacht');
    });

    test('plusquamperfekt = aux Präteritum + partizipII', () {
      expect(Conjugation.plusquamperfekt(machen, auxLookup)[0], 'hatte gemacht');
    });

    test('futur I = werden Präsens + infinitiv', () {
      expect(Conjugation.futurI(machen, werden)[0], 'werde machen');
    });

    test('futur II = werden Präsens + partizipII + aux infinitivo', () {
      expect(Conjugation.futurII(machen, werden)[0], 'werde gemacht haben');
    });
  });

  group('checkAnswer', () {
    test('normaliza mayúsculas, espacios y ß↔ss', () {
      expect(checkAnswer('gehst', '  Gehst ').correct, isTrue);
      expect(checkAnswer('groß', 'gross').correct, isTrue);
      expect(checkAnswer('gehst', 'geht').correct, isFalse);
    });
  });

  group('Srs', () {
    test('acierto sube de caja y agenda el intervalo correcto', () {
      final now = DateTime(2026, 1, 1);
      final state = SrsState.initial(now);
      final next = Srs.next(state, correct: true, now: now);
      expect(next.box, 2);
      expect(next.dueDate, now.add(const Duration(days: 1)));
    });

    test('fallo vuelve a caja 1 y suma wrongCount', () {
      final now = DateTime(2026, 1, 1);
      final state = SrsState(box: 4, dueDate: now, wrongCount: 0, lastSeen: now);
      final next = Srs.next(state, correct: false, now: now);
      expect(next.box, 1);
      expect(next.wrongCount, 1);
    });
  });

  group('buildSession', () {
    test('prioriza ítems due sobre nuevos y respeta el tamaño', () {
      final now = DateTime.now();
      final deck = List.generate(
        5,
        (i) => Question(id: 'q$i', mode: QuizMode.flashcard, prompt: i, answer: i),
      );
      // q0 está due (dueDate pasado); q1..q4 son "nuevos" (sin estado SRS).
      final srs = {
        'q0': SrsState(box: 1, dueDate: now.subtract(const Duration(days: 1)), wrongCount: 0, lastSeen: now),
      };
      final session = buildSession(deck, SessionOptions(size: 2, srs: srs, shuffle: false));
      expect(session.length, 2);
      expect(session.first.id, 'q0');
    });
  });
}
