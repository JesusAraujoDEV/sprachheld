import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sprachheld/widgets/tappable_german_text.dart';

Widget _host(String sentence, Map<String, String> glossary) {
  return MaterialApp(
    home: Scaffold(
      body: TappableGermanText(sentence: sentence, glossary: glossary),
    ),
  );
}

void main() {
  const glossary = {'ich': 'yo', 'gehe': 'ir/caminar'};

  group('TappableGermanText', () {
    testWidgets('tapping a known word shows its Spanish meaning', (tester) async {
      await tester.pumpWidget(_host('Ich gehe nach Berlin.', glossary));

      await tester.tap(find.text('Ich'));
      await tester.pumpAndSettle();

      expect(find.text('yo'), findsOneWidget);
    });

    testWidgets('tapping an unknown word shows the fallback without crashing',
        (tester) async {
      await tester.pumpWidget(_host('Ich gehe nach Berlin.', glossary));

      await tester.tap(find.text('Berlin.'));
      await tester.pumpAndSettle();

      expect(find.text('(traducción no disponible)'), findsOneWidget);
    });

    testWidgets('lookup ignores case and trailing punctuation', (tester) async {
      await tester.pumpWidget(_host('Gehe!', glossary));

      await tester.tap(find.text('Gehe!'));
      await tester.pumpAndSettle();

      expect(find.text('ir/caminar'), findsOneWidget);
    });
  });
}
