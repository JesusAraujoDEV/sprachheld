import 'package:flutter_test/flutter_test.dart';
import 'package:sprachheld/engine/clock.dart';
import 'package:sprachheld/models/clock_time.dart';

void main() {
  group('informal', () {
    // Tabla literal de la nota de clase del 13/06 (05:00 → 05:50).
    const table = {
      '05:00': 'fünf',
      '05:05': 'fünf nach fünf',
      '05:15': 'Viertel nach fünf',
      '05:20': 'zehn vor halb sechs',
      '05:25': 'fünf vor halb sechs',
      '05:30': 'halb sechs',
      '05:35': 'fünf nach halb sechs',
      '05:40': 'zehn nach halb sechs',
      '05:45': 'Viertel vor sechs',
      '05:50': 'zehn vor sechs',
    };

    for (final entry in table.entries) {
      test('${entry.key} → ${entry.value}', () {
        final parts = entry.key.split(':').map(int.parse).toList();
        final t = ClockTime(parts[0], parts[1]);
        expect(informal(t).de, entry.value);
      });
    }

    test('12:30 → halb eins (wrap 12→1, regresión de la nota del 30/05)', () {
      expect(informal(const ClockTime(12, 30)).de, 'halb eins');
    });

    test('minuto no múltiplo de 5 lanza ArgumentError', () {
      expect(() => informal(const ClockTime(5, 23)), throwsArgumentError);
    });
  });

  group('formal', () {
    test('01:00 → ein Uhr (eins → ein pegado a Uhr)', () {
      expect(formal(const ClockTime(1, 0)).de, 'ein Uhr');
    });

    test('13:00 → dreizehn Uhr (formal usa la hora 24h tal cual, sin pasar a 12h)', () {
      expect(formal(const ClockTime(13, 0)).de, 'dreizehn Uhr');
    });

    test('14:30 → vierzehn Uhr dreißig', () {
      expect(formal(const ClockTime(14, 30)).de, 'vierzehn Uhr dreißig');
    });

    test('zwölf Uhr para las 12:00', () {
      expect(formal(const ClockTime(12, 0)).de, 'zwölf Uhr');
    });
  });

  group('clockOptions', () {
    test('siempre incluye la respuesta correcta entre 4 opciones únicas', () {
      const target = ClockTime(8, 40);
      final options = clockOptions(target, (t) => informal(t).de);
      expect(options.length, 4);
      expect(options.toSet().length, 4);
      expect(options, contains(informal(target).de));
    });
  });
}
