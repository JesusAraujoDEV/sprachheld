import 'dart:math';

import '../models/clock_expression.dart';
import '../models/clock_time.dart';

/// Motor de "La Hora": deriva expresión formal/informal y distractores desde
/// `(hora, minuto)` en vez de curar las ~288 combinaciones a mano — mismo
/// principio que los tiempos compuestos de verbos (docs/PLAN-hora.md §2-3).

class _Word {
  final String de;
  final String phonetic;
  const _Word(this.de, this.phonetic);
}

const _units = [
  '', 'eins', 'zwei', 'drei', 'vier', 'fünf', 'sechs', 'sieben', 'acht', 'neun',
  'zehn', 'elf', 'zwölf', 'dreizehn', 'vierzehn', 'fünfzehn', 'sechzehn', 'siebzehn',
  'achtzehn', 'neunzehn',
];
const _unitsPhon = [
  '', 'ains', 'tsvai', 'drai', 'fia', 'fünf', 'zeks', 'zi-ben', 'ajt', 'noin',
  'tsen', 'elf', 'ts-völf', 'drai-tsen', 'fia-tsen', 'fünf-tsen', 'zeks-tsen',
  'zip-tsen', 'aj-tsen', 'noin-tsen',
];
const _tensWords = {2: 'zwanzig', 3: 'dreißig', 4: 'vierzig', 5: 'fünfzig'};
const _tensPhon = {2: 'tsvan-tsij', 3: 'drai-sij', 4: 'fia-tsij', 5: 'fünf-tsij'};
const _fixed = {
  'Uhr': 'u-a',
  'Viertel': 'fia-tel',
  'nach': 'naj',
  'vor': 'foa',
  'halb': 'halp',
};

_Word _num(int n, {bool ein = false}) {
  if (n == 1) return ein ? const _Word('ein', 'ain') : const _Word('eins', 'ains');
  if (n < 20) return _Word(_units[n], _unitsPhon[n]);
  final ones = n % 10;
  final tens = n ~/ 10;
  if (ones == 0) return _Word(_tensWords[tens]!, _tensPhon[tens]!);
  return _Word('${_units[ones]}und${_tensWords[tens]}', '${_unitsPhon[ones]}-und-${_tensPhon[tens]}');
}

_Word _fix(String word) => _Word(word, _fixed[word]!);

ClockExpression _build(List<_Word> words) => ClockExpression(
      tokens: words.map((w) => w.de).toList(),
      de: words.map((w) => w.de).join(' '),
      phonetic: '[${words.map((w) => w.phonetic).join(' ')}]',
    );

/// Hora formal/oficial (24h): `[Hora] + Uhr + [Minutos]`.
ClockExpression formal(ClockTime t) {
  final words = [_num(t.hour, ein: true), _fix('Uhr')];
  if (t.minute > 0) words.add(_num(t.minute));
  return _build(words);
}

/// Hora informal (12h) — mentalidad "hacia adelante": halb/Viertel toman
/// como referencia la hora SIGUIENTE, no la actual (docs/PLAN-hora.md §1-3).
/// Lanza [ArgumentError] si el minuto no es múltiplo de 5 (fuera de alcance).
ClockExpression informal(ClockTime t) {
  var h12 = t.hour % 12;
  if (h12 == 0) h12 = 12;
  final next = h12 % 12 + 1;
  final m = t.minute;

  final List<_Word> words;
  if (m == 0) {
    words = [_num(h12)];
  } else if (m == 15) {
    words = [_fix('Viertel'), _fix('nach'), _num(h12)];
  } else if (m == 30) {
    words = [_fix('halb'), _num(next)];
  } else if (m == 45) {
    words = [_fix('Viertel'), _fix('vor'), _num(next)];
  } else if (m == 5 || m == 10) {
    words = [_num(m), _fix('nach'), _num(h12)];
  } else if (m == 20 || m == 25) {
    words = [_num(30 - m), _fix('vor'), _fix('halb'), _num(next)];
  } else if (m == 35 || m == 40) {
    words = [_num(m - 30), _fix('nach'), _fix('halb'), _num(next)];
  } else if (m == 50 || m == 55) {
    words = [_num(60 - m), _fix('vor'), _num(next)];
  } else {
    throw ArgumentError('minuto no soportado (solo múltiplos de 5): $m');
  }
  return _build(words);
}

ClockTime _shiftMinutes(ClockTime t, int delta) {
  final total = (t.hour * 60 + t.minute + delta) % 1440;
  final wrapped = total < 0 ? total + 1440 : total;
  return ClockTime(wrapped ~/ 60, wrapped % 60);
}

/// Distractores derivados: hora vecina (±1h, el error clásico de mirar
/// "hacia atrás" en vez de a la hora siguiente) y minuto vecino (±5/10/15,
/// el error de nach/vor). Mismo generador para cualquier [render] —
/// digital, formal o informal — porque la perturbación es sobre el tiempo,
/// no sobre el texto (docs/PLAN-hora.md §4).
List<String> clockOptions(
  ClockTime target,
  String Function(ClockTime) render, {
  int count = 4,
  Random? random,
}) {
  final rnd = random ?? Random();
  final correct = render(target);
  final candidates = [
    for (final deltaH in [-1, 1]) _shiftMinutes(target, deltaH * 60),
    for (final deltaM in [-15, -10, -5, 5, 10, 15]) _shiftMinutes(target, deltaM),
  ]..shuffle(rnd);

  final chosen = <String>{correct};
  for (final candidate in candidates) {
    if (chosen.length >= count) break;
    chosen.add(render(candidate));
  }
  while (chosen.length < count) {
    chosen.add(render(ClockTime(rnd.nextInt(24), rnd.nextInt(12) * 5)));
  }
  return chosen.toList()..shuffle(rnd);
}
